import QtQuick
import QtTest
import "../../qml/components"

Item {
    width: 400
    height: 300
    property string answer: ""
    property int saves: 0

    EditWindow {
        id: win
        minimumWidth: 300
        minimumHeight: 200
        save: () => { saves++; return answer }
    }

    TestCase {
        name: "EditWindow"
        when: windowShown

        function test_an_error_keeps_the_window_open() {
            win.show()
            answer = "name already exists"
            win.accept()
            verify(win.visible)
            compare(win.error, "name already exists")
            answer = ""
            win.accept()
            verify(!win.visible)
            compare(saves, 2)
        }

        function test_cannot_save_while_invalid() {
            saves = 0
            win.canSave = false
            win.show()
            win.accept()
            compare(saves, 0)
            verify(win.visible)
            win.close()
            win.canSave = true
        }

        function test_labels() {
            win.isEdit = false
            compare(win.saveText, "Add")
            win.isEdit = true
            compare(win.saveText, "Save")
        }
    }
}
