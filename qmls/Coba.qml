import QtQuick
import QtQuick.Controls
import PrjSetModel
import AppLogic

Rectangle {
    anchors.fill: parent

    required property PrjSetModel prjSetModel

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
