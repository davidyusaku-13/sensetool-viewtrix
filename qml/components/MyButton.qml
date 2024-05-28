import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

RoundButton{
    id: button
    implicitWidth: 45
    implicitHeight: 45
    property bool isHeaderBtn: false
    highlighted: false
    display: AbstractButton.IconOnly
    icon.source: "images/plus"
    HoverHandler{
        cursorShape: Qt.PointingHandCursor
    }
    ToolTip{
        visible: button.hovered
        text: button.text
        x: isHeaderBtn ? 0 : (button.width+5)
        y: isHeaderBtn ? button.height : (button.height/2 - implicitHeight/2)
    }
}