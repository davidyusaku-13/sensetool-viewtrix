import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

// Project Setting workspace: replaces the PrjSet sheet of prjcfg.xlsx.
ShadowRect{
    id: page
    Layout.fillHeight: true
    Layout.fillWidth: true

    // dependencies, passed in by SenseTool
    required property var model     // PrjSetModel
    required property var history   // HistoryModel
    property alias searchText: searchField.text
    property alias problemsOnly: problemsOnly.checked
    readonly property alias table: table

    readonly property bool filtering: isFiltering()
    // Read the fields directly: in their change handlers the `filtering` binding may not have updated yet.
    function isFiltering(){ return searchField.text.trim() !== "" || problemsOnly.checked }

    function matches(m){
        let q = searchField.text.trim().toLowerCase()
        return (!problemsOnly.checked || m.issue !== "")
            && (q === "" || [m.name, m.value, m.desc, m.group, m.comment, m.resolved]
                            .some(s => String(s || "").toLowerCase().indexOf(q) !== -1))
    }
    function refilter(){ table.filter = page.isFiltering() ? page.matches : null; table.refilter() }
    function addItem(){ editor.open(-1, null) }
    function editRow(i){ editor.open(i, page.model.get(i)) }
    function editSelected(){ if(table.selectedCount === 1) editRow(table.selectedIndexes()[0]) }
    function deleteSelected(){
        let rows = table.selectedIndexes().reverse()
        if(rows.length === 0) return
        confirmDelete.ask(qsTr("Delete %1 item(s)?").arg(rows.length), () => {
            for(let r of rows){
                let item = page.model.get(r)
                page.history.addHistory("Deleted", item.name, item.value, item.desc)
                page.model.removeItem(r)
            }
        })
    }
    function generate(){
        if(page.model.rootIssueCount > 0)
            errors.show(qsTr("%1 item(s) have problems (shown in red). Fix them before generating the header.").arg(page.model.rootIssueCount))
        else
            dialogHeader.open()
    }

    ErrorDialog{ id: errors; title: qsTr("Project Setting") }
    ConfirmDialog{ id: confirmDelete; title: qsTr("Project Setting") }
    FileDialog {
        id: dialogImport
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Project setting (*.yaml *.yml *.xlsx)"), qsTr("YAML files (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
        onAccepted: if(!errors.show(page.model.importFile(selectedFile))) page.history.addHistory("Imported", selectedFile, "", "")
    }
    FileDialog {
        id: dialogExport
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: if(!errors.show(page.model.exportYAML(selectedFile))) page.history.addHistory("Exported", selectedFile, "", "")
    }
    FileDialog {
        id: dialogHeader
        fileMode: FileDialog.SaveFile
        defaultSuffix: "h"
        nameFilters: [qsTr("C header (*.h)")]
        onAccepted: if(!errors.show(page.model.exportHeader(selectedFile))) page.history.addHistory("Generated", selectedFile, "", "")
    }
    PrjSetWindow{
        id: editor
        model: page.model
        apply: (index, item) => {
            if(index === -1){
                page.model.addItem(item.name, item.value, item.desc, item.group, item.comment)
                page.history.addHistory("Added", item.name, item.value, item.desc)
            } else {
                page.model.edit(index, item.name, item.value, item.desc, item.group, item.comment)
                page.history.addHistory("Modified", item.name, item.value, item.desc)
            }
            return ""
        }
    }
    PageShortcuts{
        active: page.visible
        selectedCount: table.selectedCount
        typing: searchField.activeFocus
        canFind: true
        onAdd: page.addItem()
        onEdit: page.editSelected()
        onRemove: page.deleteSelected()
        onSelectAll: table.toggleAll()
        onGenerate: page.generate()
        onFind: searchField.forceActiveFocus()
    }

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        Flow{
            Layout.fillWidth: true
            spacing: 6
            ToolbarBtn{ text: qsTr("Import"); ToolTip.text: qsTr("Replace this list with a project-setting YAML or prjcfg.xlsx"); onClicked: dialogImport.open() }
            ToolbarBtn{ text: qsTr("Export"); ToolTip.text: qsTr("Save only the project settings as YAML"); onClicked: dialogExport.open() }
            ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Add an item (Ctrl+N)"); onClicked: page.addItem() }
            ToolbarBtn{ text: qsTr("Edit"); ToolTip.text: qsTr("Edit the selected item (Enter, or double-click a row)"); enabled: table.selectedCount === 1; onClicked: page.editSelected() }
            ToolbarBtn{ text: qsTr("Delete"); ToolTip.text: qsTr("Delete the selected items (Del)"); enabled: table.selectedCount > 0; onClicked: page.deleteSelected() }
            ToolbarBtn{ text: qsTr("Generate prjset.h"); ToolTip.text: qsTr("Write the C header (Ctrl+G)"); primary: true; onClicked: page.generate() }
        }
        RowLayout{
            Layout.fillWidth: true
            spacing: 12
            TextField{
                id: searchField
                Layout.fillWidth: true
                Layout.maximumWidth: 420
                placeholderText: qsTr("Search name, value, description… (Ctrl+F)")
                selectByMouse: true
                onTextChanged: page.refilter()
                Keys.onEscapePressed: { text = ""; focus = false }
            }
            CheckBox{
                id: problemsOnly
                text: qsTr("Problems only")
                enabled: checked || page.model.issueCount > 0
                onCheckedChanged: page.refilter()
            }
            Item{ Layout.fillWidth: true }
        }
        SelectableTable{
            id: table
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: page.model
            columns: [{title: qsTr("Item"), stretch: 10}, {title: qsTr("Value"), stretch: 10},
                      {title: qsTr("Description"), fraction: 3/7}]
            row: Component{ PrjSetItem{} }
            sectionProperty: "group"
            // reordering a filtered list would be confusing
            reorderable: !page.filtering
            emptyText: page.filtering ? qsTr("No items match the search.")
                                      : qsTr("No project settings yet.\nOpen a project (Ctrl+O), import prjcfg.xlsx, or Add an item.")
            footerText: {
                let m = page.model
                let s = page.filtering ? qsTr("Showing %1 of %2").arg(shownCount).arg(totalCount)
                                       : qsTr("%1 items").arg(totalCount)
                s += qsTr("  •  %1 selected").arg(selectedCount)
                if(m.rootIssueCount > 0) s += qsTr("  •  %1 problem(s)").arg(m.rootIssueCount)
                if(m.issueCount > m.rootIssueCount) s += qsTr(" (%1 more affected)").arg(m.issueCount - m.rootIssueCount)
                return s
            }
            onActivated: (i) => page.editRow(i)
            onMoveRequested: (from, to) => page.model.move(from, to)
        }
    }
}
