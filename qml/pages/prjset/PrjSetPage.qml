import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

// Project Setting workspace: replaces the PrjSet sheet of prjcfg.xlsx.
ShadowRect{
    id: layout
    Layout.fillHeight: true
    Layout.fillWidth: true

    readonly property bool filtering: searchField.text.trim() !== "" || problemsOnly.checked

    function showError(message){
        if(message !== ""){
            errorDialog.text = message
            errorDialog.open()
            return true
        }
        return false
    }
    function applyFilter(){
        let q = searchField.text.trim().toLowerCase()
        let onlyProblems = problemsOnly.checked
        for(let i = 0; i < itemModel.items.count; i++){
            let it = itemModel.items.get(i)
            let m = it.model
            let ok = (!onlyProblems || m.issue !== "")
                  && (q === "" || [m.name, m.value, m.desc, m.group, m.comment, m.resolved]
                                  .some(s => String(s || "").toLowerCase().indexOf(q) !== -1))
            it.inShown = ok
            if(!ok) it.inSelected = false
        }
    }
    function addItem(){ prjSetWindow.manage(-1, null) }
    function editSelected(){
        if(selectedGroup.count === 1){
            let selected = selectedGroup.get(0)
            prjSetWindow.manage(selected.itemsIndex, selected.model)
        }
    }
    function deleteSelected(){
        if(selectedGroup.count === 0) return
        let rows = []
        for(let i = 0; i < selectedGroup.count; i++) rows.push(selectedGroup.get(i).itemsIndex)
        rows.sort((a, b) => b - a)
        confirmDelete.ask(qsTr("Delete %1 item(s)?").arg(rows.length), () => {
            for(let r of rows){
                let item = window.prjSetModel.get(r)
                window.historyModel.addHistory("Deleted", item.name, item.value, item.desc)
                window.prjSetModel.removeItem(r)
            }
        })
    }
    function generate(){
        if(window.prjSetModel.rootIssueCount > 0)
            layout.showError(qsTr("%1 item(s) have problems (shown in red). Fix them before generating the header.").arg(window.prjSetModel.rootIssueCount))
        else
            dialogHeader.open()
    }

    MessageDialog {
        id: errorDialog
        title: qsTr("Project Setting")
        buttons: MessageDialog.Ok
    }
    ConfirmDialog { id: confirmDelete; title: qsTr("Project Setting") }
    FileDialog {
        id: dialogImport
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Project setting (*.yaml *.yml *.xlsx)"), qsTr("YAML files (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
        onAccepted: {
            if(!layout.showError(window.prjSetModel.importFile(selectedFile)))
                window.historyModel.addHistory("Imported", selectedFile, "", "")
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
    PrjSetWindow{
        id: prjSetWindow
        Material.theme: sensetool.theme
        Material.accent: sensetool.accent
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
    Connections{
        target: window.prjSetModel
        function onModelReset(){ Qt.callLater(layout.applyFilter) }
        function onRowsInserted(){ Qt.callLater(layout.applyFilter) }
        function onDataChanged(){ if(layout.filtering) Qt.callLater(layout.applyFilter) }
    }

    // Keyboard: active only while this page is shown.
    Shortcut{ sequences: [StandardKey.New]; enabled: layout.visible; onActivated: layout.addItem() }
    Shortcut{ sequences: [StandardKey.Find]; enabled: layout.visible; onActivated: searchField.forceActiveFocus() }
    Shortcut{ sequences: ["Ctrl+G"]; enabled: layout.visible; onActivated: layout.generate() }
    Shortcut{
        sequences: [StandardKey.Delete]
        enabled: layout.visible && !searchField.activeFocus && selectedGroup.count > 0
        onActivated: layout.deleteSelected()
    }
    Shortcut{
        sequences: ["Return", "Enter", "F2"]
        enabled: layout.visible && !searchField.activeFocus && selectedGroup.count === 1
        onActivated: layout.editSelected()
    }
    Shortcut{
        sequences: [StandardKey.SelectAll]
        enabled: layout.visible && !searchField.activeFocus
        onActivated: selectAll.setAll(selectAll.checkState !== Qt.Checked)
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
            ToolbarBtn{ text: qsTr("Import"); ToolTip.text: qsTr("Replace this list with a project-setting YAML or prjcfg.xlsx"); onClicked: dialogImport.open() }
            ToolbarBtn{ text: qsTr("Export"); ToolTip.text: qsTr("Save only the project settings as YAML"); onClicked: dialogExport.open() }
            ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Add an item (Ctrl+N)"); onClicked: layout.addItem() }
            ToolbarBtn{ text: qsTr("Edit"); ToolTip.text: qsTr("Edit the selected item (Enter, or double-click a row)"); enabled: selectedGroup.count === 1; onClicked: layout.editSelected() }
            ToolbarBtn{ text: qsTr("Delete"); ToolTip.text: qsTr("Delete the selected items (Del)"); enabled: selectedGroup.count > 0; onClicked: layout.deleteSelected() }
            ToolbarBtn{ text: qsTr("Generate prjset.h"); ToolTip.text: qsTr("Write the C header (Ctrl+G)"); primary: true; onClicked: layout.generate() }
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
                onTextChanged: layout.applyFilter()
                Keys.onEscapePressed: { text = ""; focus = false }
            }
            CheckBox{
                id: problemsOnly
                text: qsTr("Problems only")
                enabled: checked || (window.prjSetModel && window.prjSetModel.issueCount > 0)
                onCheckedChanged: layout.applyFilter()
            }
            Item{ Layout.fillWidth: true }
        }
        //project set rect
        ShadowRect{
            id: prjSetContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView{
                id: list
                anchors.fill: parent
                interactive: true
                clip: true
                ScrollBar.vertical: ScrollBar{}
                //header: same column widths as PrjSetItem
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
                            rows: shownGroup
                            selectedCount: selectedGroup.count
                        }
                    }
                    HeaderCell{ text: qsTr("Item"); Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.horizontalStretchFactor: 10 }
                    HeaderCell{ text: qsTr("Value"); Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.horizontalStretchFactor: 10 }
                    HeaderCell{ text: qsTr("Description"); Layout.preferredWidth: list.width * 3/7 }
                    HeaderCell{ Layout.preferredWidth: 45 }
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
                    filterOnGroup: "shown"
                    groups: [
                        DelegateModelGroup { id: selectedGroup; name: "selected" },
                        DelegateModelGroup { id: shownGroup; name: "shown"; includeByDefault: true }
                    ]
                    delegate: dragDelegate
                }
                //footer
                footerPositioning: ListView.OverlayFooter
                footer: ShadowRect{
                    width: ListView.view.width
                    height: 35
                    color: Material.accent
                    z: 2
                    Text{
                        anchors.centerIn: parent
                        text: {
                            let m = window.prjSetModel
                            let s = layout.filtering ? qsTr("Showing %1 of %2").arg(shownGroup.count).arg(itemModel.items.count)
                                                     : qsTr("%1 items").arg(itemModel.items.count)
                            s += qsTr("  •  %1 selected").arg(selectedGroup.count)
                            if(m && m.rootIssueCount > 0) s += qsTr("  •  %1 problem(s)").arg(m.rootIssueCount)
                            if(m && m.issueCount > m.rootIssueCount) s += qsTr(" (%1 more affected)").arg(m.issueCount - m.rootIssueCount)
                            return s
                        }
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
                        color: sensetool.onAccent
                    }
                }
                // Empty state
                Text{
                    anchors.centerIn: parent
                    visible: list.count === 0
                    width: parent.width * 0.6
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: layout.filtering ? qsTr("No items match the search.")
                                           : qsTr("No project settings yet.\nOpen a project (Ctrl+O), import prjcfg.xlsx, or Add an item.")
                    color: Material.foreground
                    opacity: 0.6
                    font.pixelSize: 16
                    font.family: "Montserrat Medium"
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
                            // reordering a filtered list would be confusing
                            canDrag: !layout.filtering
                            name: model.name
                            value: model.value
                            desc: model.desc
                            comment: model.comment
                            resolved: model.resolved
                            issue: model.issue
                            dependent: model.dependent
                            content: itemDel
                            checkBox.checked: content.DelegateModel.inSelected
                            onSelected: content.DelegateModel.inSelected = !content.DelegateModel.inSelected
                            onActivated: prjSetWindow.manage(content.index, content.model)
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
