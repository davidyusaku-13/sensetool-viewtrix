import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs

Item{
    Layout.fillHeight: true
    Layout.fillWidth: true
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
            implicitHeight: 25
            ToolbarBtn{
                text: "Import"
                onClicked: {
                    dialogImport.open()
                }
            }
            FileDialog {
                id: dialogImport
                selectedNameFilter.index: 1
                fileMode: FileDialog.OpenFile
                nameFilters: ["YAML files (*.yaml *.yml)"]
                onAccepted: {
                    window.manager.importYAML(selectedFile)
                    window.manager.addHistory("Imported", selectedFile)
                }
            }
            ToolbarBtn{
                text: "Export"
                onClicked: {
                    dialogExport.open()
                }
            }
            FileDialog {
                id: dialogExport
                selectedNameFilter.index: 1
                fileMode: FileDialog.SaveFile
                nameFilters: ["YAML files (*.yaml *.yml)"]
                onAccepted: {
                    window.manager.exportYAML(selectedFile)
                    window.manager.addHistory("Exported", selectedFile)
                }
            }
            ToolbarBtn{
                text: "Add"
                onClicked: {
                    prjSetWindow.manage(-1,null)
                }
            }
            ToolbarBtn{
                text: "Edit"
                enabled: selectedGroup.count === 1
                onClicked: {
                    if(selectedGroup.count === 1){
                        var selected = selectedGroup.get(0)
                        prjSetWindow.manage(selected.itemsIndex, selected.model)
                    }
                }
            }
            ToolbarBtn{
                text: "Delete"
                enabled: selectedGroup.count > 0
                onClicked: {
                    for(let i = selectedGroup.count-1; i>=0; i--){
                        let itemSelected = selectedGroup.get(i)
                        // var object = itemList.get(itemSelected.itemsIndex)
                        // layout.history("Deleted", object)
                        // itemList.remove(itemSelected.itemsIndex)
                        var object = window.manager.prjSetModel.get(itemSelected.itemsIndex)
                        window.manager.addHistory("Deleted", object.name, object.value, object.desc)
                        window.manager.prjSetModel.removeItem(itemSelected.itemsIndex)
                    }
                }
            }
            Item{
                Layout.fillWidth: true
            }
            ToolbarBtn{
                text: "Select All"
                onClicked: {
                    for(var i=0; i< itemModel.items.count; i++){
                        if(!itemModel.items.get(i).inSelected){
                            itemModel.items.get(i).inSelected = true
                        }
                    }
                }
            }
            ToolbarBtn{
                text: "Deselect All"
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
                onCreate: (object) => {
                              //   itemList.append(object);
                              //   layout.history("Added", object)
                              window.manager.add(object.name, object.value, object.desc)
                              window.manager.addHistory("Added", object.name, object.value, object.desc)
                          }
                onModify: (index, object) => {
                              //   itemList.set(index, object);
                              //   layout.history("Modified", object)
                              let i = selectedGroup.get(0).itemsIndex
                              window.manager.edit(root.i, object.name, object.value, object.desc)
                              window.manager.addHistory("Modified", object.name, object.value, object.desc)
                          }
            }
        }
        //project set rect
        ShadowRect{
            id: prjSetContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"
            ListView{
                anchors.fill: parent
                interactive: true
                clip: true
                //header
                headerPositioning: ListView.OverlayHeader
                header: RowLayout{
                    id: workspace1Header
                    width: parent.width
                    height: 50
                    spacing: 0
                    z: 2
                    Rectangle{
                        implicitWidth: 50
                        Layout.fillHeight: true
                        color: "#d6d6d6"
                    }
                    Repeater{
                        model: ["Item", "Value", "Description"]
                        Rectangle{
                            required property string modelData
                            Layout.fillHeight: true
                            Layout.fillWidth: modelData === "Description" ? false : true
                            implicitWidth: modelData === "Description" ? parent.width*3/7 : 0
                            color: "#d6d6d6"
                            Text {
                                text: parent.modelData
                                anchors.centerIn: parent
                                font.pointSize: 15
                                font.family: "Montserrat SemiBold"
                            }
                        }
                    }
                    Rectangle{
                        implicitWidth: 50
                        Layout.fillHeight: true
                        color: "#d6d6d6"
                    }
                }
                //item list
                model: DelegateModel{
                    id: itemModel
                    // model: ListModel{
                    //     id: itemList
                    // }
                    model: window.manager.prjSetModel
                    groups: [
                        DelegateModelGroup {
                            id: selectedGroup
                            name: "selected"}
                    ]
                    // delegate: MyItem{
                    //     id: itemDel
                    //     required property var model
                    //     customItem: model.name
                    //     customValue: model.value
                    //     customDesc: model.desc
                    //     width: ListView.view.width
                    //     color: itemDel.DelegateModel.inSelected ? "lightsteelblue" : "transparent"
                    //     // status: itemDel.DelegateModel.inSelected
                    //     onSelected: {
                    //         itemDel.DelegateModel.inSelected = !itemDel.DelegateModel.inSelected
                    //     }
                    // }
                    delegate: dragDelegate
                }
                //footer
                footerPositioning: ListView.OverlayFooter
                footer: Rectangle{
                    id: workspace1Footer
                    width: parent.width
                    height: 35
                    color: "#d6d6d6"
                    z: 2
                    Text{
                        anchors.centerIn: parent
                        text: selectedGroup.count + " of " + itemModel.count + " selected"
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
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
                        color: itemDel.dragArea.held ? "#d6d6d6": "white"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        radius: 2
                        MyItem{
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
                            height: 50
                            width: parent.width
                            customItem: model.name
                            customValue: model.value
                            customDesc: model.desc
                            content: itemDel
                            checkBox.checked: DelegateModel.inSelected
                            color: checkBox.checked ? "lightsteelblue": "transparent"
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                        DropArea {
                            anchors.fill: parent
                            onEntered: (drag) => {window.manager.moveItem(drag.source.index, content.index)}
                        }
                    }
                }
            }
        }
    }
}