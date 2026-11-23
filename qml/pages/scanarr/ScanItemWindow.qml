import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components"

// Add / edit a scan item.
EditWindow {
    id: root
    title: isEdit ? qsTr("Edit Scan Item") : qsTr("Add Scan Item")
    minimumWidth: 480
    minimumHeight: 360
    property int index: -1
    // (index, name, desc) -> "" or an error from the model (e.g. a duplicate name)
    property var apply: null
    canSave: nameInput.acceptableInput
    save: () => apply ? apply(index, nameInput.text, descInput.text) : ""

    function open(i, item){
        index = i
        isEdit = i !== -1
        nameInput.text = item ? item.name : ""
        descInput.text = item ? item.desc : ""
        show()
        nameInput.forceActiveFocus()
    }

    FieldLabel{ text: qsTr("Scan Name") }
    TextField{
        id: nameInput
        Layout.fillWidth: true
        selectByMouse: true
        validator: RegularExpressionValidator { regularExpression: /[A-Z_][0-9A-Z_]*/ }
    }
    FieldLabel{ text: qsTr("Description") }
    ScrollView{
        Layout.fillWidth: true
        Layout.fillHeight: true
        TextArea{ id: descInput; wrapMode: TextEdit.Wrap; selectByMouse: true }
    }
}
