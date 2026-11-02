import QtQuick

Rectangle {
  id: root

  required property color fill
  property color fg: Theme.text
  default property alias content: row.data

  radius: Theme.chipRadius
  color: fill
  border.width: 1
  border.color: Theme.chipBorder

  implicitHeight: Theme.chipHeight
  implicitWidth: row.implicitWidth + Theme.chipPadX * 2

  Row {
    id: row
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: Theme.textYOffset
    spacing: Theme.inlineGap
  }
}
