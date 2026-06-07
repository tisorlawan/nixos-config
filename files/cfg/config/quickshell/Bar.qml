import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel

      required property var modelData
      property bool barVisible: true

      screen: modelData
      color: "transparent"
      aboveWindows: true
      focusable: false
      implicitHeight: Theme.barHeight
      visible: barVisible
      anchors {
        top: true
        left: true
        right: true
      }

      Process {
        id: barToggleProc
        command: [
          "sh",
          "-c",
          "STATE_DIR=\"${XDG_STATE_HOME:-$HOME/.local/state}/quickshell-bar-toggle\"; STATE_FILE=\"$STATE_DIR/hidden\"; mkdir -p \"$STATE_DIR\"; last=''; while :; do value=1; [ -f \"$STATE_FILE\" ] && value=0; if [ \"$value\" != \"$last\" ]; then printf '%s\\n' \"$value\"; last=\"$value\"; fi; sleep 0.2; done"
        ]
        running: true

        stdout: SplitParser {
          onRead: data => {
            panel.barVisible = data.trim() !== "0";
          }
        }

        onRunningChanged: if (!running) running = true
      }

      Rectangle {
        anchors.fill: parent
        color: Theme.panelBg

        Item {
          anchors.fill: parent
          anchors.margins: 0

          RowLayout {
            anchors.fill: parent
            spacing: Theme.chipGap

            Row {
              spacing: Theme.chipGap

              Repeater {
                model: {
                  return (Hyprland.workspaces.values || [])
                    .filter(w => w.id > 0 && (BarData.occupiedWorkspaceIds[w.id] || w.active || w.focused))
                    .sort((a, b) => a.id - b.id);
                }

                delegate: Chip {
                  required property var modelData

                  fill: modelData.urgent
                    ? Theme.urgent
                    : modelData.focused
                      ? Theme.chipBlue
                      : modelData.active
                        ? Theme.chipGreen
                        : Theme.chipLight
                  fg: modelData.focused ? Theme.activeText : Theme.text

                  Text {
                    color: modelData.focused ? Theme.activeText : Theme.text
                    text: String(modelData.name).substring(0, 3)
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                  }

                  TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: modelData.activate()
                  }
                }
              }

              Chip {
                visible: BarData.submapText.length > 0
                fill: Theme.chipGreen

                Text {
                  color: Theme.text
                  text: "\uF11C"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
                Text {
                  color: Theme.text
                  text: BarData.submapText
                  font.pixelSize: Theme.fontSize
                  font.italic: true
                  font.family: Theme.fontFamily
                }
              }

              // Chip {
              //   visible: BarData.mediaText.length > 0
              //   fill: Theme.chipBlue
              //   width: Math.min(320, implicitWidth)
              //   clip: true
              //
              //   Text {
              //     width: 300
              //     color: Theme.text
              //     text: "\uF001 " + BarData.mediaText
              //     elide: Text.ElideRight
              //     font.pixelSize: Theme.fontSize
              //     font.family: Theme.fontFamily
              //   }
              // }
            }

            Item { Layout.fillWidth: true }

            Row {
              spacing: Theme.chipGap

              Rectangle {
                width: 130
                height: Theme.chipHeight
                radius: Theme.chipRadius
                color: Theme.chipDark
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.08)

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.verticalCenterOffset: Theme.textYOffset
                  color: Theme.text
                  text: "\uF063 " + String(BarData.stats.down_kb || 0).padEnd(4, ' ') + " \uF062 " + String(BarData.stats.up_kb || 0).padEnd(3, ' ')
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
              }

              Chip {
                fill: Theme.chipLight

                Text {
                  color: BarData.volMuted ? Theme.urgent : Theme.text
                  text: BarData.volMuted ? "\uF026" : "\uF028"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
                Text {
                  color: BarData.volMuted ? Theme.urgent : Theme.text
                  text: BarData.volText
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.fontFamily
                }
                Text {
                  color: BarData.micMuted ? Theme.urgent : Theme.text
                  text: BarData.micMuted ? "\uF131" : "\uF130"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
                Text {
                  color: BarData.micMuted ? Theme.urgent : Theme.text
                  text: BarData.micText
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.fontFamily
                }

                TapHandler {
                  acceptedButtons: Qt.LeftButton
                  onTapped: audioLauncher.startDetached()
                }

                Process {
                  id: audioLauncher
                  command: ["pavucontrol"]
                }
              }

              Chip {
                fill: Theme.chipDark

                Text {
                  color: Theme.text
                  text: "\uF185"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
                Text {
                  color: Theme.text
                  text: BarData.stats.backlight_text || "0"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.fontFamily
                }
              }

              Chip {
                fill: Theme.chipLight

                Text {
                  color: parseInt(BarData.stats.cpu_text) > 80 ? Theme.urgent : Theme.text
                  text: "\uF2DB"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
                Text {
                  color: parseInt(BarData.stats.cpu_text) > 80 ? Theme.urgent : Theme.text
                  text: BarData.stats.cpu_text || "0"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.fontFamily
                }
              }

              Chip {
                fill: Theme.chipDark

                Text {
                  color: parseInt(BarData.stats.memory_text) > 80 ? Theme.urgent : Theme.text
                  text: "\uF233"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
                Text {
                  color: parseInt(BarData.stats.memory_text) > 80 ? Theme.urgent : Theme.text
                  text: BarData.stats.memory_text || "0"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.fontFamily
                }
              }

              Chip {
                visible: BarData.batteryText.length > 0
                fill: Theme.chipLight

                Text {
                  color: Theme.text
                  text: BarData.batteryCharging ? "\uF0E7" : "\uF241"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
                Text {
                  color: Theme.text
                  text: BarData.batteryText
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.fontFamily
                }
              }

              Chip {
                fill: Theme.chipDark

                Text {
                  color: Theme.text
                  text: BarData.stats.network_text === "Disconnected" ? "\uF127" :
                        (BarData.stats.network_text || "").indexOf("WiFi") >= 0 ? "\uF1EB" : "\uF0AC"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.iconFont
                }
                Text {
                  color: Theme.text
                  text: BarData.stats.network_text || "Disconnected"
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.fontFamily
                }

                TapHandler {
                  acceptedButtons: Qt.LeftButton
                  onTapped: networkLauncher.startDetached()
                }

                Process {
                  id: networkLauncher
                  command: ["nm-connection-editor"]
                }
              }

              Chip {
                visible: (SystemTray.items.values || []).length > 0
                fill: Theme.chipLight

                Repeater {
                  model: SystemTray.items.values || []

                  delegate: Rectangle {
                    required property var modelData

                    width: 18
                    height: 18
                    radius: 4
                    color: "transparent"

                    IconImage {
                      anchors.fill: parent
                      implicitSize: 18
                      source: modelData.icon || ""
                    }

                    TapHandler {
                      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                      onTapped: point => {
                        if (point.button === Qt.LeftButton) {
                          modelData.activate();
                        } else {
                          const pos = parent.mapToItem(null, point.position.x, point.position.y);
                          modelData.display(panel, pos.x, pos.y);
                        }
                      }
                    }
                  }
                }
              }

              Chip {
                fill: Theme.chipLight

                Text {
                  color: Theme.text
                  text: BarData.clockText
                  font.pixelSize: Theme.fontSize
                  font.family: Theme.fontFamily
                }
              }
            }
          }
        }
      }
    }
  }
}
