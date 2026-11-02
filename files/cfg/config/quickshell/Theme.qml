pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "Themes.js" as Themes

Singleton {
  id: root

  // Live color mode. Source of truth is ~/.color, written by
  // ~/.scripts/set-color ("dark" or "light"). Defaults to dark.
  property string rawMode: "dark"
  readonly property bool isLight: rawMode === "light"

  // Selected theme. Source of truth is the state file below, written by
  // select(). Always a valid ID: the poll parses unknown IDs to the default.
  property string themeId: Themes.themes[0].id
  readonly property var themes: Themes.themes
  readonly property var theme: Themes.find(themeId)
  readonly property var colors: isLight ? theme.light : theme.dark

  // Shell expression for the theme state directory.
  readonly property string stateDir: "\"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell-theme\""

  readonly property string fontFamily: "Berkeley Mono"
  readonly property string iconFont: "BlexMono Nerd Font"
  readonly property int fontSize: 12

  // Color roles are documented in Themes.js.
  readonly property color panelBg: colors.panelBg
  readonly property color panelBorder: colors.panelBorder
  readonly property color text: colors.text
  readonly property color mutedText: colors.mutedText
  readonly property color activeText: colors.activeText
  readonly property color urgent: colors.urgent
  readonly property color chipDark: colors.chipDark
  readonly property color chipLight: colors.chipLight
  readonly property color chipBlue: colors.chipBlue
  readonly property color chipGreen: colors.chipGreen
  readonly property color chipBorder: Qt.rgba(text.r, text.g, text.b, 0.08)
  readonly property int barHeight: 25
  readonly property int barPadding: 6
  readonly property int chipHeight: 26
  readonly property int chipRadius: 0
  readonly property int chipPadX: 10
  readonly property int chipGap: 0
  readonly property int inlineGap: 6
  readonly property int textYOffset: -1

  function select(id) {
    themeWriter.command = ["sh", "-c",
      "dir=" + stateDir + "; mkdir -p \"$dir\" && printf '%s\\n' \"$1\" >\"$dir/theme.tmp\" && mv \"$dir/theme.tmp\" \"$dir/theme\"",
      "sh", Themes.find(id).id];
    themeWriter.startDetached();
  }

  Process {
    id: themeWriter
  }

  // Poll ~/.color and the theme state file. Each change prints one line:
  // "<dark|light> <theme id>". FileView's change-watch reloads stale content
  // in quickshell 0.3.0, so use the same polling pattern as Bar.qml.
  Process {
    command: ["sh", "-c",
      "state=" + stateDir + "/theme; last=''; while :; do "
      + "mode=$(cat \"$HOME/.color\" 2>/dev/null || true); "
      + "case \"$mode\" in *light*) mode=light ;; *) mode=dark ;; esac; "
      + "theme=''; { read -r theme <\"$state\"; } 2>/dev/null; "
      + "value=\"$mode $theme\"; "
      + "if [ \"$value\" != \"$last\" ]; then printf '%s\\n' \"$value\"; last=\"$value\"; fi; "
      + "sleep 0.25; done"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        const [mode, id] = data.trim().split(/\s+/);
        root.rawMode = mode;
        root.themeId = Themes.find(id).id;
      }
    }
  }
}
