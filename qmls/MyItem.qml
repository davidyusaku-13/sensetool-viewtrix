import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property string customItemColor: "#ffffff"
    property string customItemName: "dbchjcdhbsfhcsdfu"
    property int customItemSize: 15
    property int customWidth: 1000
    property int customHeight: 50

    // property bool selectState: false

    width: customWidth
    height: customHeight

    //check box
    Button{
        id: checkBox

        width: parent.height-30
        height: parent.height-30

        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.verticalCenter: parent.verticalCenter

        background: Rectangle{
            anchors.fill: parent
            color: "#ffffff"
            radius: 5
            border.color: "#b3b3b3"
            border.width: 1

            // layer.enabled: true
            // layer.effect: InnerShadow{
            //     horizontalOffset: 0
            //     verticalOffset: 0
            //     radius: 6
            //     samples: 6
            //     color: "#b0000000"
            // }
        }

        //check list rectangle
        Rectangle{
            id: checklistIcon
            width: parent.width
            height: width
            color: "#000000"
            radius: parent.background.radius
            visible: false
        }

        //check list icon
        // Image{
        //     id: checklistIcon
        //     width: parent.width
        //     height: width
        //     source: "images/checklist"
        //     visible: true
        // }

        onClicked: {
            // if(checklistIcon.visible === false){
            //     checklistIcon.visible = true
            // }else{
            //     checklistIcon.visible = false
            // }

            // if(checklistIcon.visible === false){
            //     checklistIcon.visible = true
            //     selectState = true
            //     listItem.DelegateModel.inSelected
            //     window.manager.editState(listItem.DelegateModel.itemsIndex, "true")
            // }else{
            //     checklistIcon.visible = false
            //     selectState = false
            //     !listItem.DelegateModel.inSelected
            //     window.manager.editState(listItem.DelegateModel.itemsIndex, "false")
            // }

            // if(listItem.selectState==="true"){
            //     checklistIcon.visible = true
            //     selectState = true
            //     listItem.DelegateModel.inSelected
            //     window.manager.editState(listItem.DelegateModel.itemsIndex, "true")
            // } else {
            //     checklistIcon.visible = false
            //     selectState = false
            //     !listItem.DelegateModel.inSelected
            //     window.manager.editState(listItem.DelegateModel.itemsIndex, "false")
            // }

            // print(visualModel.model.get(listItem.DelegateModel.itemsIndex).selectState)

            if(visualModel.model.get(listItem.DelegateModel.itemsIndex).selectState === "false"){
                checklistIcon.visible = true
                selectState = true
                listItem.DelegateModel.inSelected
                window.manager.editState(listItem.DelegateModel.itemsIndex, "true")
            } else {
                checklistIcon.visible = false
                selectState = false
                !listItem.DelegateModel.inSelected
                window.manager.editState(listItem.DelegateModel.itemsIndex, "false")
            }
        }

        HoverHandler {
            id: checklistPointer
            acceptedDevices: PointerDevice.Mouse
            cursorShape: Qt.PointingHandCursor
        }
    }

    //check box shadow
    // InnerShadow {
    //     anchors.fill: checkBox
    //     cached: true
    //     horizontalOffset: 1
    //     verticalOffset: 1
    //     radius: 6
    //     samples: 48
    //     color: "#b0000000"
    //     smooth: true
    //     source: checkBox
    // }

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
            customSize: customItemSize
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


