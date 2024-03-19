import QtQuick
import QtQuick.Controls
import PrjSetModel
import AppLogic

ApplicationWindow {
    id: window
    title: qsTr("Viewtrix")

    property int w: 1280
    property int h: 400
    property AppManager manager: AppManager{
        prjSetModel: PrjSetModel{}
        logic: AppLogic{}
    }

    visible: true
    width: window.w
    height: window.h

    SenseTrix{
        anchors.fill: parent
    }

    // Rectangle {
    //     anchors.fill: parent

    //     DelegateModel {
    //         id: visualModel
    //         model: ListModel {
    //             ListElement { setitem: "GUI_ENABLE" }
    //             ListElement { setitem: "OS_EVENT_QUEUE" }
    //             ListElement { setitem: "OS_MSG_LEN_QUEUE" }
    //             ListElement { setitem: "OS_UART_LEN_QUEUE" }
    //             ListElement { setitem: "EVT_FIFO_DEEP_MAX" }
    //             ListElement { setitem: "EVT_FIFO_LEN_MAX" }
    //             ListElement { setitem: "CMD_FIFO_DEEP_MAX" }
    //             ListElement { setitem: "CMD_FIFO_LEN_MAX" }
    //         }

    //        groups: [
    //            DelegateModelGroup { name: "selected" }
    //        ]

    //         delegate: Rectangle {
    //             id: item
    //             height: 25
    //             width: 200
    //             Text {
    //                 text: {
    //                     var text = "Item: " + setitem
    //                     if (item.DelegateModel.inSelected){
    //                         text += " (" + item.DelegateModel.itemsIndex + ")"
    //                         print(setitem)
    //                     }
    //                     return text;
    //                 }
    //             }
    //             MouseArea {
    //                 anchors.fill: parent
    //                 onClicked: item.DelegateModel.inSelected = !item.DelegateModel.inSelected
    //             }
    //         }
    //     }

    //     ListView {
    //         anchors.fill: parent
    //         model: visualModel
    //     }
    // }
}