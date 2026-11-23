import QtQuick
import QtQuick.Layouts
import QtTest
import "../../qml/components"

Item {
    width: 600
    height: 400

    ListModel {
        id: people
        ListElement { name: "ada"; group: "A" }
        ListElement { name: "bob"; group: "A" }
        ListElement { name: "cy"; group: "B" }
    }
    Component {
        id: rowComponent
        TableRow {
            id: r
            height: 40
            TableCell { spec: r.columns[0]; listWidth: r.listWidth; text: r.row ? r.row.name : "" }
        }
    }
    SelectableTable {
        id: table
        anchors.fill: parent
        model: people
        row: rowComponent
        columns: [{title: "Name", stretch: 1}]
        emptyText: "nothing"
    }
    SignalSpy { id: activatedSpy; target: table; signalName: "activated" }

    TestCase {
        name: "SelectableTable"
        when: windowShown

        function init() { table.filter = null; table.setAll(false) }

        function test_select_all_and_indexes() {
            compare(table.totalCount, 3)
            table.setAll(true)
            compare(table.selectedCount, 3)
            compare(table.selectedIndexes(), [0, 1, 2])
            table.toggleAll()
            compare(table.selectedCount, 0)
            table.select([2, 0])
            compare(table.selectedIndexes(), [0, 2])
        }

        function test_filter_hides_and_deselects() {
            table.setAll(true)
            table.filter = (m) => m.group === "A"
            compare(table.shownCount, 2)
            compare(table.selectedIndexes(), [0, 1], "hidden rows are deselected")
            table.toggleAll()
            compare(table.selectedCount, 0)
            table.toggleAll()
            compare(table.selectedCount, 2, "select-all only selects the rows shown")
            table.filter = null
            compare(table.shownCount, 3)
        }

        function test_double_click_activates_the_row() {
            activatedSpy.clear()
            let first = table.view.itemAtIndex(1)
            verify(first)
            mouseDoubleClickSequence(first, first.width / 2, first.height / 2)
            compare(activatedSpy.count, 1)
            compare(activatedSpy.signalArguments[0][0], 1)
        }
    }
}
