import QtQuick
import QtQuick.Controls
import PrjSetModel
import AppLogic

ApplicationWindow {
    id: root
    title: qsTr("Viewtrix")

    property int w: 1280
    property int h: 720
    property AppManager manager: AppManager{
        prjSetModel: PrjSetModel{}
        logic: AppLogic{}
    }

    visible: true
    width: root.w
    height: root.h

    // SenseTrix{
    //     anchors.fill: parent
    // }

    Rectangle{
        id: rect
        anchors.fill: parent
        color: "#fff"
        
        DelegateModel {
            id: visualModel
            model: root.manager.prjSetModel

            groups: [
                DelegateModelGroup { name: "selected" }
            ]

            delegate: Rectangle {
                id: item
                height: 25
                width: parent.width
                color: "#ff0"
                Text {
                    text: {
                        var text = "Item: " + setitem + " | " + val + " | " + desc
                        if (item.DelegateModel.inSelected){
                            text += " (" + item.DelegateModel.itemsIndex + ")"
                        }
                        return text;
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        item.DelegateModel.inSelected = !item.DelegateModel.inSelected
                    }
                }
            }
        }

        ListView {
            anchors.fill: parent
            model: visualModel
        }

        // Button{
        //     id: btnAdd
        //     text: "Add"
        //     anchors.top: parent.top
        //     anchors.topMargin: 10
        //     anchors.left: parent.left
        //     anchors.leftMargin: 10

        //     onClicked: {
        //         root.manager.add("OS_EVENT_QUE", "8", "Queue deep value")
        //     }
        // }
    }
}