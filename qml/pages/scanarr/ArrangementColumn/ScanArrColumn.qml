import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../../components"

// Scan arrangements (eAfeScanArrgID_t). Click one to edit its steps in the Scan List.
Item{
    id: root
    property alias scanArrList: scanArrList
    property var confirm: null
    // row shown in the Scan List column, -1 for none
    property int currentIndex: -1
    readonly property int selectedCount: selectedScanArr.count
    signal focusIndex(int index, var model)
    signal touched()

    function addItem(){
        let next = 1
        for(let i=0; i<scanArrList.count; i++){
            next = Math.max(next, (parseInt(scanArrList.get(i).arrId) || 0) + 1)
        }
        scanArrWindow.manage(-1, null, String(next))
    }
    function editSelected(){
        if(selectedScanArr.count === 1){
            let selected = selectedScanArr.get(0)
            scanArrWindow.manage(selected.itemsIndex, selected.model)
        }
    }
    function deleteSelected(){
        if(selectedScanArr.count === 0) return
        let rows = []
        for(let i = 0; i < selectedScanArr.count; i++) rows.push(selectedScanArr.get(i).itemsIndex)
        rows.sort((a, b) => b - a)
        root.confirm.ask(qsTr("Delete %1 arrangement(s) and their steps?").arg(rows.length), () => {
            for(let r of rows) scanArrList.remove(r)
            // The Scan List column may be showing a deleted arrangement.
            root.focusIndex(-1, null)
        })
    }
    function toggleAll(){ selectAll.setAll(selectAll.checkState !== Qt.Checked) }

    ScanArrWindow{
        id: scanArrWindow
        Material.theme: sensetool.theme
        Material.accent: sensetool.accent
        onCreate: (object) => {
                      scanArrList.append({"arrId": object.arrId, "name": object.name, "desc": object.desc,
                                          "scans": [{"name": "AFE_END"}]})
                      root.focusIndex(scanArrList.count - 1, scanArrList.get(scanArrList.count - 1))
                  }
        onModify: (index, object) => {
                      // Only rename/redescribe; keep the arrangement's scan list.
                      scanArrList.setProperty(index, "arrId", object.arrId)
                      scanArrList.setProperty(index, "name", object.name)
                      scanArrList.setProperty(index, "desc", object.desc)
                  }
    }
    MouseArea{
        anchors.fill: parent
        onClicked: sidebar.folded = true
    }
    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10
        Text{
            text: qsTr("Arrangements")
            font.family: "Montserrat SemiBold"
            font.pixelSize: 15
            color: Material.foreground
        }
        Flow{
            Layout.fillWidth: true
            spacing: 6
            ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Add an arrangement (Ctrl+N)"); onClicked: root.addItem() }
            ToolbarBtn{ text: qsTr("Edit"); ToolTip.text: qsTr("Edit ID, name, description (Enter, or double-click)"); enabled: selectedScanArr.count === 1; onClicked: root.editSelected() }
            ToolbarBtn{ text: qsTr("Delete"); ToolTip.text: qsTr("Delete (Del)"); enabled: selectedScanArr.count > 0; onClicked: root.deleteSelected() }
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
                            rows: scanArrModel.items
                            selectedCount: selectedScanArr.count
                        }
                    }
                    HeaderCell{ text: qsTr("ID"); Layout.preferredWidth: 44 }
                    HeaderCell{ text: qsTr("Name"); Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.horizontalStretchFactor: 12 }
                    HeaderCell{ text: qsTr("Description"); Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.horizontalStretchFactor: 10 }
                }
                model: DelegateModel{
                    id: scanArrModel
                    model: ListModel{ id: scanArrList }
                    groups: [ DelegateModelGroup { id: selectedScanArr; name: "selected"; onCountChanged: root.touched() } ]
                    delegate: ScanArrItem{
                        id: scanArrDel
                        required property int index
                        required property var model
                        itemID: model.arrId
                        name: model.name
                        desc: model.desc
                        current: index === root.currentIndex
                        width: ListView.view.width
                        checkBox.checked: scanArrDel.DelegateModel.inSelected
                        onFocused: root.focusIndex(index, model)
                        onActivated: scanArrWindow.manage(index, model)
                        onSelected: scanArrDel.DelegateModel.inSelected = !scanArrDel.DelegateModel.inSelected
                    }
                }
                footerPositioning: ListView.OverlayFooter
                footer: Rectangle{
                    width: ListView.view.width
                    height: 35
                    color: Material.accent
                    z: 2
                    Text{
                        anchors.centerIn: parent
                        text: qsTr("%1 arrangements  •  %2 selected").arg(scanArrModel.count).arg(selectedScanArr.count)
                        font.pointSize: 11
                        font.family: "Montserrat SemiBold"
                        color: sensetool.onAccent
                    }
                }
                Text{
                    anchors.centerIn: parent
                    visible: list.count === 0
                    width: parent.width * 0.8
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: qsTr("No arrangements yet. Add one, then click it to choose its scan steps.")
                    color: Material.foreground
                    opacity: 0.6
                    font.pixelSize: 14
                }
            }
        }
    }
}
