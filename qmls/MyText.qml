import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: button
    x: 0
    y: 0

    width: 150
    height: 50

    property string customText: "menu 1"
    property string customFont: "Montserrat Medium"
    property int customSize: 20
    property string customHAlignment: "Left"

    property string customColor: "#ffffff"
    property string customHoveredColor: "#e1e1e1"

    property int customRadius: 10

    Text {
        id: myText

        text: customText
        font.pixelSize: customSize
        font.family: customFont

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: (customHAlignment === "Left") ? Text.AlignLeft :
        (customHAlignment === "Center") ? Text.AlignHCenter : (customHAlignment === "Right") ?
        Text.AlignRight : (customHAlignment === "Justify") ? Text.AlignJustify : Text.AlignLeft

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
    }

    background: Rectangle{
        anchors.fill: parent
        color: parent.down? customColor: (parent.hovered ? customHoveredColor : customColor)

        radius: customRadius
    }
}



