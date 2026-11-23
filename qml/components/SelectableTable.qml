pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

// A list with a header, a checkbox per row, select-all, optional filtering,
// optional drag-to-reorder, a footer and an empty-state hint.
//
//   columns: [{title, width | fraction | stretch}]   header and TableCell sizes
//   row:     Component whose root is a TableRow holding TableCells sized by `columns`.
//
// The table owns selection; pages read selectedIndexes() and react to
// activated (double-click), tapped (single click) and moveRequested (drag).
ShadowRect{
    id: table
    property var model: null
    property Component row: null
    property var columns: []
    property bool reorderable: false
    property string sectionProperty: ""
    // function(rowModel) -> bool; null shows every row
    property var filter: null
    property string emptyText: ""
    property string footerText: qsTr("%1 items  •  %2 selected").arg(totalCount).arg(selectedCount)
    // rows shown highlighted (e.g. the arrangement shown in the Scan List)
    property int currentIndex: -1

    readonly property int selectedCount: selectedGroup.count
    readonly property int shownCount: shownGroup.count
    readonly property int totalCount: delegateModel.items.count
    readonly property alias view: list

    signal activated(int index)
    signal tapped(int index)
    signal moveRequested(int from, int to)

    color: Material.background

    function selectedIndexes(){
        let out = []
        for(let i = 0; i < selectedGroup.count; i++) out.push(selectedGroup.get(i).itemsIndex)
        return out.sort((a, b) => a - b)
    }
    // select-all acts on the rows shown (respects the filter)
    function setAll(on){
        for(let i = 0; i < shownGroup.count; i++) shownGroup.get(i).inSelected = on
    }
    function toggleAll(){ setAll(selectedGroup.count < shownGroup.count) }
    function select(indexes){
        let want = new Set(indexes)
        for(let i = 0; i < delegateModel.items.count; i++)
            delegateModel.items.get(i).inSelected = want.has(i)
    }
    // row index of a delegate (the drag source of a reorder)
    function indexOf(delegate){ return delegate ? delegate["index"] : -1 }
    function refilter(){
        for(let i = 0; i < delegateModel.items.count; i++){
            let it = delegateModel.items.get(i)
            let ok = !table.filter || table.filter(it.model)
            it.inShown = ok
            if(!ok) it.inSelected = false
        }
    }
    onFilterChanged: refilter()
    Connections{
        target: table.model
        ignoreUnknownSignals: true
        function onModelReset(){ if(table.filter) Qt.callLater(table.refilter) }
        function onRowsInserted(){ if(table.filter) Qt.callLater(table.refilter) }
        function onDataChanged(){ if(table.filter) Qt.callLater(table.refilter) }
    }

    ListView{
        id: list
        // what rows use to reach the table (TableRow.table)
        readonly property var owner: table
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
                    anchors.centerIn: parent
                    rows: shownGroup
                    selectedCount: selectedGroup.count
                    onClicked: table.setAll(checkState === Qt.Checked)
                }
            }
            Repeater{
                model: table.columns
                HeaderCell{ required property var modelData; spec: modelData; listWidth: list.width }
            }
            HeaderCell{ visible: table.reorderable; spec: ({width: 45}) }
        }
        section.property: table.sectionProperty
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
        model: DelegateModel{
            id: delegateModel
            model: table.model
            filterOnGroup: "shown"
            groups: [
                DelegateModelGroup { id: selectedGroup; name: "selected" },
                DelegateModelGroup { id: shownGroup; name: "shown"; includeByDefault: true }
            ]
            delegate: table.row
        }
        footerPositioning: ListView.OverlayFooter
        footer: Rectangle{
            width: ListView.view.width
            height: 35
            color: Material.accent
            z: 2
            Text{
                anchors.centerIn: parent
                width: parent.width - 16
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: table.footerText
                font.pointSize: 11
                font.family: "Montserrat SemiBold"
                color: Theme.onAccent
            }
        }
        Text{
            anchors.centerIn: parent
            visible: list.count === 0 && text !== ""
            width: parent.width * 0.7
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: table.emptyText
            color: Material.foreground
            opacity: 0.6
            font.pixelSize: 15
            font.family: "Montserrat Medium"
        }
    }
}
