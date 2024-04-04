import QtQuick 2.15
import QtQuick.Controls 2.15

RoundButton{
    id: button
    width: 50
    height: 50
    radius: 5
    flat: true

    ToolTip{
        visible: button.hovered
        text: button.text
    }
}
