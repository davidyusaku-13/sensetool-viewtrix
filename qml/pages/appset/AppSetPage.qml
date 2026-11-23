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
    function addItem(){ regWindow.manage(-1, null) }
    function editSelected(){
        if(selectedGroup.count !== 1) return
        let i = selectedGroup.get(0).itemsIndex
        regWindow.manage(i, window.appSetModel.get(i))
    }
    function deleteSelected(){
        let rows = page.selectedIndexes()
        if(rows.length === 0) return
        confirmDelete.ask(qsTr("Delete %1 register(s)?").arg(rows.length), () => {
            for(let i of rows){
                let r = window.appSetModel.get(i)
                window.historyModel.addHistory("Deleted", r.name, r.addr, r.desc)
            }
            window.appSetModel.removeItems(rows)
        })
    }
    function generate(){
        if(window.appSetModel.issueCount > 0)
            page.showMessage(qsTr("%1 register(s) have problems (shown in red). Fix them before generating.").arg(window.appSetModel.issueCount))
        else
            dialogGenerate.open()
    }
    Shortcut{ sequences: [StandardKey.New]; enabled: page.visible; onActivated: page.addItem() }
    Shortcut{ sequences: ["Ctrl+G"]; enabled: page.visible; onActivated: page.generate() }
    Shortcut{ sequences: [StandardKey.SelectAll]; enabled: page.visible; onActivated: selectAll.setAll(selectAll.checkState !== Qt.Checked) }
    Shortcut{ sequences: [StandardKey.Delete]; enabled: page.visible && selectedGroup.count > 0; onActivated: page.deleteSelected() }
    Shortcut{ sequences: ["Return", "Enter", "F2"]; enabled: page.visible && selectedGroup.count === 1; onActivated: page.editSelected() }
    ConfirmDialog{ id: confirmDelete; title: qsTr("Application Setting") }
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
        Material.accent: sensetool.accent
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
        Flow{
            Layout.fillWidth: true
            spacing: 6
            ToolbarBtn{ text: qsTr("Import"); ToolTip.text: qsTr("Replace the table with an app-setting YAML or the AppSet sheet"); onClicked: dialogImport.open() }
            ToolbarBtn{ text: qsTr("Export"); ToolTip.text: qsTr("Save only the app settings as YAML"); onClicked: dialogExport.open() }
            ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Add a register (Ctrl+N)"); onClicked: page.addItem() }
            ToolbarBtn{ text: qsTr("Edit"); ToolTip.text: qsTr("Edit (Enter, or double-click a row)"); enabled: selectedGroup.count === 1; onClicked: page.editSelected() }
            ToolbarBtn{ text: qsTr("Delete"); ToolTip.text: qsTr("Delete (Del)"); enabled: selectedGroup.count > 0; onClicked: page.deleteSelected() }
            ToolbarBtn{ text: qsTr("Generate appset.c/.h"); ToolTip.text: qsTr("Write the C files (Ctrl+G)"); primary: true; onClicked: page.generate() }
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
                    Rectangle{
                        Layout.preferredWidth: 40
                        Layout.fillHeight: true
                        color: Material.accent
                        SelectAllBox{
                            id: selectAll
                            anchors.centerIn: parent
                            rows: itemModel.items
                            selectedCount: selectedGroup.count
                        }
                    }
                    HeaderCell{ text: qsTr("Addr"); Layout.preferredWidth: 70 }
                    HeaderCell{ text: qsTr("Name"); Layout.preferredWidth: list.width * 0.17 }
                    HeaderCell{ text: qsTr("Size"); Layout.preferredWidth: 50 }
                    HeaderCell{ text: qsTr("Bit fields"); Layout.fillWidth: true }
                    HeaderCell{ text: qsTr("Default"); Layout.preferredWidth: 80 }
                    HeaderCell{ text: qsTr("Description"); Layout.preferredWidth: list.width * 0.25 }
                }
                model: DelegateModel{
                    id: itemModel
                    model: window.appSetModel
                    groups: [ DelegateModelGroup { id: selectedGroup; name: "selected" } ]
                    delegate: AppSetItem{
                        id: row
                        required property var model
                        required property int index
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
                        onActivated: regWindow.manage(row.index, window.appSetModel.get(row.index))
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
                        color: sensetool.onAccent
                        text: qsTr("%1 registers").arg(itemModel.count) + qsTr("  •  %1 selected").arg(selectedGroup.count)
                              + (window.appSetModel ? qsTr("  •  %1 / %2 bytes used").arg(window.appSetModel.bytesUsed).arg(window.appSetModel.tableSize()) : "")
                              + (window.appSetModel && window.appSetModel.issueCount > 0 ? qsTr("  •  %1 with problems").arg(window.appSetModel.issueCount) : "")
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
                    }
                }
                Text{
                    anchors.centerIn: parent
                    visible: list.count === 0
                    width: parent.width * 0.6
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: qsTr("No registers yet.\nOpen a project (Ctrl+O), import the AppSet sheet, or Add a register.")
                    color: Material.foreground
                    opacity: 0.6
                    font.pixelSize: 16
                    font.family: "Montserrat Medium"
                }
                ScrollBar.vertical: ScrollBar{}
            }
        }
    }
}
