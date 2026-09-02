pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  // Live color mode. Source of truth is ~/.color, written by
  // ~/.scripts/set-color ("dark" or "light"). Defaults to dark.
  property string rawMode: "dark"
  readonly property bool isLight: rawMode === "light"

  readonly property string fontFamily: "Berkeley Mono"
  readonly property string iconFont: "BlexMono Nerd Font"
  readonly property int fontSize: 12

  // Dark palette matches the nvim nightfox/kanagawa setup; light palette
  // matches colors/light.lua.
  readonly property color panelBg: isLight ? "#fefefe" : "#1f1f28"
  readonly property color panelBorder: isLight ? "#d0d0d0" : "#3b4252"
  readonly property color text: isLight ? "#000000" : "#dcd7ba"
  readonly property color mutedText: isLight ? "#8a8a8a" : "#727169"
  readonly property color activeText: isLight ? "#1561b8" : "#9cabca"
  readonly property color urgent: isLight ? "#c2372c" : "#f7768e"
  readonly property color chipDark: isLight ? "#f0f0f0" : "#1f1f28"
  readonly property color chipLight: isLight ? "#e4e4e4" : "#434349"
  readonly property color chipBlue: isLight ? "#dbe7f8" : "#223249"
  readonly property color chipGreen: isLight ? "#e0efe0" : "#2b3328"
  readonly property int barHeight: 25
  readonly property int barPadding: 6
  readonly property int chipHeight: 26
  readonly property int chipRadius: 0
  readonly property int chipPadX: 10
  readonly property int chipGap: 0
  readonly property int inlineGap: 6
  readonly property int textYOffset: -1


  // Poll ~/.color for mode changes. FileView's change-watch reloads stale
  // content in quickshell 0.3.0, so use the same polling pattern as Bar.qml.
  Process {
    command: ["sh", "-c", "last=''; while :; do v=$(cat \"$HOME/.color\" 2>/dev/null || true); case \"$v\" in *light*) v=light ;; *) v=dark ;; esac; if [ \"$v\" != \"$last\" ]; then printf '%s\\n' \"$v\"; last=\"$v\"; fi; sleep 1; done"]
    running: true

    stdout: SplitParser {
      onRead: data => root.rawMode = data.trim()
    }
  }
}
