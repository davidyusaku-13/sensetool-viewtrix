import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../components"

Window {
    id: root
    title: isEdit === false ? qsTr("Add Item") : qsTr("Edit Item")
    minimumWidth: 500
    minimumHeight: 680
    maximumWidth: 500
    maximumHeight: 680
    modality: Qt.ApplicationModal

    signal create(var object)
    signal modify(int index, var object)

    // The PrjSetModel being edited; used for duplicate checks and group suggestions.
    property var model: null
    property PrjSetObject object: PrjSetObject{}
    property int index: -1
    property bool isEdit: false
    property var groupNames: []
    readonly property int duplicateIndex: (model && object.name !== "") ? model.indexOfName(object.name) : -1
    readonly property bool isDuplicate: duplicateIndex !== -1 && duplicateIndex !== index
    property HoverHandler cursor: HoverHandler{
        cursorShape: Qt.IBeamCursor
    }

    function manage(i: int, item: var){
        if(i !== -1){
            isEdit = true
            object.set(item)
        }else {
            isEdit = false
            root.object.reset()
        }
        index = i
        groupNames = model ? model.groups() : []
        groupInput.editText = root.object.group
        root.show()
    }
    ConfirmWindow{
        id: confirmWindow
        onSaved: (state) => {
                     if(state === true){
                         root.modify(root.index, root.object.get())
                         root.object.reset()
                         root.close()
                     }
                 }
    }
    ShadowRect{
        anchors.fill: parent
        ColumnLayout{
            anchors.fill: parent
            spacing: 14
            anchors.margins: 20
            //item
            ColumnLayout{
                Layout.fillWidth: true
                Text{
                    text: qsTr("Name")
                    font.family: "Montserrat Medium"
                    font.pixelSize: 20
                    color: Material.foreground
                }
                Frame{
                    Layout.fillWidth: true
                    Layout.preferredHeight: itemInput.lineCount*childrenRect.height
                    TextInput{
                        id: itemInput
                        anchors.fill: parent
                        text: root.object.name
                        onTextChanged: root.object.name = text
                        color: Material.foreground
                        font.family: "Montserrat"
                        font.pixelSize: 17
                        wrapMode: Text.Wrap
                        clip: true
                        autoScroll: false
                        selectByMouse: true
                        // A valid C macro name: must not start with a digit.
                        validator: RegularExpressionValidator {regularExpression: /[A-Z_][0-9A-Z_]*/}
                        HoverHandler {
                            cursorShape: Qt.IBeamCursor
                        }
                    }
                }
                Text{
                    visible: root.isDuplicate
                    text: qsTr("An item with this name already exists")
                    color: "#E53935"
                    font.family: "Montserrat"
                    font.pixelSize: 13
                }
            }
            //value
            ColumnLayout{
                Layout.fillWidth: true
                Text{
                    text: qsTr("Value")
                    font.family: "Montserrat Medium"
                    font.pixelSize: 20
                    color: Material.foreground
                }
                Frame{
                    Layout.fillWidth: true
                    Layout.preferredHeight: valueInput.lineCount*childrenRect.height
                    TextInput{
                        id: valueInput
                        anchors.fill: parent
                        text: root.object.value
                        onTextChanged: root.object.value = text
                        color: Material.foreground
                        font.family: "Montserrat"
                        font.pixelSize: 17
                        wrapMode: Text.Wrap
                        clip: true
                        autoScroll: false
                        selectByMouse: true
                        // Numbers, macro names, strings and all C operators.
                        validator: RegularExpressionValidator {regularExpression: /[0-9a-zA-Z_ ()*\/%+\-<>=!&|^~?:.,"']+/}
                        HoverHandler {
                            cursorShape: Qt.IBeamCursor
                        }
                    }
                }
            }
            //group
            ColumnLayout{
                Layout.fillWidth: true
                Text{
                    text: qsTr("Group")
                    font.family: "Montserrat Medium"
                    font.pixelSize: 20
                    color: Material.foreground
                }
                ComboBox{
                    id: groupInput
                    Layout.fillWidth: true
                    editable: true
                    model: root.groupNames
                    onEditTextChanged: root.object.group = editText
                }
            }
            //desc
            ColumnLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text{
                    text: qsTr("Description")
                    font.family: "Montserrat Medium"
                    font.pixelSize: 20
                    color: Material.foreground
                }
                Frame{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    TextEdit{
                        anchors.fill: parent
                        text: root.object.desc
                        onTextChanged: root.object.desc = text
                        color: Material.foreground
                        font.family: "Montserrat"
                        font.pixelSize: 17
                        wrapMode: Text.Wrap
                        selectByMouse: true
                    }
                }
            }
            //comment
            ColumnLayout{
                Layout.fillWidth: true
                Text{
                    text: qsTr("Comment (not written to prjset.h)")
                    font.family: "Montserrat Medium"
                    font.pixelSize: 20
                    color: Material.foreground
                }
                TextField{
                    Layout.fillWidth: true
                    text: root.object.comment
                    onTextChanged: root.object.comment = text
                    selectByMouse: true
                }
            }
            //button
            RowLayout{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: 5
                //add
                RoundButton {
                    implicitWidth: 80
                    text: root.isEdit ? qsTr("Save") : qsTr("Add")
                    enabled: itemInput.acceptableInput && valueInput.acceptableInput && !root.isDuplicate
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    onClicked: {
                        if (root.isEdit == true) {
                            confirmWindow.show()
                        } else {
                            root.create(root.object.get())
                            root.object.reset()
                            root.close()
                        }
                    }
                }
                //cancel
                RoundButton {
                    implicitWidth: 80
                    text: qsTr("Cancel")
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    onClicked: {
                        root.object.reset()
                        root.close()
                    }
                }
            }
        }
    }
}
