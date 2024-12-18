#!/usr/bin/env python
import os
import select
import socket
import time


class SystemMonitor:
    def __init__(self):
        self.mem_icon = " "
        self.cpu_icon = " "
        self.prev_cpu_stats = self.get_cpu_stats()
        self.prev_time = time.time()

    def get_cpu_stats(self):
        with open("/proc/stat", "r") as f:
            line = f.readline().split()
        user, nice, system, idle, iowait, irq, softirq = map(float, line[1:8])
        idle_total = idle + iowait
        non_idle = user + nice + system + irq + softirq
        total = idle_total + non_idle
        return total, idle_total

    def get_memory_usage(self):
        with open("/proc/meminfo", "r") as f:
            lines = f.readlines()
        total_mem = int(lines[0].split()[1])
        available_mem = int(lines[2].split()[1])
        mem_percent = ((total_mem - available_mem) / total_mem) * 100
        return mem_percent

    def get_status(self):
        # CPU usage with proper calculation
        total2, idle2 = self.get_cpu_stats()
        total1, idle1 = self.prev_cpu_stats

        total_diff = total2 - total1
        idle_diff = idle2 - idle1
        cpu_percent = (1 - (idle_diff / total_diff)) * 100 if total_diff > 0 else 0

        # Update previous CPU stats
        self.prev_cpu_stats = (total2, idle2)

        # Memory usage
        mem_percent = self.get_memory_usage()

        # Return just the values and icons, let eww handle the markup
        return f'{{"cpu_icon": "{self.cpu_icon}", "cpu_value": "{cpu_percent:.1f}", "mem_icon": "{self.mem_icon}", "mem_value": "{mem_percent:.1f}"}}'


def setup_inotify():
    sock = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, 15)
    sock.bind((os.getpid(), 1))
    return sock


def main():
    monitor = SystemMonitor()
    sock = setup_inotify()
    sock.setblocking(False)

    poller = select.poll()
    poller.register(sock.fileno(), select.POLLIN)

    print(monitor.get_status(), flush=True)
    last_update = time.time()

    try:
        while True:
            events = poller.poll(0)
            current_time = time.time()
            time_until_next_update = 1.0 - (current_time - last_update)

            if events or time_until_next_update <= 0:
                if events:
                    sock.recv(4096)
                print(monitor.get_status(), flush=True)
                last_update = current_time
                time_until_next_update = 1.0

            time.sleep(min(0.1, time_until_next_update))
    except KeyboardInterrupt:
        sock.close()


if __name__ == "__main__":
    main()
