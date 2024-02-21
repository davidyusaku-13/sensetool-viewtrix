import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects


Item {
    id: root
    width: 1000
    height: 50

    property string customItemColor: "#ffffff"
    property string customItemName: "dbchjcdhbsfhcsdfu"
    property int customNameSize: 15

    //check box
    Button{

        id: checkBox
        x: 8

        width: 20
        height: 20

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 15

        background: Rectangle{
            anchors.fill: parent
            color: "#ffffff"
        }

        //check list icon
        Image{
            id: checklistIcon
            width: parent.width
            height: width
            source: "images/checklist"
            visible: false
        }

        HoverHandler {
            id: checklistPointer
            acceptedDevices: PointerDevice.Mouse
            cursorShape: Qt.PointingHandCursor
        }

        onClicked: {
            if(checklistIcon.visible === false){
                checklistIcon.visible = true
            }else{
                checklistIcon.visible = false
            }
        }
    }

    //check box shadow
    InnerShadow {
        anchors.fill: root
        cached: true
        horizontalOffset: 0
        verticalOffset: 0
        radius: 6
        samples: 48
        color: "#b0000000"
        smooth: true
        source: root
    }

    //item box
    Rectangle{
        id: itemBox
        x: checkBox.width+(checkBox.anchors.leftMargin*2)

        width: root.width-(x*2)
        height: 50

        anchors.verticalCenter: parent.verticalCenter

        color: customItemColor

        layer.enabled: true
        layer.effect: DropShadow{
            radius: 2
        }

        MyText {
            anchors.fill: parent
            customSize: customNameSize
            customText: customItemName
            customFont: "Montserrat"
            customRadius: 0
        }
    }

    //drag icon
    Image{
        width: checkBox.width
        height: checkBox.height

        anchors.left: parent.left
        anchors.leftMargin: itemBox.x+itemBox.width+checkBox.anchors.leftMargin
        anchors.verticalCenter: parent.verticalCenter
        source: "images/drag"

        HoverHandler {
            id: dragPointer
            acceptedDevices: PointerDevice.Mouse
            cursorShape: Qt.OpenHandCursor
        }
    }
}


