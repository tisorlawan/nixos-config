#!/usr/bin/env python
import os
import select
import socket
import subprocess
import time
from typing import Tuple


class NetworkMonitor:
    def __init__(self):
        self.iface = os.environ.get("WLAN_IFACE", "wlan0")
        self.icons = {"connected": "󰤨 ", "disconnected": "󰤭 "}
        self.prev_rx = 0
        self.prev_tx = 0
        self.prev_time = time.time()

    def get_ssid(self) -> str:
        try:
            result = subprocess.run(
                f"iw {self.iface} link | grep SSID",
                shell=True,
                capture_output=True,
                text=True,
            )
            if result.stdout:
                return result.stdout.strip().split("SSID: ")[1]
            return ""
        except:
            return ""

    def get_network_speeds(self) -> Tuple[float, float]:
        try:
            with open(f"/sys/class/net/{self.iface}/statistics/rx_bytes") as f:
                rx = int(f.read())
            with open(f"/sys/class/net/{self.iface}/statistics/tx_bytes") as f:
                tx = int(f.read())
            current_time = time.time()
            time_diff = current_time - self.prev_time
            # Calculate speeds in MB/s
            rx_speed = (rx - self.prev_rx) / (1024 * 1024 * time_diff)
            tx_speed = (tx - self.prev_tx) / (1024 * 1024 * time_diff)
            # Update previous values
            self.prev_rx = rx
            self.prev_tx = tx
            self.prev_time = current_time
            return rx_speed, tx_speed
        except:
            return 0.0, 0.0

    def format_speed(self, speed: float) -> str:
        speed_kb = speed * 1024
        if speed_kb > 1024:
            return f"<b>{speed_kb:.1f}</b>"
        return f"{speed_kb:.1f}"

    def get_status(self) -> str:
        ssid = self.get_ssid()
        if ssid:
            rx_speed, tx_speed = self.get_network_speeds()
            content = f"{self.icons['connected']}  {ssid} (↓{self.format_speed(rx_speed)}, ↑{self.format_speed(tx_speed)})"
            if rx_speed > 3000:
                content = f"{self.icons['connected']}  {ssid} (↓ -, ↑ -)"
            return f'(label :markup "{content}" :class "network-label")'
        return (
            f"(label :markup \"{self.icons['disconnected']}\" :class \"network-label\")"
        )


def setup_netlink_socket():
    sock = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, 15)
    sock.bind((os.getpid(), 1))
    return sock


def main():
    monitor = NetworkMonitor()
    sock = setup_netlink_socket()
    sock.setblocking(False)
    # For select() to monitor socket
    poller = select.poll()
    poller.register(sock.fileno(), select.POLLIN)
    # Print initial status
    print(monitor.get_status(), flush=True)
    last_update = time.time()
    try:
        while True:
            # Check for socket events (non-blocking)
            events = poller.poll(0)  # Returns immediately
            current_time = time.time()
            time_until_next_update = 1.0 - (current_time - last_update)
            if events or time_until_next_update <= 0:
                # If there's a network event or it's time for speed update
                if events:
                    sock.recv(4096)  # Clear the socket buffer
                print(monitor.get_status(), flush=True)
                last_update = current_time
                time_until_next_update = 1.0
            # Sleep for a short time to avoid busy waiting
            time.sleep(min(0.1, time_until_next_update))
    except KeyboardInterrupt:
        sock.close()


if __name__ == "__main__":
    main()
