pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import QtQuick

Singleton {
  id: root

  property var stats: ({
    cpu_text: "0",
    memory_text: "0",
    backlight_text: "0",
    network_text: "Disconnected",
    down_kb: 0,
    up_kb: 0
  })

  property string submapText: ""
  property var projectWorkspaceNames: ({})
  property string currentProjectWorkspace: ""
  property string currentProjectName: ""
  property string currentProjectSlot: ""
  property var currentProjectSlots: []

  property string volText: "0"
  property bool volMuted: true
  property string micText: "0"
  property bool micMuted: true

  readonly property var batteryDevice: UPower.displayDevice
  readonly property var mediaPlayer: {
    const players = Mpris.players.values || [];
    for (const player of players) {
      if (player && player.isPlaying) return player;
    }
    return players.length > 0 ? players[0] : null;
  }
  readonly property string mediaText: {
    const player = mediaPlayer;
    if (!player) return "";
    const title = player.trackTitle || player.identity || "Media";
    const artist = player.trackArtist || "";
    return artist ? `${artist} - ${title}` : title;
  }
  readonly property string clockText: Qt.formatDateTime(clock.date, "ddd, d MMMM, HH:mm")
  readonly property string batteryText: {
    const battery = batteryDevice;
    if (!battery || !battery.isLaptopBattery || !battery.isPresent) return "";
    const raw = battery.percentage || 0;
    const pct = Math.round(raw > 1 ? raw : raw * 100);
    if (battery.state === UPowerDeviceState.Charging) return `${pct}`;
    if (battery.state === UPowerDeviceState.FullyCharged) return `${pct}`;
    return `${pct}`;
  }
  readonly property bool batteryCharging: {
    const battery = batteryDevice;
    return battery ? battery.state === UPowerDeviceState.Charging : false;
  }
  readonly property color batteryFill: {
    const battery = batteryDevice;
    const raw = battery ? (battery.percentage || 0) : 100;
    const pct = Math.round(raw > 1 ? raw : raw * 100);
    if (pct <= 15) return Theme.urgent;
    if (pct <= 30) return "#e6c384";
    return Theme.chipDark;
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Process {
    id: statsProc
    command: ["sh", "-c", "$HOME/.scripts/quickshell-bar-stats"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        try {
          root.stats = JSON.parse(data);
        } catch (err) {
          console.warn("failed to parse quickshell-bar-stats", err);
        }
      }
    }

    onRunningChanged: if (!running) running = true
  }

  Process {
    id: audioProc
    command: ["sh", "-c", "$HOME/.scripts/quickshell-audio-monitor"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        try {
          const obj = JSON.parse(data);
          root.volText = obj.v;
          root.volMuted = obj.vm;
          root.micText = obj.m;
          root.micMuted = obj.mm;
        } catch (err) {}
      }
    }

    onRunningChanged: if (!running) running = true
  }

  Process {
    id: submapProc
    command: [
      "sh",
      "-c",
      "while :; do hyprctl submap 2>/dev/null || printf 'default\\n'; sleep 0.5; done"
    ]
    running: true

    stdout: SplitParser {
      onRead: data => {
        const value = data.trim();
        root.submapText = value === "default" ? "" : value;
      }
    }

    onRunningChanged: if (!running) running = true
  }

  Process {
    id: hypeProc
    command: [
      "sh",
      "-c",
      "while :; do $HOME/.scripts/hype workspace-map 2>/dev/null || true; printf '\\f\\n'; sleep 0.5; done"
    ]
    running: true

    stdout: SplitParser {
      property string chunk: ""

      onRead: data => {
        chunk += data + "\n";
        const parts = chunk.split("\f\n");
        chunk = parts.pop();

        for (const part of parts) {
          const mapping = {};
          let currentWorkspace = "";
          for (const line of part.split("\n")) {
            const trimmed = line.trim();
            if (!trimmed) continue;
            const fields = trimmed.split("\t");
            if (fields.length < 3) continue;
            const name = fields[0];
            const workspace = fields[1];
            const isCurrent = fields[2] === "1";
            mapping[workspace] = name;
            if (isCurrent) currentWorkspace = workspace;
          }
          root.projectWorkspaceNames = mapping;
          root.currentProjectWorkspace = currentWorkspace;
        }
      }
    }

    onRunningChanged: if (!running) running = true
  }

  Process {
    id: hypeSlotProc
    command: [
      "sh",
      "-c",
      "while :; do $HOME/.scripts/hype slot-map 2>/dev/null || true; printf '\\f\\n'; sleep 0.4; done"
    ]
    running: true

    stdout: SplitParser {
      property string chunk: ""

      onRead: data => {
        chunk += data + "\n";
        const parts = chunk.split("\f\n");
        chunk = parts.pop();

        for (const part of parts) {
          let projectName = "";
          let currentSlot = "";
          const slots = [];
          for (const line of part.split("\n")) {
            const trimmed = line.trim();
            if (!trimmed) continue;
            const fields = trimmed.split("\t");
            if (fields.length < 2) continue;
            if (fields[0] === "project") projectName = fields[1];
            if (fields[0] === "current") currentSlot = fields[1];
            if (fields[0] === "slot") slots.push(fields[1]);
          }
          root.currentProjectName = projectName;
          root.currentProjectSlot = currentSlot;
          root.currentProjectSlots = slots;
        }
      }
    }

    onRunningChanged: if (!running) running = true
  }
}
