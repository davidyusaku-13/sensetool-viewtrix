import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: myButton

    property string customColor: "#d6d6d6"
    property string customHoveredColor: "#ffffff"

    property string customImage:"images/menu-icon2.png"

    property int customIconWidth: 150
    property int customIconHeight: 150

    property int customRadius: 10

    x: 500
    y: 500

    width: 500
    height: 200

    Image {
        id: menuicon

        width: 150
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.topMargin: 20
        anchors.bottomMargin: 20


        source: customImage
        fillMode: Image.PreserveAspectFit
    }

    background: Rectangle{
        width: parent.width
        height: parent.height

        color: parent.down ? customColor :
        (parent.hovered ? customHoveredColor : customColor)

        radius:customRadius
    }
}
