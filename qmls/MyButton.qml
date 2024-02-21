import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Button {
    id: myButton

    property string customColor: "#d6d6d6"
    property string customHoveredColor: "#ffffff"

    property string customImage:"images/menu-icon2.png"

    property int customIconWidth: width-12
    property int customIconHeight: height-12

    property int customRadius: 10

    x: 500
    y: 500

    width: 35
    height: 35

    Image {
        id: menuIcon

        width: customIconHeight
        height: customIconHeight

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        source: customImage
        fillMode: Image.PreserveAspectFit
    }

    background: Rectangle{
        width: parent.width
        height: parent.height

        color: parent.down ? customColor :
        parent.hovered ? customHoveredColor : customColor

        radius:customRadius
    }
}
