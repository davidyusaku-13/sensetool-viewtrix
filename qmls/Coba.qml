import QtQuick
import QtQuick.Controls
import PrjSetModel
import AppLogic

Rectangle {
        anchors.fill: parent

        DelegateModel {
            id: visualModel
            model: ListModel {
                ListElement { setitem: "GUI_ENABLE"; val: ""; desc: "Used for enable the gui feature (DEBUG USE)" }
                ListElement { setitem: "OS_EVENT_QUEUE" }
                ListElement { setitem: "OS_MSG_LEN_QUEUE" }
                ListElement { setitem: "OS_UART_LEN_QUEUE" }
                ListElement { setitem: "EVT_FIFO_DEEP_MAX" }
                ListElement { setitem: "EVT_FIFO_LEN_MAX" }
                ListElement { setitem: "CMD_FIFO_DEEP_MAX" }
                ListElement { setitem: "CMD_FIFO_LEN_MAX" }
            }

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
    }