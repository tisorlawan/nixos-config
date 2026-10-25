import QtQuick

Rectangle {
  id: root
  required property string text
  property string label: text
  signal clicked()

  implicitWidth: buttonText.implicitWidth + 16
  implicitHeight: 26
  color: activeFocus || hover.hovered ? Theme.chipBlue : Theme.chipLight
  opacity: enabled ? 1 : 0.5
  activeFocusOnTab: true
  Accessible.role: Accessible.Button
  Accessible.name: label
  Accessible.onPressAction: clicked()
  Keys.onReturnPressed: clicked()
  Keys.onSpacePressed: clicked()

  Text {
    id: buttonText
    anchors.centerIn: parent
    text: root.text
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
  }
  HoverHandler { id: hover }
  TapHandler { onTapped: root.clicked() }
}
