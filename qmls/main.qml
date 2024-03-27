import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import PrjSetModel
import AppLogic

ApplicationWindow {
    id: window

    title: qsTr("Viewtrix")
    visible: true
    width: 1280
    height: 400

    property AppManager manager: AppManager{prjSetModel: PrjSetModel { }}

    SenseTrix{
        anchors.fill: parent
    }

    // Rectangle {
    //     anchors.fill: parent

    //     DelegateModel {
    //         id: visualModel

    //         model: window.manager.prjSetModel

    //         groups: [
    //             DelegateModelGroup {
    //                 name: "selected"
    //             }
    //         ]

    //         delegate: Rectangle {
    //             id: item
    //             width: parent.width
    //             height: 20
    //             Text {
    //                 text: {
    //                     var text = "Item: " + name + " | " + "Value: " + value + " | " + "Desc: " + desc
    //                     if (item.DelegateModel.inSelected)
    //                     {
    //                         text += " (" + item.DelegateModel.itemsIndex + ")"
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
    //         id: lv
    //         width: parent.width
    //         height: 300
    //         model: visualModel
    //     }

    //     Button{
    //         id: addBtn
    //         anchors.top: lv.bottom
    //         text: "Add"
    //         width: 120
    //         height: width/3

    //         onClicked: {
    //             window.manager.add("GUI_ENABLE", "", "Used for enable the gui feature (DEBUG USE)", false)
    //         }
    //     }

    //     Button{
    //         anchors.top: addBtn.bottom
    //         text: "Export"
    //         width: 120
    //         height: width/3

    //         onClicked: {
    //             window.manager.exportYAML()
    //         }
    //     }

    //     Button {
    //         text: qsTr("Choose File...")
    //         onClicked: fileDialog.open()
    //     }
    //     FileDialog {
    //         id: fileDialog
    //         selectedNameFilter.index: 1
    //         nameFilters: ["YAML files (*.yaml *.yml)"]
    //         onAccepted: {
    //             window.manager.importYAML(selectedFile)
    //         }
    //     }
    // }
}