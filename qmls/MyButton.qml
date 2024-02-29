import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Button {
    id: myButton
    width: 50
    height: 50

    //property
    property string customColor: "#d6d6d6"
    property string customHoveredColor: "#ffffff"

    property string customImage:"images/menu-icon2.png"

    property int customIconWidth: myButton.width-10
    property int customIconHeight: myButton.height-10

    property int customRadius: 5

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
        color: parent.down ? customColor :
                             parent.hovered ? customHoveredColor : customColor

        radius:customRadius
    }
}
