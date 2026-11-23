import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import "../../components"

// Scan Arrangement workspace: replaces the ScanArrg sheet of prjcfg.xlsx.
// All state and rules are in ScanArrModel (Python); this page only presents them.
ShadowRect{
    id: page
    Layout.fillWidth: true
    Layout.fillHeight: true

    // dependencies, passed in by SenseTool
    required property var scanArr   // ScanArrModel
    required property var history   // HistoryModel

    // Keyboard shortcuts act on the column where something was last selected.
    property var active: items

    function generate(){
        let issues = page.scanArr.check()
        if(issues.length > 0) errors.show(qsTr("Fix these problems first:\n\n") + issues.join("\n"))
        else dialogGenerate.open()
    }

    ErrorDialog{ id: errors; title: qsTr("Scan Arrangement") }
    ConfirmDialog{ id: confirmDelete; title: qsTr("Scan Arrangement") }
    FolderDialog {
        id: dialogGenerate
        title: qsTr("Folder for afeScanArrg.c and afeScanArrg.h")
        onAccepted: if(!errors.show(page.scanArr.generate(selectedFolder)))
                        page.history.addHistory("Generated", selectedFolder + "/afeScanArrg.c, afeScanArrg.h", "", "")
    }
    FileDialog {
        id: dialogImport
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Scan arrangement (*.yaml *.yml *.xlsx)"), qsTr("YAML files (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
        onAccepted: {
            if(errors.show(page.scanArr.importFile(selectedFile))) return
            page.history.addHistory("Imported", selectedFile, "", "")
            let skipped = page.scanArr.skippedRows()
            if(skipped.length > 0)
                errors.show(qsTr("Imported. These arrangement rows have no name or scan steps yet and were skipped:\n\n") + skipped.join("\n"))
        }
    }
    FileDialog {
        id: dialogExport
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: if(!errors.show(page.scanArr.exportYAML(selectedFile))) page.history.addHistory("Exported", selectedFile, "", "")
    }
    ScanItemWindow{
        id: itemEditor
        apply: (i, name, desc) => i === -1 ? page.scanArr.addItem(name, desc) : page.scanArr.editItem(i, name, desc)
    }
    ArrangementWindow{
        id: arrEditor
        apply: (i, id, name, desc) => i === -1 ? page.scanArr.addArrangement(id, name, desc)
                                               : page.scanArr.editArrangement(i, id, name, desc)
    }
    StepPickerWindow{
        id: stepPicker
        items: page.scanArr.items
        apply: (names) => {
            let sel = steps.table.selectedIndexes()
            page.scanArr.insertSteps(names, sel.length === 1 ? sel[0] : -1)
            return ""
        }
    }
    PageShortcuts{
        active: page.visible
        selectedCount: page.active.table.selectedCount
        onAdd: page.active.add()
        onEdit: page.active.edit()
        onRemove: page.active.remove()
        onSelectAll: page.active.table.toggleAll()
        onGenerate: page.generate()
    }

    // A titled column: a toolbar over a table.
    component Panel: ColumnLayout{
        id: panel
        property alias title: titleText.text
        property alias note: noteText.text
        readonly property SelectableTable table: tableItem
        default property alias tools: toolbar.data
        // what Ctrl+N / Enter / Del do in this column
        property var add: function(){}
        property var edit: function(){}
        property var remove: function(){}
        // something was selected here: page shortcuts should act on this column
        signal used()
        spacing: 10
        RowLayout{
            Layout.fillWidth: true
            Text{
                id: titleText
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.family: "Montserrat SemiBold"
                font.pixelSize: 15
                color: Material.foreground
            }
            Text{
                id: noteText
                visible: text !== ""
                font.family: "Montserrat Medium"
                font.pixelSize: 13
                color: Material.foreground
                opacity: 0.7
            }
        }
        // Wraps onto a second line when the column is narrow instead of squashing buttons.
        Flow{ id: toolbar; Layout.fillWidth: true; spacing: 6 }
        SelectableTable{
            id: tableItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            onSelectedCountChanged: if(selectedCount > 0) panel.used()
        }
    }

    ColumnLayout{
        anchors.fill: parent
        spacing: 0
        Flow{
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 20
            spacing: 6
            ToolbarBtn{ text: qsTr("Import"); ToolTip.text: qsTr("Replace the scan items and arrangements with a YAML file or the ScanArrg sheet"); onClicked: dialogImport.open() }
            ToolbarBtn{ text: qsTr("Export"); ToolTip.text: qsTr("Save only the scan arrangement as YAML"); onClicked: dialogExport.open() }
            ToolbarBtn{
                text: qsTr("Check")
                ToolTip.text: qsTr("Look for problems without generating")
                onClicked: {
                    let issues = page.scanArr.check()
                    errors.show(issues.length === 0 ? qsTr("No problems found.") : issues.join("\n"))
                }
            }
            ToolbarBtn{ text: qsTr("Generate afeScanArrg.c/.h"); ToolTip.text: qsTr("Write the C files (Ctrl+G)"); primary: true; onClicked: page.generate() }
        }
        SplitView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            Panel{
                id: items
                onUsed: page.active = items
                SplitView.fillHeight: true
                SplitView.minimumWidth: 230
                SplitView.preferredWidth: page.width * 0.38
                title: qsTr("Scan Items")
                table.model: page.scanArr.items
                table.columns: [{title: "#", width: 36}, {title: qsTr("Name"), stretch: 12}, {title: qsTr("Description"), stretch: 10}]
                table.row: Component{ ScanItemRow{} }
                table.emptyText: qsTr("No scan items. The first one must be AFE_END (value 0).")
                table.onActivated: (i) => itemEditor.open(i, page.scanArr.items.get(i))
                add: () => itemEditor.open(-1, null)
                edit: () => { if(table.selectedCount === 1) itemEditor.open(table.selectedIndexes()[0], page.scanArr.items.get(table.selectedIndexes()[0])) }
                remove: () => {
                    let rows = table.selectedIndexes()
                    if(rows.length) confirmDelete.ask(qsTr("Delete %1 scan item(s)?").arg(rows.length), () => page.scanArr.removeItems(rows))
                }
                function moveSelected(delta){
                    let j = page.scanArr.moveItem(table.selectedIndexes()[0], delta)
                    table.select([j])
                }
                ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Add a scan item (Ctrl+N)"); onClicked: items.add() }
                ToolbarBtn{ text: qsTr("Edit"); ToolTip.text: qsTr("Edit (Enter, or double-click)"); enabled: items.table.selectedCount === 1; onClicked: items.edit() }
                ToolbarBtn{ text: qsTr("Delete"); ToolTip.text: qsTr("Delete (Del)"); enabled: items.table.selectedCount > 0; onClicked: items.remove() }
                ToolbarBtn{ text: "▲"; ToolTip.text: qsTr("Move up (lowers its value)"); enabled: items.table.selectedCount === 1; onClicked: items.moveSelected(-1) }
                ToolbarBtn{ text: "▼"; ToolTip.text: qsTr("Move down"); enabled: items.table.selectedCount === 1; onClicked: items.moveSelected(1) }
            }
            Panel{
                id: arrangements
                onUsed: page.active = arrangements
                SplitView.fillHeight: true
                SplitView.fillWidth: true
                SplitView.minimumWidth: 240
                title: qsTr("Arrangements")
                table.model: page.scanArr.arrangements
                table.columns: [{title: qsTr("ID"), width: 44}, {title: qsTr("Name"), stretch: 12}, {title: qsTr("Description"), stretch: 10}]
                table.row: Component{ ArrangementRow{} }
                table.currentIndex: page.scanArr.current
                table.emptyText: qsTr("No arrangements yet. Add one, then click it to choose its scan steps.")
                table.footerText: qsTr("%1 arrangements  •  %2 selected").arg(table.totalCount).arg(table.selectedCount)
                table.onTapped: (i) => { page.scanArr.setCurrent(i); page.active = steps }
                table.onActivated: (i) => arrEditor.open(i, page.scanArr.arrangements.get(i))
                add: () => arrEditor.open(-1, null, page.scanArr.nextArrangementId())
                edit: () => { if(table.selectedCount === 1) arrEditor.open(table.selectedIndexes()[0], page.scanArr.arrangements.get(table.selectedIndexes()[0])) }
                remove: () => {
                    let rows = table.selectedIndexes()
                    if(rows.length) confirmDelete.ask(qsTr("Delete %1 arrangement(s) and their steps?").arg(rows.length), () => page.scanArr.removeArrangements(rows))
                }
                ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Add an arrangement (Ctrl+N)"); onClicked: arrangements.add() }
                ToolbarBtn{ text: qsTr("Edit"); ToolTip.text: qsTr("Edit ID, name, description (Enter, or double-click)"); enabled: arrangements.table.selectedCount === 1; onClicked: arrangements.edit() }
                ToolbarBtn{ text: qsTr("Delete"); ToolTip.text: qsTr("Delete (Del)"); enabled: arrangements.table.selectedCount > 0; onClicked: arrangements.remove() }
            }
            Panel{
                id: steps
                onUsed: page.active = steps
                SplitView.fillHeight: true
                SplitView.minimumWidth: 190
                SplitView.preferredWidth: page.width * 0.28
                readonly property bool hasArrangement: page.scanArr.current !== -1
                title: hasArrangement ? page.scanArr.currentName : qsTr("Scan List")
                note: hasArrangement ? qsTr("%1 / %2 steps").arg(table.totalCount).arg(page.scanArr.stepLimit) : ""
                table.model: page.scanArr.steps
                table.columns: [{title: "#", width: 46}, {title: qsTr("Scan step"), stretch: 1}]
                table.row: Component{ StepRow{} }
                table.emptyText: hasArrangement ? "" : qsTr("Click an arrangement to see and edit its scan steps.")
                table.footerText: qsTr("%1 of %2 selected").arg(table.selectedCount).arg(table.totalCount)
                add: () => { if(hasArrangement) stepPicker.open() }
                remove: () => {
                    let rows = table.selectedIndexes()
                    if(rows.length) confirmDelete.ask(qsTr("Remove %1 step(s) from %2?").arg(rows.length).arg(page.scanArr.currentName),
                                                      () => page.scanArr.removeSteps(rows))
                }
                function moveSelected(delta){
                    let j = page.scanArr.moveStep(table.selectedIndexes()[0], delta)
                    table.select([j])
                }
                ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Insert steps after the selected one, or before AFE_END (Ctrl+N)"); enabled: steps.hasArrangement; onClicked: steps.add() }
                ToolbarBtn{ text: qsTr("Remove"); ToolTip.text: qsTr("Remove the selected steps (Del)"); enabled: steps.table.selectedCount > 0; onClicked: steps.remove() }
                ToolbarBtn{ text: "▲"; ToolTip.text: qsTr("Move up"); enabled: steps.table.selectedCount === 1; onClicked: steps.moveSelected(-1) }
                ToolbarBtn{ text: "▼"; ToolTip.text: qsTr("Move down"); enabled: steps.table.selectedCount === 1; onClicked: steps.moveSelected(1) }
            }
        }
    }
}
