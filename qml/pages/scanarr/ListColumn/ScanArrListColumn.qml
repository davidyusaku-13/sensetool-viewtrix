import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../../components"

// The scan steps of the arrangement picked in the Arrangements column.
Item{
    id: root
    property int index: -1
    property var model: null
    property var confirm: null
    readonly property int stepCount: model ? model.scans.count : 0
    readonly property int selectedCount: selectedChoose.count
    signal touched()

    // Where new steps go: after the single selected step, otherwise just before
    // the terminating AFE_END (or at the end if there is none).
    function insertPosition(){
        let scans = root.model.scans
        if(selectedChoose.count === 1) return selectedChoose.get(0).itemsIndex + 1
        if(scans.count > 0 && scans.get(scans.count-1).name === "AFE_END") return scans.count - 1
        return scans.count
    }
    function moveSelected(delta){
        if(!root.model || selectedChoose.count !== 1) return
        let i = selectedChoose.get(0).itemsIndex
        let j = i + delta
        if(j < 0 || j >= root.model.scans.count) return
        root.model.scans.move(i, j, 1)
    }
    function addItem(){ if(root.model) scanArrListWindow.manage(-1, null) }
    function editSelected(){}
    function deleteSelected(){
        if(!root.model || selectedChoose.count === 0) return
        let rows = []
        for(let i = 0; i < selectedChoose.count; i++) rows.push(selectedChoose.get(i).itemsIndex)
        rows.sort((a, b) => b - a)
        root.confirm.ask(qsTr("Remove %1 step(s) from %2?").arg(rows.length).arg(root.model.name), () => {
            for(let r of rows) root.model.scans.remove(r)
        })
    }
    function toggleAll(){ selectAll.setAll(selectAll.checkState !== Qt.Checked) }

    ScanArrListWindow{
        id: scanArrListWindow
        Material.theme: sensetool.theme
        Material.accent: sensetool.accent
        onCreate: (object) => {
                      if(!root.model) return
                      let at = root.insertPosition()
                      for(let i=0; i<object.names.length; i++){
                          root.model.scans.insert(at + i, object.get(i))
                      }
                  }
    }
    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10
        RowLayout{
            Layout.fillWidth: true
            Text{
                Layout.fillWidth: true
                text: root.model ? root.model.name : qsTr("Scan List")
                elide: Text.ElideRight
                font.family: "Montserrat SemiBold"
                font.pixelSize: 15
                color: Material.foreground
            }
            Text{
                visible: root.model !== null
                text: qsTr("%1 / 10 steps").arg(root.stepCount)
                color: root.stepCount > 10 ? "#E53935" : Material.foreground
                opacity: root.stepCount > 10 ? 1 : 0.7
                font.family: "Montserrat Medium"
                font.pixelSize: 13
            }
        }
        Flow{
            Layout.fillWidth: true
            spacing: 6
            enabled: root.model !== null
            ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Insert steps after the selected one, or before AFE_END (Ctrl+N)"); onClicked: root.addItem() }
            ToolbarBtn{ text: qsTr("Remove"); ToolTip.text: qsTr("Remove the selected steps (Del)"); enabled: selectedChoose.count > 0; onClicked: root.deleteSelected() }
            ToolbarBtn{ text: "▲"; ToolTip.text: qsTr("Move up"); enabled: selectedChoose.count === 1; onClicked: root.moveSelected(-1) }
            ToolbarBtn{ text: "▼"; ToolTip.text: qsTr("Move down"); enabled: selectedChoose.count === 1; onClicked: root.moveSelected(1) }
        }
        ShadowRect{
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Material.background
            ListView{
                id: list
                anchors.fill: parent
                clip: true
                ScrollBar.vertical: ScrollBar{}
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
                            enabled: root.model !== null
                            rows: scanArrChooseModel.items
                            selectedCount: selectedChoose.count
                        }
                    }
                    HeaderCell{ text: "#"; Layout.preferredWidth: 36 }
                    HeaderCell{ text: qsTr("Scan step"); Layout.fillWidth: true }
                }
                model: DelegateModel{
                    id: scanArrChooseModel
                    model: root.model ? root.model.scans : []
                    groups: [ DelegateModelGroup { id: selectedChoose; name: "selected"; onCountChanged: root.touched() } ]
                    delegate: ScanArrListItem{
                        id: scanArrChooseDel
                        required property var model
                        required property int index
                        step: index + 1
                        name: model.name
                        width: ListView.view.width
                        checkBox.checked: scanArrChooseDel.DelegateModel.inSelected
                        onSelected: scanArrChooseDel.DelegateModel.inSelected = !scanArrChooseDel.DelegateModel.inSelected
                    }
                }
                Text{
                    anchors.centerIn: parent
                    visible: root.model === null
                    width: parent.width * 0.8
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: qsTr("Click an arrangement to see and edit its scan steps.")
                    color: Material.foreground
                    opacity: 0.6
                    font.pixelSize: 14
                }
            }
        }
    }
}
