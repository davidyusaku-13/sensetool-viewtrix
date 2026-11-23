import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"
import "./ArrangementColumn"
import "./ItemColumn"
import "./ListColumn"

ShadowRect{
    id: page
    Layout.fillWidth: true
    Layout.fillHeight: true

    function collect(){
        let items = []
        for(let i=0; i<itemColumn.scanItemList.count; i++){
            let it = itemColumn.scanItemList.get(i)
            items.push({"name": it.name, "desc": it.desc})
        }
        let arrs = []
        for(let i=0; i<arrColumn.scanArrList.count; i++){
            let a = arrColumn.scanArrList.get(i)
            let scans = []
            for(let j=0; j<a.scans.count; j++){
                scans.push(a.scans.get(j).name)
            }
            arrs.push({"id": a.arrId, "name": a.name, "desc": a.desc, "scans": scans})
        }
        return [items, arrs]
    }
    function load(data){
        scanArrListColumn.index = -1
        scanArrListColumn.model = null
        itemColumn.scanItemList.clear()
        arrColumn.scanArrList.clear()
        for(let it of data.scan_items){
            itemColumn.scanItemList.append({"name": it.name, "desc": it.desc})
        }
        for(let a of data.arrangements){
            arrColumn.scanArrList.append({"arrId": a.id, "name": a.name, "desc": a.desc,
                                          "scans": a.scans.map(n => ({"name": n}))})
        }
    }
    function showError(message){
        errorDialog.text = message
        errorDialog.open()
    }
    function renameStep(oldName, newName){
        for(let i=0; i<arrColumn.scanArrList.count; i++){
            let scans = arrColumn.scanArrList.get(i).scans
            for(let j=0; j<scans.count; j++){
                if(scans.get(j).name === oldName) scans.setProperty(j, "name", newName)
            }
        }
    }
    function check(){
        let d = page.collect()
        return window.logic.checkScanArr(d[0], d[1])
    }
    FolderDialog {
        id: dialogGenerate
        title: qsTr("Folder for afeScanArrg.c and afeScanArrg.h")
        onAccepted: {
            let d = page.collect()
            let err = window.logic.generateScanArr(selectedFolder, d[0], d[1])
            if(err !== ""){
                page.showError(err)
                return
            }
            window.historyModel.addHistory("Generated", selectedFolder + "/afeScanArrg.c, afeScanArrg.h", "", "")
        }
    }
    MessageDialog {
        id: errorDialog
        title: qsTr("Scan Arrangement")
        buttons: MessageDialog.Ok
    }
    FileDialog {
        id: dialogImport
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Scan arrangement (*.yaml *.yml *.xlsx)"), qsTr("YAML files (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
        onAccepted: {
            let data = window.logic.importScanArr(selectedFile)
            if(data.scan_items === undefined){
                page.showError(window.logic.lastError())
                return
            }
            page.load(data)
            window.historyModel.addHistory("Imported", selectedFile, "", "")
            if(data.skipped.length > 0){
                page.showError(qsTr("Imported. These arrangement rows have no name or scan steps yet and were skipped:\n\n")
                               + data.skipped.join("\n"))
            }
        }
    }
    FileDialog {
        id: dialogExport
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: {
            let d = page.collect()
            let err = window.logic.exportScanArr(selectedFile, d[0], d[1])
            if(err !== ""){
                page.showError(err)
                return
            }
            window.historyModel.addHistory("Exported", selectedFile, "", "")
        }
    }
    ColumnLayout{
        anchors.fill: parent
        // Import Export Row
        RowLayout{
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 20
            ToolbarBtn{
                Layout.fillWidth: true
                text: qsTr("Import")
                Material.background: Material.accent
                onClicked: dialogImport.open()
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: qsTr("Export")
                Material.background: Material.accent
                onClicked: dialogExport.open()
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: qsTr("Check")
                Material.background: Material.accent
                onClicked: {
                    let issues = page.check()
                    page.showError(issues.length === 0 ? qsTr("No problems found.")
                                                       : issues.join("\n"))
                }
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: qsTr("Generate afeScanArrg.c/.h")
                Material.background: Material.accent
                onClicked: {
                    let issues = page.check()
                    if(issues.length > 0){
                        page.showError(qsTr("Fix these problems first:\n\n") + issues.join("\n"))
                    } else {
                        dialogGenerate.open()
                    }
                }
            }
        }
        SplitView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Scan Items
            ScanItemColumn{
                id: itemColumn
                onRenamed: (oldName, newName) => page.renameStep(oldName, newName)
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 6/15 : parent.width * 2/7
            }
            // ScanArr Items
            ScanArrColumn{
                id: arrColumn
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 6/15  : parent.width * 3/7
                onFocusIndex: (index, model) => {
                                  scanArrListColumn.index = index
                                  scanArrListColumn.model = model
                              }
            }
            // ScanArrList Column
            ScanArrListColumn{
                id: scanArrListColumn
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 3/15  : parent.width * 1/7
            }
        }
    }
}
