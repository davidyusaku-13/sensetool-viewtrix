import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../components"

// Add / edit one Project Setting item.
EditWindow {
    id: root
    title: isEdit ? qsTr("Edit Item") : qsTr("Add Item")
    minimumWidth: 520
    minimumHeight: 600

    // The PrjSetModel being edited: duplicate checks and group suggestions.
    property var model: null
    property int index: -1
    property var groupNames: []
    // Called with (index, item) when saved; -1 means a new item. Returns "" or an error.
    property var apply: null

    readonly property int duplicateIndex: (model && nameInput.text !== "") ? model.indexOfName(nameInput.text) : -1
    readonly property bool isDuplicate: duplicateIndex !== -1 && duplicateIndex !== index

    canSave: nameInput.acceptableInput && valueInput.acceptableInput && !isDuplicate
    save: () => apply ? apply(index, result()) : ""

    function open(i, item){
        index = i
        isEdit = i !== -1
        groupNames = model ? model.groups() : []
        nameInput.text = item ? item.name : ""
        valueInput.text = item ? item.value : ""
        groupInput.editText = item ? item.group : ""
        descInput.text = item ? item.desc : ""
        commentInput.text = item ? item.comment : ""
        show()
        nameInput.forceActiveFocus()
    }
    function result(){
        return {"name": nameInput.text, "value": valueInput.text, "desc": descInput.text,
                "group": groupInput.editText, "comment": commentInput.text}
    }

    FieldLabel{ text: qsTr("Name") }
    TextField{
        id: nameInput
        Layout.fillWidth: true
        selectByMouse: true
        // A valid C macro name: must not start with a digit.
        validator: RegularExpressionValidator { regularExpression: /[A-Z_][0-9A-Z_]*/ }
    }
    Text{
        visible: root.isDuplicate
        text: qsTr("An item with this name already exists")
        color: Theme.error
        font.pixelSize: 13
    }
    FieldLabel{ text: qsTr("Value") }
    TextField{
        id: valueInput
        Layout.fillWidth: true
        selectByMouse: true
        // Numbers, macro names, strings and all C operators.
        validator: RegularExpressionValidator { regularExpression: /[0-9a-zA-Z_ ()*\/%+\-<>=!&|^~?:.,"']+/ }
    }
    FieldLabel{ text: qsTr("Group") }
    ComboBox{
        id: groupInput
        Layout.fillWidth: true
        editable: true
        model: root.groupNames
    }
    FieldLabel{ text: qsTr("Description") }
    ScrollView{
        Layout.fillWidth: true
        Layout.fillHeight: true
        TextArea{ id: descInput; wrapMode: TextEdit.Wrap; selectByMouse: true }
    }
    FieldLabel{ text: qsTr("Comment (not written to prjset.h)") }
    TextField{
        id: commentInput
        Layout.fillWidth: true
        selectByMouse: true
    }
}
