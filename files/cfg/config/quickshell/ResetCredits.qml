import QtQuick
import QtQuick.Layouts

Column {
  id: root
  required property string accountId
  visible: ResetData.accountId === accountId && ResetData.state !== ResetData.Closed
  spacing: 6

  Text {
    width: parent.width
    visible: ResetData.busy || ResetData.error.length > 0
      || ResetData.state === ResetData.Complete || ResetData.credits.length === 0
    text: ResetData.state === ResetData.Submitting ? "Reset request in progress…"
      : ResetData.state === ResetData.Loading ? "Read reset credits…"
      : ResetData.error || (ResetData.state === ResetData.Complete ? "Reset complete." : "No usable resets.")
    color: ResetData.error ? Theme.urgent : Theme.mutedText
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize - 1
    wrapMode: Text.WordWrap
  }

  Repeater {
    model: root.visible && (ResetData.state === ResetData.Ready || ResetData.state === ResetData.Confirming)
      ? ResetData.credits : []

    delegate: Column {
      id: entry
      required property var modelData
      readonly property bool selected: ResetData.selected !== null && ResetData.selected.id === modelData.id
      width: root.width
      spacing: 4

      RowLayout {
        width: parent.width

        ColumnLayout {
          Layout.fillWidth: true
          Layout.minimumWidth: 0
          spacing: 3

          Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: entry.modelData.title || entry.modelData.id
            textFormat: Text.PlainText
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            elide: Text.ElideMiddle
          }
          Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: entry.modelData.expiresAt === null ? "No expiry"
              : "Expires " + Qt.formatDateTime(new Date(entry.modelData.expiresAt), "d MMM HH:mm")
            color: Theme.mutedText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            elide: Text.ElideRight
          }
        }
        QuotaButton {
          text: "Use"
          label: "Use credit " + entry.modelData.id
          enabled: ResetData.state === ResetData.Ready
          onClicked: ResetData.select(entry.modelData)
        }
      }

      Column {
        width: parent.width
        spacing: 4
        visible: entry.selected

        Text {
          text: "Credit: " + entry.modelData.id
          textFormat: Text.PlainText
          width: parent.width
          color: Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
          wrapMode: Text.WrapAnywhere
        }
        Text {
          text: "Use this credit? You cannot undo this action."
          width: parent.width
          color: Theme.urgent
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
          wrapMode: Text.WordWrap
        }
        Row {
          spacing: 6
          QuotaButton {
            text: "Cancel"
            onClicked: ResetData.cancel()
          }
          QuotaButton {
            text: "Use reset"
            label: "Confirm credit " + entry.modelData.id
            onClicked: ResetData.consume()
          }
        }
      }
    }
  }
}
