#!/usr/bin/env python3
import subprocess
import sys


class AudioMonitor:
    def __init__(self):
        # self.speaker_icons = {"high": "󰕾", "medium": "󰖀", "low": "󰕿", "muted": "󰝟"}
        self.speaker_icons = {"high": "󰕾", "medium": "󰖀", "low": "󰕿", "muted": "󰝟"}
        self.mic_icons = {"on": "󰍬", "muted": "󰍭"}

    def get_speaker_info(self):
        try:
            volume_result = subprocess.run(
                ["pactl", "get-sink-volume", "@DEFAULT_SINK@"],
                capture_output=True,
                text=True,
            )
            volume_line = volume_result.stdout.strip()

            mute_result = subprocess.run(
                ["pactl", "get-sink-mute", "@DEFAULT_SINK@"],
                capture_output=True,
                text=True,
            )

            volume = int(volume_line.split("/")[1].strip().replace("%", ""))
            muted = "yes" in mute_result.stdout.lower()

            if muted:
                icon = self.speaker_icons["muted"]
            elif volume > 65:
                icon = self.speaker_icons["high"]
            elif volume > 35:
                icon = self.speaker_icons["medium"]
            else:
                icon = self.speaker_icons["low"]

            return {"icon": icon, "volume": volume, "muted": muted}

        except Exception as e:
            print(f"Speaker Error: {e}", file=sys.stderr)
            return {"icon": self.speaker_icons["muted"], "volume": 0, "muted": True}

    def get_mic_info(self):
        try:
            volume_result = subprocess.run(
                ["pactl", "get-source-volume", "@DEFAULT_SOURCE@"],
                capture_output=True,
                text=True,
            )
            volume_line = volume_result.stdout.strip()

            mute_result = subprocess.run(
                ["pactl", "get-source-mute", "@DEFAULT_SOURCE@"],
                capture_output=True,
                text=True,
            )

            volume = int(volume_line.split("/")[1].strip().replace("%", ""))
            muted = "yes" in mute_result.stdout.lower()

            icon = self.mic_icons["muted"] if muted else self.mic_icons["on"]

            return {"icon": icon, "volume": volume, "muted": muted}

        except Exception as e:
            print(f"Mic Error: {e}", file=sys.stderr)
            return {"icon": self.mic_icons["muted"], "volume": 0, "muted": True}

    def get_status(self):
        speaker = self.get_speaker_info()
        mic = self.get_mic_info()

        # Combine both into a single output
        speaker_output = f"{speaker['icon']} {speaker['volume']}"
        if speaker["muted"]:
            speaker_output = "[M]"
        mic_output = f"{mic['icon']} {mic['volume']}"
        if mic["muted"]:
            mic_output = "[M]"

        print(
            f"{speaker_output}   {mic_output}",
            flush=True,
        )


def main():
    monitor = AudioMonitor()

    # Start pactl subscribe process
    subscribe_process = subprocess.Popen(
        ["pactl", "subscribe"], stdout=subprocess.PIPE, text=True
    )

    # Print initial status
    monitor.get_status()

    try:
        while True:
            line = subscribe_process.stdout.readline()
            # Update on sink (speaker) or source (mic) events
            if "sink" in line or "source" in line:
                monitor.get_status()

    except KeyboardInterrupt:
        subscribe_process.kill()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        subscribe_process.kill()
        sys.exit(1)


if __name__ == "__main__":
    main()
