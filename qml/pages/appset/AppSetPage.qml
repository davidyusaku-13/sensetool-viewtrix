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

    // dependencies, passed in by SenseTool
    required property var model     // AppSetModel
    required property var history   // HistoryModel

    function addItem(){ editor.open(-1, null) }
    function editRow(i){ editor.open(i, page.model.get(i)) }
    function editSelected(){ if(table.selectedCount === 1) editRow(table.selectedIndexes()[0]) }
    function deleteSelected(){
        let rows = table.selectedIndexes()
        if(rows.length === 0) return
        confirmDelete.ask(qsTr("Delete %1 register(s)?").arg(rows.length), () => {
            for(let i of rows){
                let r = page.model.get(i)
                page.history.addHistory("Deleted", r.name, r.addr, r.desc)
            }
            page.model.removeItems(rows)
        })
    }
    function generate(){
        if(page.model.issueCount > 0)
            errors.show(qsTr("%1 register(s) have problems (shown in red). Fix them before generating.").arg(page.model.issueCount))
        else
            dialogGenerate.open()
    }

    ErrorDialog{ id: errors; title: qsTr("Application Setting") }
    ConfirmDialog{ id: confirmDelete; title: qsTr("Application Setting") }
    FileDialog {
        id: dialogImport
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Application setting (*.yaml *.yml *.xlsx)"), qsTr("YAML files (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
        onAccepted: if(!errors.show(page.model.importFile(selectedFile))) page.history.addHistory("Imported", selectedFile, "", "")
    }
    FileDialog {
        id: dialogExport
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: if(!errors.show(page.model.exportYAML(selectedFile))) page.history.addHistory("Exported", selectedFile, "", "")
    }
    FolderDialog {
        id: dialogGenerate
        title: qsTr("Folder for appset.c and appset.h")
        onAccepted: if(!errors.show(page.model.generate(selectedFolder))) page.history.addHistory("Generated", selectedFolder + "/appset.c, appset.h", "", "")
    }
    AppSetWindow{
        id: editor
        model: page.model
        apply: (index, reg) => {
            if(index === -1){
                page.model.addRegister(reg)
                page.history.addHistory("Added", reg.name, reg.addr, reg.desc)
            } else {
                page.model.editRegister(index, reg)
                page.history.addHistory("Modified", reg.name, reg.addr, reg.desc)
            }
            return ""
        }
    }
    PageShortcuts{
        active: page.visible
        selectedCount: table.selectedCount
        onAdd: page.addItem()
        onEdit: page.editSelected()
        onRemove: page.deleteSelected()
        onSelectAll: table.toggleAll()
        onGenerate: page.generate()
    }

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        Flow{
            Layout.fillWidth: true
            spacing: 6
            ToolbarBtn{ text: qsTr("Import"); ToolTip.text: qsTr("Replace the table with an app-setting YAML or the AppSet sheet"); onClicked: dialogImport.open() }
            ToolbarBtn{ text: qsTr("Export"); ToolTip.text: qsTr("Save only the app settings as YAML"); onClicked: dialogExport.open() }
            ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Add a register (Ctrl+N)"); onClicked: page.addItem() }
            ToolbarBtn{ text: qsTr("Edit"); ToolTip.text: qsTr("Edit (Enter, or double-click a row)"); enabled: table.selectedCount === 1; onClicked: page.editSelected() }
            ToolbarBtn{ text: qsTr("Delete"); ToolTip.text: qsTr("Delete (Del)"); enabled: table.selectedCount > 0; onClicked: page.deleteSelected() }
            ToolbarBtn{ text: qsTr("Generate appset.c/.h"); ToolTip.text: qsTr("Write the C files (Ctrl+G)"); primary: true; onClicked: page.generate() }
        }
        SelectableTable{
            id: table
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: page.model
            columns: [{title: qsTr("Addr"), width: 70}, {title: qsTr("Name"), fraction: 0.17}, {title: qsTr("Size"), width: 50},
                      {title: qsTr("Bit fields"), stretch: 1}, {title: qsTr("Default"), width: 80},
                      {title: qsTr("Description"), fraction: 0.25}]
            row: Component{ AppSetItem{} }
            emptyText: qsTr("No registers yet.\nOpen a project (Ctrl+O), import the AppSet sheet, or Add a register.")
            footerText: qsTr("%1 registers").arg(totalCount) + qsTr("  •  %1 selected").arg(selectedCount)
                        + qsTr("  •  %1 / %2 bytes used").arg(page.model.bytesUsed).arg(page.model.tableSize())
                        + (page.model.issueCount > 0 ? qsTr("  •  %1 with problems").arg(page.model.issueCount) : "")
            onActivated: (i) => page.editRow(i)
        }
    }
}
