pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

// Base of every SelectableTable row: the checkbox, the optional drag handle,
// click/double-click and drop handling. A row type puts its TableCells inside:
//
//   TableRow { id: root; height: 44
//       TableCell { spec: root.columns[0]; listWidth: root.listWidth; text: root.row.name } }
//
// It is the delegate itself (no Loader), so its bindings go away with it.
Item{
    id: wrap
    required property var model
    required property int index
    default property alias cells: cellsRow.data

    // The SelectableTable this row belongs to (its ListView exposes it as `owner`,
    // which the linter can't see on a plain ListView).
    readonly property var table: ListView.view ? ListView.view.owner : null // qmllint disable missing-property
    readonly property var row: model
    readonly property int rowIndex: index
    readonly property var columns: table ? table.columns : []
    readonly property real listWidth: ListView.view ? ListView.view.width : 0
    // The linter doesn't know the DelegateModel attached property.
    readonly property bool selected: DelegateModel.inSelected // qmllint disable missing-property
    function setSelected(on){ DelegateModel.inSelected = on } // qmllint disable missing-property

    width: ListView.view ? ListView.view.width : 0
    implicitHeight: 44

    // body is lifted out of the list while dragging
    Item{
        id: body
        width: wrap.width
        height: wrap.height
        states: State {
            when: handle.pressed
            ParentChange { target: body; parent: wrap.ListView.view }
        }
        Drag.active: handle.pressed
        Drag.source: wrap
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
        // under the cells: clicks on empty cell space select/open the row
        MouseArea{
            anchors.fill: parent
            onClicked: if(wrap.table) wrap.table.tapped(wrap.index)
            onDoubleClicked: if(wrap.table) wrap.table.activated(wrap.index)
        }
        Rectangle{
            anchors.fill: parent
            z: 1
            color: Material.accent
            opacity: wrap.table && wrap.index === wrap.table.currentIndex ? 0.18 : 0
        }
        RowLayout{
            anchors.fill: parent
            spacing: 0
            ShadowRect{
                Layout.preferredWidth: 40
                Layout.fillHeight: true
                CheckBox{
                    anchors.centerIn: parent
                    checked: wrap.selected
                    onClicked: wrap.setSelected(checked)
                }
            }
            RowLayout{
                id: cellsRow
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
            }
            ShadowRect{
                visible: wrap.table ? wrap.table.reorderable : false
                Layout.preferredWidth: 45
                Layout.fillHeight: true
                Image{
                    anchors.centerIn: parent
                    source: "qrc:/images/drag"
                    sourceSize.height: 15
                    opacity: 0.7
                }
                MouseArea{
                    id: handle
                    anchors.fill: parent
                    enabled: wrap.table ? wrap.table.reorderable : false
                    drag.target: pressed ? body : undefined
                    drag.axis: Drag.YAxis
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                }
            }
        }
    }
    DropArea{
        anchors.fill: parent
        enabled: wrap.table ? wrap.table.reorderable : false
        onEntered: (drag) => {
            if(drag.source !== wrap && wrap.table) wrap.table.moveRequested(wrap.table.indexOf(drag.source), wrap.index)
        }
    }
}
