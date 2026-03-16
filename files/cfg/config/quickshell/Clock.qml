import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel

      required property var modelData

      property bool clockVisible: true
      readonly property string displayTime: Qt.formatDateTime(clock.date, "HH:mm")

      screen: modelData
      color: "transparent"
      aboveWindows: true
      focusable: false
      implicitWidth: clockBox.implicitWidth
      implicitHeight: clockBox.implicitHeight
      anchors {
        top: true
        right: true
      }

      visible: clockVisible

      Process {
        id: clockToggleProc
        command: [
          "sh",
          "-c",
          "STATE_DIR=\"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell-clock-toggle\"; STATE_FILE=\"$STATE_DIR/hidden\"; mkdir -p \"$STATE_DIR\"; last=''; while :; do value=1; [ -f \"$STATE_FILE\" ] && value=0; if [ \"$value\" != \"$last\" ]; then printf '%s\\n' \"$value\"; last=\"$value\"; fi; sleep 0.2; done"
        ]
        running: true

        stdout: SplitParser {
          onRead: data => {
            panel.clockVisible = data.trim() !== "0";
          }
        }

        onRunningChanged: if (!running) running = true
      }

      SystemClock {
        id: clock
        precision: SystemClock.Seconds
      }

      Rectangle {
        id: clockBox
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 0
        anchors.rightMargin: 0
        implicitWidth: clockText.implicitWidth + 20
        implicitHeight: clockText.implicitHeight + 12
        radius: 8
        color: Qt.rgba(0.12, 0.12, 0.16, 0.9)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        Text {
          id: clockText
          anchors.centerIn: parent
          color: Theme.text
          text: panel.displayTime
          font.pixelSize: 30
          font.family: Theme.fontFamily
          font.weight: 700
          renderType: Text.NativeRendering
        }
      }

    }
  }
}
