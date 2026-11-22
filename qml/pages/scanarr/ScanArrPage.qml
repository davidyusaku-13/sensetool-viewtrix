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
            arrs.push({"name": a.name, "desc": a.desc, "scans": scans})
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
            arrColumn.scanArrList.append({"name": a.name, "desc": a.desc,
                                          "scans": a.scans.map(n => ({"name": n}))})
        }
    }
    function showError(message){
        errorDialog.text = message
        errorDialog.open()
    }
    MessageDialog {
        id: errorDialog
        title: qsTr("Scan Arrangement")
        buttons: MessageDialog.Ok
    }
    FileDialog {
        id: dialogImport
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: {
            let data = window.logic.importScanArr(selectedFile)
            if(data.scan_items === undefined){
                page.showError(window.logic.lastError())
                return
            }
            page.load(data)
            window.historyModel.addHistory("Imported", selectedFile, "", "")
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
        }
        SplitView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Scan Items
            ScanItemColumn{
                id: itemColumn
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
