#!/usr/bin/env python3
import subprocess


def get_wifi_networks():
    try:
        result = subprocess.run(
            ["nmcli", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list"],
            capture_output=True,
            text=True,
        )

        content = '(box :orientation "vertical" :space-evenly false'
        content += ' (button :class "wifi-refresh" :onclick "nmcli device wifi rescan" "󰑓 Refresh")'

        # Process each network
        for line in result.stdout.strip().split("\n")[1:]:
            parts = [part for part in line.split("  ") if part]
            if len(parts) >= 3:
                ssid = parts[0].strip()
                if ssid:
                    signal = int(parts[1].strip())
                    security = parts[2].strip()

                    # Signal strength icon
                    if signal >= 75:
                        icon = "󰤨"
                    elif signal >= 50:
                        icon = "󰤥"
                    elif signal >= 25:
                        icon = "󰤢"
                    else:
                        icon = "󰤟"

                    # Add lock icon if secured
                    if security != "--":
                        icon += " 󰌾"

                    content += f' (button :class "wifi-network" :onclick "nmcli device wifi connect \'{ssid}\'" "{icon} {ssid}")'

        content += ")"
        return content

    except Exception as e:
        return '(box :class "wifi-error" (button "󰤭 Error loading networks"))'


if __name__ == "__main__":
    print(get_wifi_networks())
