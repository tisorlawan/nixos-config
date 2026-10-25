import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Quota.js" as Quota

Chip {
  id: root

  required property var barWindow
  property bool expanded: false
  onExpandedChanged: if (!expanded) ResetData.close()

  fill: expanded ? Theme.chipBlue : Theme.chipDark
  activeFocusOnTab: true
  Accessible.role: Accessible.Button
  Accessible.name: "CLIProxy account quotas"
  Accessible.onPressAction: toggle()
  Keys.onReturnPressed: toggle()
  Keys.onSpacePressed: toggle()

  function toggle() {
    expanded = !expanded;
    if (expanded) QuotaData.refresh();
  }

  Text {
    text: "AI " + (QuotaData.generatedAt === null ? "—" : QuotaData.accountCount)
      + (QuotaData.error || QuotaData.accountError || QuotaData.stale ? " !" : "")
    color: QuotaData.error || QuotaData.accountError || QuotaData.stale ? Theme.urgent : Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
  }

  TapHandler {
    onTapped: root.toggle()
  }

  PopupWindow {
    id: popup

    visible: root.expanded && root.barWindow.visible
    onVisibleChanged: if (!visible) root.expanded = false
    anchor.item: root
    anchor.rect.x: root.width
    anchor.rect.y: root.height + 4
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.SlideY
    implicitWidth: Math.min(420, root.barWindow.screen.width - 24)
    implicitHeight: Math.min(content.implicitHeight + 32, root.barWindow.screen.height - Theme.barHeight - 32)
    color: Theme.panelBg
    grabFocus: true

    Rectangle {
      anchors.fill: parent
      color: "transparent"
      border.width: 1
      border.color: Theme.panelBorder
    }

    FocusScope {
      anchors.fill: parent
      anchors.margins: 16
      focus: true
      Keys.onEscapePressed: root.expanded = false

      ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: 12

        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          Text {
            text: "CLIProxy"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 16
            font.bold: true
            Layout.fillWidth: true
          }
          QuotaButton {
            text: QuotaData.busy ? "…" : "↻"
            label: "Refresh"
            enabled: !QuotaData.busy
            onClicked: QuotaData.refresh()
          }
          QuotaButton {
            text: "×"
            label: "Close"
            onClicked: root.expanded = false
          }
        }

        RowLayout {
          Layout.fillWidth: true

          Text {
            Layout.fillWidth: true
            text: QuotaData.generatedAt === null ? "" : Qt.formatDateTime(new Date(QuotaData.generatedAt), "HH:mm")
            color: Theme.mutedText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
          }
          Text {
            text: "Remaining · reset in"
            color: Theme.mutedText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
          }
        }

        Text {
          Layout.fillWidth: true
          visible: QuotaData.error.length > 0 || QuotaData.stale
          text: QuotaData.error || "Quota data is out of date."
          color: Theme.urgent
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
          wrapMode: Text.WordWrap
        }

        Text {
          Layout.fillWidth: true
          visible: QuotaData.accountCount === 0
          text: QuotaData.busy && QuotaData.generatedAt === null ? "Read quotas…"
            : QuotaData.generatedAt !== null ? "No Claude or Codex accounts." : ""
          color: Theme.mutedText
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
          wrapMode: Text.WordWrap
        }

        ScrollView {
          id: quotaScroll
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.preferredHeight: providers.implicitHeight
          visible: QuotaData.accountCount > 0
          clip: true
          contentWidth: availableWidth
          ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

          Column {
            id: providers
            width: quotaScroll.availableWidth
            spacing: 16

            Repeater {
              model: QuotaData.groups

              delegate: Column {
                required property var modelData
                width: providers.width
                spacing: 10

                Text {
                  text: modelData.name
                  color: Theme.activeText
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize
                  font.bold: true
                }

                Repeater {
                  model: modelData.accounts

                  delegate: Column {
                    id: account
                    required property var modelData
                    width: providers.width
                    spacing: 6

                    HoverHandler {
                      id: accountHover
                      onHoveredChanged: {
                        if (hovered) closeCredits.stop();
                        else closeCredits.start();
                      }
                    }

                    Timer {
                      id: closeCredits
                      interval: 150
                      onTriggered: {
                        if (!accountHover.hovered && ResetData.accountId === account.modelData.id
                            && (ResetData.state === ResetData.Ready || ResetData.state === ResetData.Loading)) {
                          ResetData.close();
                        }
                      }
                    }

                    RowLayout {
                      width: parent.width

                      Text {
                        Layout.fillWidth: true
                        text: account.modelData.name
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        elide: Text.ElideMiddle
                      }
                      Text {
                        text: "P" + (account.modelData.priority === null ? "—" : account.modelData.priority)
                        color: Theme.mutedText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                      }
                      Text {
                        visible: account.modelData.resetCredits !== null
                        text: account.modelData.resetCredits + " resets"
                        color: account.modelData.resetCredits > 0 ? Theme.activeText : Theme.mutedText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        font.underline: creditHover.hovered && account.modelData.resetCredits > 0
                        activeFocusOnTab: account.modelData.resetCredits > 0
                        Accessible.role: Accessible.Button
                        Accessible.name: "Reset credits for " + account.modelData.name
                        Accessible.onPressAction: if (account.modelData.resetCredits > 0) ResetData.show(account.modelData.id)
                        Keys.onReturnPressed: if (account.modelData.resetCredits > 0) ResetData.show(account.modelData.id)
                        Keys.onSpacePressed: if (account.modelData.resetCredits > 0) ResetData.show(account.modelData.id)

                        HoverHandler {
                          id: creditHover
                          onHoveredChanged: if (hovered && account.modelData.resetCredits > 0) ResetData.show(account.modelData.id)
                        }
                        TapHandler {
                          onTapped: if (account.modelData.resetCredits > 0) ResetData.show(account.modelData.id)
                        }
                      }
                    }

                    ResetCredits {
                      width: account.width
                      accountId: account.modelData.id
                    }

                    Text {
                      width: parent.width
                      visible: account.modelData.error.length > 0 || account.modelData.windows.length === 0
                      text: account.modelData.error || "Quota unavailable."
                      color: Theme.urgent
                      font.family: Theme.fontFamily
                      font.pixelSize: Theme.fontSize
                      wrapMode: Text.WordWrap
                    }

                    Repeater {
                      model: account.modelData.windows

                      delegate: RowLayout {
                        id: limit
                        required property var modelData
                        width: account.width
                        spacing: 8

                        Text {
                          Layout.preferredWidth: 64
                          text: limit.modelData.label === "5 hours" ? "5h" : limit.modelData.label
                          color: Theme.mutedText
                          font.family: Theme.fontFamily
                          font.pixelSize: Theme.fontSize
                          elide: Text.ElideRight
                        }

                        Rectangle {
                          Layout.fillWidth: true
                          height: 3
                          color: Theme.chipLight

                          Rectangle {
                            width: parent.width * (limit.modelData.remaining === null ? 0 : limit.modelData.remaining / 100)
                            height: parent.height
                            color: limit.modelData.remaining <= 20 ? Theme.urgent : Theme.activeText
                          }
                        }

                        Text {
                          Layout.preferredWidth: 48
                          horizontalAlignment: Text.AlignRight
                          text: limit.modelData.remaining === null ? "—"
                            : (Math.round(limit.modelData.remaining * 10) / 10) + "%"
                          color: limit.modelData.remaining !== null && limit.modelData.remaining <= 20
                            ? Theme.urgent : Theme.text
                          font.family: Theme.fontFamily
                          font.pixelSize: Theme.fontSize
                        }

                        Text {
                          Layout.preferredWidth: 72
                          horizontalAlignment: Text.AlignRight
                          text: Quota.resetText(limit.modelData.resetAt, QuotaData.now)
                          color: Theme.mutedText
                          font.family: Theme.fontFamily
                          font.pixelSize: Theme.fontSize
                        }
                      }
                    }

                    Rectangle {
                      width: parent.width
                      height: 1
                      color: Theme.panelBorder
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

}
