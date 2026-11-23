import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components"

// Add / edit a scan arrangement (its ID, name and description; steps are edited in the Scan List).
EditWindow {
    id: root
    title: isEdit ? qsTr("Edit Scan Arrangement") : qsTr("Add Scan Arrangement")
    minimumWidth: 480
    minimumHeight: 420
    property int index: -1
    // (index, id, name, desc) -> "" or an error from the model
    property var apply: null
    canSave: idInput.acceptableInput && nameInput.acceptableInput
    save: () => apply ? apply(index, idInput.text, nameInput.text, descInput.text) : ""

    function open(i, arrangement, nextId){
        index = i
        isEdit = i !== -1
        idInput.text = arrangement ? arrangement.arrId : (nextId || "")
        nameInput.text = arrangement ? arrangement.name : ""
        descInput.text = arrangement ? arrangement.desc : ""
        show()
        nameInput.forceActiveFocus()
    }

    FieldLabel{ text: qsTr("ID") }
    TextField{
        id: idInput
        Layout.fillWidth: true
        selectByMouse: true
        validator: RegularExpressionValidator { regularExpression: /[0-9]+/ }
    }
    FieldLabel{ text: qsTr("Scan Arrangement Name") }
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
