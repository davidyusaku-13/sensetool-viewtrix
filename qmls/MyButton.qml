import QtQuick
import QtQuick.Controls

RoundButton{
    id: button
    width: 35
    height: 35
    radius: 5
    display: AbstractButton.IconOnly
    palette{
        button: hovered ? "#d6d6d6" : "transparent"
    }
    HoverHandler{
        cursorShape: Qt.PointingHandCursor
    }

    ToolTip{
        visible: button.hovered
        text: button.text
        x: button.width+5
        y: button.height/2 - implicitHeight/2
    }
}
