#!/usr/bin/env python
import subprocess

# Regular battery icons
bat_status_arr = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
# Charging battery icons
bat_charging_arr = ["󰢜", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋"]


def get_bat_status():
    acpi = subprocess.run(["acpi"], capture_output=True)
    bat_status = acpi.stdout.decode("utf-8")

    # Get charging status
    status = bat_status.split(":")[1].split(",")[0].strip()
    status_indicator = ""
    is_charging = False

    if "not charging" == status.lower() or "charging" == status.lower():
        status_indicator = ""
        is_charging = True
    elif "Discharging" in status:
        status_indicator = ""
        is_charging = False
    elif "Full" in status:
        status_indicator = "[F]"

    # Get percentage
    percentage = bat_status.split(",")[1].strip()[:-1]

    bat_icon = (
        bat_charging_arr[(int(percentage) // 10) - 1]
        if is_charging
        else bat_status_arr[(int(percentage) // 10) - 1]
    )

    if is_charging:
        percentage = f"<b>{percentage}</b>"

    if status_indicator == "[F]":
        return f'(label :markup "{status_indicator}")'

    return f'(label :markup "{bat_icon} {status_indicator}{percentage}")'


print(get_bat_status())
