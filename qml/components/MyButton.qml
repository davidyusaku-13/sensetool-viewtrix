import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

RoundButton{
    id: button
    implicitWidth: 45
    implicitHeight: 45
    property int tooltipX: button.width + 5
    property int tooltipY: (button.height/2 - implicitHeight/2)
    Accessible.role: Accessible.Button
    Accessible.name: text
    highlighted: false
    display: AbstractButton.IconOnly
    icon.source: "images/plus"
    HoverHandler{
        cursorShape: Qt.PointingHandCursor
    }
    ToolTip{
        visible: button.hovered
        text: button.text
        x: button.tooltipX
        y: button.tooltipY
    }
}