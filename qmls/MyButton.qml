import QtQuick
import QtQuick.Controls

Button {
    id: root
    width: 50
    height: 50
    
    //property
    property string customColor: "#d6d6d6"
    property string customHoveredColor: "#ffffff"
    
    property string customImage: "images/menu-icon2.png"
    
    property int customIconWidth: root.width-13
    property int customIconHeight: root.height-13
    
    property int customRadius: 5
    
    Image {
        id: menuIcon
        
        width: root.customIconHeight
        height: root.customIconHeight
        
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        
        source: root.customImage
        fillMode: Image.PreserveAspectFit
    }
    
    background: Rectangle{
        color: parent.down ? customColor : parent.hovered ? customHoveredColor : customColor
        Behavior on color { ColorAnimation { duration: 100 } }
        
        radius: root.customRadius
    }
}
