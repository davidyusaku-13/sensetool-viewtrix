import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

BaseRoundButton {
    id: button
    implicitWidth: 45
    implicitHeight: 45
    property int tooltipX: button.width + 5
    property int tooltipY: (button.height/2 - implicitHeight/2)
    Accessible.role: Accessible.Button
    Accessible.name: text
    highlighted: false
    display: AbstractButton.IconOnly

    ToolTip{
        visible: button.hovered
        text: button.text
        x: button.tooltipX
        y: button.tooltipY
    }
}
