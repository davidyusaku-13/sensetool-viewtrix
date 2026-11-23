pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../components"

// Pick scan items to insert as steps of the current arrangement.
EditWindow {
    id: root
    title: qsTr("Add Scan Steps")
    minimumWidth: 480
    minimumHeight: 480
    // the scan items list model (ScanArrModel.items)
    property var items: null
    // (names) -> "" or an error
    property var apply: null
    canSave: table.selectedCount > 0
    save: () => {
        let names = table.selectedIndexes().map(i => root.items.get(i).name)
        return apply ? apply(names) : ""
    }

    function open(){
        table.setAll(false)
        show()
    }

    FieldLabel{ text: qsTr("Scan Items") }
    SelectableTable{
        id: table
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: root.items
        columns: [{title: qsTr("Name"), stretch: 1}]
        row: Component{
            TableRow{
                id: pickRow
                height: 38
                TableCell{ spec: pickRow.columns[0]; listWidth: pickRow.listWidth; text: pickRow.row ? pickRow.row.name : "" }
            }
        }
        footerText: qsTr("%1 of %2 selected").arg(selectedCount).arg(totalCount)
        onActivated: (i) => { table.select([i]); root.accept() }
    }
}
