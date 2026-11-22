import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

//project set workspace
ShadowRect{
    id: layout
    Layout.fillHeight: true
    Layout.fillWidth: true

    function showError(message){
        if(message !== ""){
            errorDialog.text = message
            errorDialog.open()
            return true
        }
        return false
    }
    MessageDialog {
        id: errorDialog
        title: qsTr("Project Setting")
        buttons: MessageDialog.Ok
    }
    MouseArea{
        anchors.fill: parent
        onClicked:{
            sidebar.folded = true
        }
    }
    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        //toolbar
        RowLayout{
            Layout.fillWidth: true
            ToolbarBtn{
                text: qsTr("Import")
                onClicked: {
                    dialogImport.open()
                }
            }
            FileDialog {
                id: dialogImport
                fileMode: FileDialog.OpenFile
                nameFilters: [qsTr("Project setting (*.yaml *.yml *.xlsx)"), qsTr("YAML files (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
                onAccepted: {
                    if(!layout.showError(window.prjSetModel.importFile(selectedFile)))
                        window.historyModel.addHistory("Imported", selectedFile, "", "")
                }
            }
            ToolbarBtn{
                text: qsTr("Export")
                onClicked: {
                    dialogExport.open()
                }
            }
            FileDialog {
                id: dialogExport
                fileMode: FileDialog.SaveFile
                defaultSuffix: "yaml"
                nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
                onAccepted: {
                    if(!layout.showError(window.prjSetModel.exportYAML(selectedFile)))
                        window.historyModel.addHistory("Exported", selectedFile, "", "")
                }
            }
            ToolbarBtn{
                text: qsTr("Generate prjset.h")
                onClicked: {
                    if(window.prjSetModel.issueCount > 0){
                        layout.showError(qsTr("%1 item(s) have problems (shown in red). Fix them before generating the header.").arg(window.prjSetModel.issueCount))
                    } else {
                        dialogHeader.open()
                    }
                }
            }
            FileDialog {
                id: dialogHeader
                fileMode: FileDialog.SaveFile
                defaultSuffix: "h"
                nameFilters: [qsTr("C header (*.h)")]
                onAccepted: {
                    if(!layout.showError(window.prjSetModel.exportHeader(selectedFile)))
                        window.historyModel.addHistory("Generated", selectedFile, "", "")
                }
            }
            ToolbarBtn{
                text: qsTr("Add")
                onClicked: {
                    prjSetWindow.manage(-1,null)
                }
            }
            ToolbarBtn{
                text: qsTr("Edit")
                enabled: selectedGroup.count === 1
                onClicked: {
                    if(selectedGroup.count === 1){
                        var selected = selectedGroup.get(0)
                        prjSetWindow.manage(selected.itemsIndex, selected.model)
                    }
                }
            }
            ToolbarBtn{
                text: qsTr("Delete")
                enabled: selectedGroup.count > 0
                onClicked: {
                    for(let i = selectedGroup.count-1; i>=0; i--){
                        let itemSelected = selectedGroup.get(i)
                        var object = itemSelected.model
                        window.historyModel.addHistory("Deleted", object.name, object.value, object.desc)
                        window.prjSetModel.removeItem(itemSelected.itemsIndex)
                    }
                }
            }
            Item{
                Layout.fillWidth: true
            }
            ToolbarBtn{
                text: qsTr("Select All")
                onClicked: {
                    for(var i=0; i< itemModel.items.count; i++){
                        if(!itemModel.items.get(i).inSelected){
                            itemModel.items.get(i).inSelected = true
                        }
                    }
                }
            }
            ToolbarBtn{
                text: qsTr("Deselect All")
                onClicked: {
                    for(var i=0; i< itemModel.items.count; i++){
                        if(itemModel.items.get(i).inSelected){
                            itemModel.items.get(i).inSelected = false
                        }
                    }
                }
            }
            PrjSetWindow{
                id: prjSetWindow
                Material.theme: sensetool.theme
                model: window.prjSetModel
                onCreate: (object) => {
                              window.prjSetModel.addItem(object.name, object.value, object.desc, object.group, object.comment)
                              window.historyModel.addHistory("Added", object.name, object.value, object.desc)
                          }
                onModify: (index, object) => {
                              // Use the index the window was opened for, not the current selection.
                              window.prjSetModel.edit(index, object.name, object.value, object.desc, object.group, object.comment)
                              window.historyModel.addHistory("Modified", object.name, object.value, object.desc)
                          }
            }
        }
        //project set rect
        ShadowRect{
            id: prjSetContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView{
                anchors.fill: parent
                interactive: true
                clip: true
                highlightMoveDuration: 1000
                //header
                headerPositioning: ListView.OverlayHeader
                header: RowLayout{
                    id: workspace1Header
                    width: parent.width
                    height: 35
                    spacing: 0
                    z: 2
                    Rectangle{
                        implicitWidth: 50
                        Layout.fillHeight: true
                        color: Material.accent
                    }
                    Repeater{
                        model: ["Item", "Value", "Description"]
                        Rectangle{
                            required property string modelData
                            Layout.fillHeight: true
                            Layout.fillWidth: modelData === "Description" ? false : true
                            implicitWidth: modelData === "Description" ? parent.width*3/7 : 0
                            color: Material.accent
                            Text {
                                text: parent.modelData
                                anchors.centerIn: parent
                                font.pointSize: 12
                                font.family: "Montserrat SemiBold"
                                color: Material.foreground
                            }
                        }
                    }
                    Rectangle{
                        implicitWidth: 50
                        Layout.fillHeight: true
                        color: Material.accent
                    }
                }
                //sections from the item's group
                section.property: "group"
                section.criteria: ViewSection.FullString
                section.delegate: Rectangle{
                    required property string section
                    width: ListView.view.width
                    height: section === "" ? 0 : 30
                    visible: section !== ""
                    color: Material.background
                    Text{
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: parent.section
                        font.pointSize: 11
                        font.family: "Montserrat SemiBold"
                        color: Material.accent
                    }
                }
                //item list
                model: DelegateModel{
                    id: itemModel
                    model: window.prjSetModel
                    groups: [
                        DelegateModelGroup {
                            id: selectedGroup
                            name: "selected"}
                    ]
                    delegate: dragDelegate
                }
                //footer
                footerPositioning: ListView.OverlayFooter
                footer: ShadowRect{
                    id: workspace1Footer
                    width: parent.width
                    height: 35
                    color: Material.accent
                    z: 2
                    Text{
                        anchors.centerIn: parent
                        text: selectedGroup.count + qsTr(" of ") + itemModel.count + qsTr(" selected")
                              + (window.prjSetModel.issueCount > 0 ? qsTr("  •  %1 with problems").arg(window.prjSetModel.issueCount) : "")
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
                        color: Material.foreground
                    }
                }
                Component {
                    id: dragDelegate
                    Rectangle {
                        id: content
                        required property var model
                        required property int index
                        width: ListView.view.width
                        height: itemDel.height
                        color: itemDel.dragArea.held ? Material.foreground : Material.background
                        Behavior on color { ColorAnimation { duration: 100 } }
                        radius: 2
                        PrjSetItem{
                            id: itemDel
                            states: State {
                                when: itemDel.dragArea.pressed
                                ParentChange {
                                    target: itemDel
                                    parent: content.ListView.view
                                }
                            }
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2
                            Drag.source: content
                            Drag.active: itemDel.dragArea.pressed
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                            width: parent.width
                            name: model.name
                            value: model.value
                            desc: model.desc
                            comment: model.comment
                            resolved: model.resolved
                            issue: model.issue
                            content: itemDel
                            checkBox.checked: DelegateModel.inSelected
                            onSelected: {
                                DelegateModel.inSelected = !DelegateModel.inSelected
                            }
                        }
                        DropArea {
                            anchors.fill: parent
                            onEntered: (drag) => {window.prjSetModel.move(drag.source.index, content.index)}
                        }
                    }
                }
            }
        }
    }
}
