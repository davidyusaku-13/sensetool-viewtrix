import QtQuick
import QtTest
import "../../qml/pages/prjset"

Item {
    width: 800
    height: 600

    // Stand-in for PrjSetModel with only what the window uses, so this tests the
    // window on its own (the real model is covered by the Python tests).
    QtObject {
        id: prj
        property var names: []
        function clear(){ names = [] }
        function addItem(name){ names = names.concat([name]) }
        function indexOfName(name){ return names.indexOf(name) }
        function groups(){ return ["Project Information"] }
        function get(i){ return {"name": names[i], "value": "21", "desc": "", "group": "", "comment": ""} }
    }
    property var saved: []

    PrjSetWindow {
        id: win
        model: prj
        apply: (index, item) => { saved.push([index, item]); return "" }
    }

    TestCase {
        name: "PrjSetWindow"
        when: windowShown

        function init() { prj.clear(); saved = [] }

        function test_open_fills_the_form_and_result_reads_it_back() {
            let item = {"name": "TEST_NAME", "value": "1 + 2", "desc": "testDesc",
                        "group": "testGroup", "comment": "testComment"}
            win.open(3, item)
            verify(win.isEdit)
            compare(win.result(), item)
            win.close()
        }

        function test_add_starts_empty_and_saves() {
            win.open(-1, null)
            verify(!win.isEdit)
            compare(win.result().name, "")
            verify(!win.canSave, "an empty name can't be saved")
            win.close()
        }

        function test_duplicate_names_are_refused() {
            prj.addItem("TX_LEN", "21", "", "", "")
            win.open(-1, {"name": "TX_LEN", "value": "1", "desc": "", "group": "", "comment": ""})
            verify(win.isDuplicate)
            verify(!win.canSave)
            win.close()
            win.open(0, prj.get(0))
            verify(!win.isDuplicate, "an item may keep its own name")
            win.accept()
            compare(saved.length, 1)
            compare(saved[0][0], 0)
        }
    }
}
