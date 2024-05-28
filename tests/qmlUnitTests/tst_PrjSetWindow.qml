import QtQuick
import QtTest
import "../../qml/pages/prjset"

Item {
    width: 800
    height: 600

    PrjSetWindow {
        id: prjSetWindow
    }

    TestCase {
        name: "PrjSetWindowTestCase"
        when: windowShown

        function test_checkPrjSetWindow() {
            let input = {
                "name": "testName",
                "value": "testValue",
                "desc": "testDesc"
            }
            prjSetWindow.object.set(input)
            let prjSetObj = prjSetWindow.object.get()
            compare(prjSetObj, input, "prjObj does equal input")
        }
    }
}
