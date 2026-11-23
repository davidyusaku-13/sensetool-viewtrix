import QtQuick
import QtTest
import PrjSetModel
import "../../qml/pages/prjset"

// The Project Setting page with the real model and the real prjcfg.yaml.
Item {
    width: 1100
    height: 700

    PrjSetModel { id: prj }
    QtObject { id: history; function addHistory() {} }
    PrjSetPage { id: page; anchors.fill: parent; model: prj; history: history }

    TestCase {
        name: "PrjSetPage"
        when: windowShown

        function initTestCase() {
            compare(prj.importFile(Qt.resolvedUrl("../../yaml/prjcfg.yaml")), "")
            compare(page.table.totalCount, 140)
        }
        function cleanup() { page.searchText = ""; page.problemsOnly = false }

        // Regression: rows removed by a filter crashed the app, and the search
        // handler read a stale "filtering" flag so it never filtered at all.
        function test_search_filters_and_survives_redraw() {
            page.searchText = "fwcfg"
            verify(page.table.shownCount > 0 && page.table.shownCount < 140, "shown " + page.table.shownCount)
            waitForRendering(page)
            wait(100)
            page.searchText = ""
            compare(page.table.shownCount, 140)
        }

        function test_problems_only() {
            prj.edit(1, "RX_LEN", "TX_LEN +", "", "Project Information", "")
            page.problemsOnly = true
            verify(page.table.shownCount >= 1)
            compare(page.table.shownCount, prj.issueCount)
            prj.edit(1, "RX_LEN", "40", "", "Project Information", "")
        }

        function test_select_all_only_selects_what_is_shown() {
            page.searchText = "fwcfg"
            page.table.toggleAll()
            compare(page.table.selectedCount, page.table.shownCount)
            page.table.setAll(false)
        }
    }
}
