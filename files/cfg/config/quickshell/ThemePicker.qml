import Quickshell
import QtQuick
import QtQuick.Layouts

Chip {
  id: root

  required property var barWindow
  property bool expanded: false
  readonly property int swatchWidth: 44

  fill: expanded ? Theme.chipBlue : Theme.chipLight
  activeFocusOnTab: true
  Accessible.role: Accessible.Button
  Accessible.name: "Theme: " + Theme.theme.name
  Accessible.onPressAction: expanded = !expanded
  Keys.onReturnPressed: expanded = !expanded
  Keys.onSpacePressed: expanded = !expanded

  Text {
    color: Theme.text
    text: "\uF1FC"
    font.pixelSize: Theme.fontSize
    font.family: Theme.iconFont
  }

  TapHandler {
    onTapped: root.expanded = !root.expanded
  }

  // Preview of one palette: its background with text, accent, and urgent dots.
  component Swatch: Rectangle {
    required property var colors

    implicitWidth: root.swatchWidth
    implicitHeight: 16
    color: colors.panelBg
    border.width: 1
    border.color: colors.panelBorder

    Row {
      anchors.centerIn: parent
      spacing: 4

      Repeater {
        model: [colors.text, colors.activeText, colors.urgent]

        delegate: Rectangle {
          required property color modelData
          width: 7
          height: 7
          color: modelData
        }
      }
    }
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
    implicitWidth: 280
    implicitHeight: content.implicitHeight + 24
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
      anchors.margins: 12
      focus: true
      Keys.onEscapePressed: root.expanded = false

      ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 2

        RowLayout {
          Layout.fillWidth: true
          Layout.leftMargin: 8
          Layout.rightMargin: 8
          Layout.bottomMargin: 6
          spacing: 8

          Text {
            Layout.fillWidth: true
            text: "Theme"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 16
            font.bold: true
          }
          Repeater {
            model: ["Dark", "Light"]

            delegate: Text {
              required property string modelData
              Layout.preferredWidth: root.swatchWidth
              horizontalAlignment: Text.AlignHCenter
              text: modelData
              color: (modelData === "Light") === Theme.isLight ? Theme.text : Theme.mutedText
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
            }
          }
        }

        Repeater {
          model: Theme.themes

          delegate: Rectangle {
            id: option
            required property var modelData
            readonly property bool selected: modelData.id === Theme.themeId

            Layout.fillWidth: true
            implicitHeight: 28
            color: selected ? Theme.chipBlue : activeFocus || hover.hovered ? Theme.chipLight : "transparent"
            focus: selected
            activeFocusOnTab: true
            Accessible.role: Accessible.RadioButton
            Accessible.name: modelData.name
            Accessible.checked: selected
            Accessible.onPressAction: Theme.select(modelData.id)
            Keys.onReturnPressed: Theme.select(modelData.id)
            Keys.onSpacePressed: Theme.select(modelData.id)
            Keys.onUpPressed: nextItemInFocusChain(false).forceActiveFocus()
            Keys.onDownPressed: nextItemInFocusChain(true).forceActiveFocus()

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 8
              anchors.rightMargin: 8
              spacing: 8

              Text {
                Layout.fillWidth: true
                text: option.modelData.name
                color: option.selected ? Theme.activeText : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
              }
              Swatch { colors: option.modelData.dark }
              Swatch { colors: option.modelData.light }
            }

            HoverHandler { id: hover }
            TapHandler { onTapped: Theme.select(option.modelData.id) }
          }
        }
      }
    }
  }
}
