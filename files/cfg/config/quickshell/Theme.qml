pragma Singleton

import Quickshell
import QtQuick

Singleton {
  readonly property string fontFamily: "Berkeley Mono"
  readonly property string iconFont: "BlexMono Nerd Font"
  readonly property int fontSize: 12

  readonly property color panelBg: "#1f1f28"
  readonly property color panelBorder: "#3b4252"
  readonly property color text: "#dcd7ba"
  readonly property color mutedText: "#727169"
  readonly property color activeText: "#9cabca"
  readonly property color urgent: "#f7768e"
  readonly property color chipDark: "#1f1f28"
  readonly property color chipLight: "#434349"
  readonly property color chipBlue: "#223249"
  readonly property color chipGreen: "#2b3328"
  readonly property int barHeight: 25
  readonly property int barPadding: 6
  readonly property int chipHeight: 26
  readonly property int chipRadius: 0
  readonly property int chipPadX: 10
  readonly property int chipGap: 0
  readonly property int inlineGap: 6
  readonly property int textYOffset: -1
}
