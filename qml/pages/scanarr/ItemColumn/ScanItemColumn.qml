import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components"

// Scan items: the eAfeScanID_t enum, in value order.
Item{
    id: root
    property alias scanItemList: scanItemList
    property var confirm: null
    readonly property int selectedCount: selectedScanItem.count
    // Emitted when a scan item is renamed so arrangements can follow.
    signal renamed(string oldName, string newName)
    // Emitted when the selection changes, so page shortcuts act on this column.
    signal touched()

    function moveSelected(delta){
        if(selectedScanItem.count !== 1) return
        let i = selectedScanItem.get(0).itemsIndex
        let j = i + delta
        if(j < 0 || j >= scanItemList.count) return
        scanItemList.move(i, j, 1)
    }
    function addItem(){ scanWindow.manage(-1, null) }
    function editSelected(){
        if(selectedScanItem.count === 1){
            let selected = selectedScanItem.get(0)
            scanWindow.manage(selected.itemsIndex, selected.model)
        }
    }
    function deleteSelected(){
        if(selectedScanItem.count === 0) return
        let rows = []
        for(let i = 0; i < selectedScanItem.count; i++) rows.push(selectedScanItem.get(i).itemsIndex)
        rows.sort((a, b) => b - a)
        root.confirm.ask(qsTr("Delete %1 scan item(s)?").arg(rows.length), () => {
            for(let r of rows) scanItemList.remove(r)
        })
    }
    function toggleAll(){ selectAll.setAll(selectAll.checkState !== Qt.Checked) }

    ScanWindow{
        id: scanWindow
        Material.theme: sensetool.theme
        Material.accent: sensetool.accent
        onCreate: (object) => scanItemList.append(object)
        onModify: (index, object) => {
                      let oldName = scanItemList.get(index).name
                      scanItemList.set(index, object)
                      if(oldName !== object.name) root.renamed(oldName, object.name)
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
            text: qsTr("Scan Items")
            font.family: "Montserrat SemiBold"
            font.pixelSize: 15
            color: Material.foreground
        }
        // Wraps onto a second line when the column is narrow instead of squashing buttons.
        Flow{
            Layout.fillWidth: true
            spacing: 6
            ToolbarBtn{ text: qsTr("Add"); ToolTip.text: qsTr("Add a scan item (Ctrl+N)"); onClicked: root.addItem() }
            ToolbarBtn{ text: qsTr("Edit"); ToolTip.text: qsTr("Edit (Enter, or double-click)"); enabled: selectedScanItem.count === 1; onClicked: root.editSelected() }
            ToolbarBtn{ text: qsTr("Delete"); ToolTip.text: qsTr("Delete (Del)"); enabled: selectedScanItem.count > 0; onClicked: root.deleteSelected() }
            ToolbarBtn{ text: "▲"; ToolTip.text: qsTr("Move up (lowers its value)"); enabled: selectedScanItem.count === 1; onClicked: root.moveSelected(-1) }
            ToolbarBtn{ text: "▼"; ToolTip.text: qsTr("Move down"); enabled: selectedScanItem.count === 1; onClicked: root.moveSelected(1) }
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
                            rows: scanItemModel.items
                            selectedCount: selectedScanItem.count
                        }
                    }
                    HeaderCell{ text: "#"; Layout.preferredWidth: 36 }
                    HeaderCell{ text: qsTr("Name"); Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.horizontalStretchFactor: 12 }
                    HeaderCell{ text: qsTr("Description"); Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.horizontalStretchFactor: 10 }
                }
                model: DelegateModel{
                    id: scanItemModel
                    model: ListModel{ id: scanItemList }
                    groups: [ DelegateModelGroup { id: selectedScanItem; name: "selected"; onCountChanged: root.touched() } ]
                    delegate: ScanItem{
                        id: scanItemDel
                        required property var model
                        required property int index
                        value: index
                        name: model.name
                        desc: model.desc
                        width: ListView.view.width
                        checkBox.checked: scanItemDel.DelegateModel.inSelected
                        onSelected: scanItemDel.DelegateModel.inSelected = !scanItemDel.DelegateModel.inSelected
                        onActivated: scanWindow.manage(index, model)
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
                        text: qsTr("%1 items  •  %2 selected").arg(scanItemModel.count).arg(selectedScanItem.count)
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
                    text: qsTr("No scan items. The first one must be AFE_END (value 0).")
                    color: Material.foreground
                    opacity: 0.6
                    font.pixelSize: 14
                }
            }
        }
    }
}
