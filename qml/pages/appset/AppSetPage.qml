import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

// Application Setting workspace: replaces the AppSet sheet of prjcfg.xlsx.
ShadowRect{
    id: page
    Layout.fillHeight: true
    Layout.fillWidth: true

    function showMessage(message){
        if(message !== ""){
            messageDialog.text = message
            messageDialog.open()
            return true
        }
        return false
    }
    function selectedIndexes(){
        let out = []
        for(let i=0; i<selectedGroup.count; i++) out.push(selectedGroup.get(i).itemsIndex)
        return out
    }
    MessageDialog {
        id: messageDialog
        title: qsTr("Application Setting")
        buttons: MessageDialog.Ok
    }
    FileDialog {
        id: dialogImport
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Application setting (*.yaml *.yml *.xlsx)"), qsTr("YAML files (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
        onAccepted: {
            if(!page.showMessage(window.appSetModel.importFile(selectedFile)))
                window.historyModel.addHistory("Imported", selectedFile, "", "")
        }
    }
    FileDialog {
        id: dialogExport
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: {
            if(!page.showMessage(window.appSetModel.exportYAML(selectedFile)))
                window.historyModel.addHistory("Exported", selectedFile, "", "")
        }
    }
    FolderDialog {
        id: dialogGenerate
        title: qsTr("Folder for appset.c and appset.h")
        onAccepted: {
            if(!page.showMessage(window.appSetModel.generate(selectedFolder)))
                window.historyModel.addHistory("Generated", selectedFolder + "/appset.c, appset.h", "", "")
        }
    }
    AppSetWindow{
        id: regWindow
        Material.theme: sensetool.theme
        model: window.appSetModel
        onCreate: (reg) => {
                      window.appSetModel.addRegister(reg)
                      window.historyModel.addHistory("Added", reg.name, reg.addr, reg.desc)
                  }
        onModify: (index, reg) => {
                      window.appSetModel.editRegister(index, reg)
                      window.historyModel.addHistory("Modified", reg.name, reg.addr, reg.desc)
                  }
    }
    MouseArea{
        anchors.fill: parent
        onClicked: sidebar.folded = true
    }
    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        //toolbar
        RowLayout{
            Layout.fillWidth: true
            ToolbarBtn{ text: qsTr("Import"); onClicked: dialogImport.open() }
            ToolbarBtn{ text: qsTr("Export"); onClicked: dialogExport.open() }
            ToolbarBtn{
                text: qsTr("Generate appset.c/.h")
                onClicked: {
                    if(window.appSetModel.issueCount > 0)
                        page.showMessage(qsTr("%1 register(s) have problems (shown in red). Fix them before generating.").arg(window.appSetModel.issueCount))
                    else
                        dialogGenerate.open()
                }
            }
            ToolbarBtn{ text: qsTr("Add"); onClicked: regWindow.manage(-1, null) }
            ToolbarBtn{
                text: qsTr("Edit")
                enabled: selectedGroup.count === 1
                onClicked: {
                    let i = selectedGroup.get(0).itemsIndex
                    regWindow.manage(i, window.appSetModel.get(i))
                }
            }
            ToolbarBtn{
                text: qsTr("Delete")
                enabled: selectedGroup.count > 0
                onClicked: {
                    for(let i of page.selectedIndexes()){
                        let r = window.appSetModel.get(i)
                        window.historyModel.addHistory("Deleted", r.name, r.addr, r.desc)
                    }
                    window.appSetModel.removeItems(page.selectedIndexes())
                }
            }
            Item{ Layout.fillWidth: true }
            ToolbarBtn{
                text: qsTr("Select All")
                onClicked: { for(let i=0; i<itemModel.items.count; i++) itemModel.items.get(i).inSelected = true }
            }
            ToolbarBtn{
                text: qsTr("Deselect All")
                onClicked: { for(let i=0; i<itemModel.items.count; i++) itemModel.items.get(i).inSelected = false }
            }
        }
        ShadowRect{
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView{
                id: list
                anchors.fill: parent
                clip: true
                headerPositioning: ListView.OverlayHeader
                header: RowLayout{
                    width: ListView.view.width
                    height: 35
                    spacing: 0
                    z: 2
                    Repeater{
                        // label, fixed width (0 = fill, <1 = fraction of the row)
                        model: [["", 40], ["Addr", 70], ["Name", 0.17], ["Size", 50], ["Bit fields", 0],
                                ["Default", 80], ["Description", 0.25]]
                        Rectangle{
                            required property var modelData
                            Layout.fillHeight: true
                            Layout.fillWidth: modelData[1] === 0
                            Layout.preferredWidth: modelData[1] < 1 ? list.width * modelData[1] : modelData[1]
                            color: Material.accent
                            Text{
                                text: parent.modelData[0]
                                anchors.centerIn: parent
                                font.pointSize: 12
                                font.family: "Montserrat SemiBold"
                                color: Material.foreground
                            }
                        }
                    }
                }
                model: DelegateModel{
                    id: itemModel
                    model: window.appSetModel
                    groups: [ DelegateModelGroup { id: selectedGroup; name: "selected" } ]
                    delegate: AppSetItem{
                        id: row
                        required property var model
                        width: ListView.view.width
                        addrHex: model.addrHex
                        name: model.name
                        size: model.size
                        layout: model.layout
                        defaultValue: model.defaultValue
                        desc: model.desc
                        category: model.category
                        issue: model.issue
                        checkBox.checked: row.DelegateModel.inSelected
                        onSelected: row.DelegateModel.inSelected = !row.DelegateModel.inSelected
                    }
                }
                footerPositioning: ListView.OverlayFooter
                footer: ShadowRect{
                    width: ListView.view.width
                    height: 35
                    color: Material.accent
                    z: 2
                    Text{
                        anchors.centerIn: parent
                        text: selectedGroup.count + qsTr(" of ") + itemModel.count + qsTr(" selected")
                              + (window.appSetModel ? qsTr("  •  %1 / %2 bytes used").arg(window.appSetModel.bytesUsed).arg(window.appSetModel.tableSize()) : "")
                              + (window.appSetModel && window.appSetModel.issueCount > 0 ? qsTr("  •  %1 with problems").arg(window.appSetModel.issueCount) : "")
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
                        color: Material.foreground
                    }
                }
            }
        }
    }
}
