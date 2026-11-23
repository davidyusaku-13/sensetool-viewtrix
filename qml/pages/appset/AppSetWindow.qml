pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../../components"

// Add / edit one register and its bit fields.
EditWindow {
    id: root
    title: isEdit ? qsTr("Edit Register") : qsTr("Add Register")
    minimumWidth: 640
    minimumHeight: 640

    // The AppSetModel being edited (suggestions, duplicate and live checks).
    property var model: null
    property int index: -1
    // Called with (index, register) when saved; -1 means a new one. Returns "" or an error.
    property var apply: null
    canSave: addrInput.acceptableInput && nameInput.acceptableInput && !isDuplicate
    save: () => apply ? apply(index, result()) : ""
    property var categoryNames: []
    // Bumped on every edit so the live problem check re-runs.
    property int rev: 0
    readonly property string liveIssue: { rev; return (model && visible && nameInput.text !== "") ? model.checkRegister(index, result()) : "" }
    function addrOther(text){
        let a = /^0[xX]/.test(text) ? parseInt(text, 16) : parseInt(text, 10)
        if(isNaN(a)) return ""
        return /^0[xX]/.test(text) ? "= " + a : "= 0x" + a.toString(16).toUpperCase().padStart(3, "0")
    }
    readonly property bool isDuplicate: model !== null && nameInput.text !== ""
                                        && model.indexOfName(nameInput.text, index) !== -1

    function open(i, reg){
        isEdit = i !== -1
        index = i
        categoryNames = model ? model.categories() : []
        addrInput.text = reg ? reg.addr : (model ? model.nextFreeAddress() : "0")
        nameInput.text = reg ? reg.name : ""
        sizeInput.currentIndex = Math.max(0, ["1", "2", "4"].indexOf(reg ? String(reg.size) : "1"))
        categoryInput.editText = reg ? reg.category : ""
        descInput.text = reg ? reg.desc : ""
        fieldList.clear()
        let fields = reg ? reg.fields : []
        for(let f of fields){
            fieldList.append({"name": f.name, "msb": String(f.msb), "lsb": String(f.lsb), "dflt": f["default"]})
        }
        if(!reg) fieldList.append({"name": "", "msb": "7", "lsb": "0", "dflt": ""})
        root.show()
        nameInput.forceActiveFocus()
    }
    function result(){
        let fields = []
        for(let i=0; i<fieldList.count; i++){
            let f = fieldList.get(i)
            fields.push({"name": f.name, "msb": f.msb, "lsb": f.lsb, "default": f.dflt})
        }
        return {"addr": addrInput.text, "name": nameInput.text, "size": sizeInput.currentText,
                "category": categoryInput.editText, "desc": descInput.text, "fields": fields}
    }

    ListModel{
        id: fieldList
        onDataChanged: root.rev++
        onCountChanged: root.rev++
    }

    ColumnLayout{
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 10
        GridLayout{
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 12
            FieldLabel{ text: qsTr("Address") }
            TextField{
                id: addrInput
                Layout.fillWidth: true
                placeholderText: qsTr("e.g. 16 or 0x010")
                validator: RegularExpressionValidator { regularExpression: /(0[xX][0-9A-Fa-f]{1,3}|[0-9]{1,4})/ }
                selectByMouse: true
                onTextChanged: root.rev++
                // the same address in the other base, matching the table's hex column
                Text{
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.addrOther(addrInput.text)
                    color: Material.foreground
                    opacity: 0.55
                    font.family: "Monospace"
                    font.pixelSize: 13
                }
            }
            FieldLabel{ text: qsTr("Size (bytes)") }
            ComboBox{
                id: sizeInput
                Layout.fillWidth: true
                model: ["1", "2", "4"]
                onCurrentIndexChanged: root.rev++
            }
            FieldLabel{ text: qsTr("Name") }
            TextField{
                id: nameInput
                Layout.fillWidth: true
                Layout.columnSpan: 3
                validator: RegularExpressionValidator { regularExpression: /[A-Za-z_][A-Za-z0-9_]*/ }
                selectByMouse: true
            }
            FieldLabel{ text: qsTr("Category") }
            ComboBox{
                id: categoryInput
                Layout.fillWidth: true
                Layout.columnSpan: 3
                editable: true
                model: root.categoryNames
            }
            FieldLabel{ text: qsTr("Description") }
            TextField{
                id: descInput
                Layout.fillWidth: true
                Layout.columnSpan: 3
                selectByMouse: true
            }
        }
        Text{
            visible: root.isDuplicate
            text: qsTr("A register with this name already exists")
            color: Theme.error
            font.family: "Montserrat"
            font.pixelSize: 13
        }
        RowLayout{
            Layout.fillWidth: true
            FieldLabel{ text: qsTr("Bit fields"); Layout.fillWidth: true }
            Text{
                text: qsTr("bits %1..0, unused bits are reserved").arg(parseInt(sizeInput.currentText) * 8 - 1)
                color: Material.foreground
                opacity: 0.6
                font.pixelSize: 12
            }
            Button{
                text: qsTr("Add field")
                onClicked: fieldList.append({"name": "", "msb": "0", "lsb": "0", "dflt": ""})
            }
        }
        RowLayout{
            Layout.fillWidth: true
            spacing: 6
            Repeater{
                model: [[qsTr("Field name"), 0], [qsTr("MSB"), 60], [qsTr("LSB"), 60], [qsTr("Default"), 90], ["", 40]]
                Text{
                    required property var modelData
                    text: modelData[0]
                    Layout.fillWidth: modelData[1] === 0
                    Layout.preferredWidth: modelData[1]
                    color: Material.foreground
                    opacity: 0.7
                    font.pixelSize: 12
                }
            }
        }
        ListView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: fieldList
            delegate: RowLayout{
                id: fieldRow
                required property int index
                required property var model
                width: ListView.view.width
                spacing: 6
                TextField{
                    Layout.fillWidth: true
                    text: fieldRow.model.name
                    onTextEdited: fieldList.setProperty(fieldRow.index, "name", text)
                    validator: RegularExpressionValidator { regularExpression: /[A-Za-z_][A-Za-z0-9_]*/ }
                    selectByMouse: true
                }
                TextField{
                    Layout.preferredWidth: 60
                    text: fieldRow.model.msb
                    onTextEdited: fieldList.setProperty(fieldRow.index, "msb", text)
                    validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }
                }
                TextField{
                    Layout.preferredWidth: 60
                    text: fieldRow.model.lsb
                    onTextEdited: fieldList.setProperty(fieldRow.index, "lsb", text)
                    validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }
                }
                TextField{
                    Layout.preferredWidth: 90
                    text: fieldRow.model.dflt
                    onTextEdited: fieldList.setProperty(fieldRow.index, "dflt", text)
                    validator: RegularExpressionValidator { regularExpression: /(0[xX][0-9A-Fa-f]*|0[bB][01]*|[0-9]*)/ }
                }
                RoundButton{
                    Layout.preferredWidth: 40
                    icon.source: "qrc:/images/trash"
                    flat: true
                    onClicked: fieldList.remove(fieldRow.index)
                }
            }
        }
        // Live check: the same problems the table would show in red after saving.
        Text{
            Layout.fillWidth: true
            visible: root.liveIssue !== ""
            text: "\u26A0 " + root.liveIssue
            wrapMode: Text.Wrap
            color: Theme.error
            font.family: "Montserrat Medium"
            font.pixelSize: 13
        }
    }
}
