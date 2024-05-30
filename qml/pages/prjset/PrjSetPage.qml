import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

//project set workspace
Item{
    id: layout
    Layout.fillHeight: true
    Layout.fillWidth: true
    function history(status, object){
        var temp = {
            "status": status,
            "name": object["name"],
            "value": object["value"],
            "desc": object["desc"]
        }
        historyList.append(temp)
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
            //implicitHeight: 25
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
                        var object = itemList.get(itemSelected.itemsIndex)
                        layout.history("Deleted", object)
                        itemList.remove(itemSelected.itemsIndex)
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
                              itemList.append(object);
                              layout.history("Added", object)
                          }
                onModify: (index, object) => {
                              itemList.set(index, object);
                              layout.history("Modified", object)
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
                //header
                headerPositioning: ListView.OverlayHeader
                header: RowLayout{
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
                //item list
                model: DelegateModel{
                    id: itemModel
                    model: ListModel{
                        id: itemList
                    }
                    groups: [
                        DelegateModelGroup {
                            id: selectedGroup
                            name: "selected"}
                    ]
                    delegate: PrjSetItem{
                        id: itemDel
                        required property var model
                        name: model.name
                        value: model.value
                        desc: model.desc
                        width: ListView.view.width
                        checkBox.checked: DelegateModel.inSelected
                        onSelected: {
                            DelegateModel.inSelected = !DelegateModel.inSelected
                        }
                    }
                }
                //footer
                footerPositioning: ListView.OverlayFooter
                footer: ShadowRect{
                    width: parent.width
                    height: 35
                    color: Material.accent
                    z: 2
                    Text{
                        anchors.centerIn: parent
                        text: selectedGroup.count + " of " + itemModel.count + " selected"
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
                        color: Material.foreground
                    }
                }
            }
        }
    }
}
