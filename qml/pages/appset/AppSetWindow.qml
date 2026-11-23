import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../components"

// Add / edit one register and its bit fields.
Window {
    id: root
    title: isEdit ? qsTr("Edit Register") : qsTr("Add Register")
    minimumWidth: 640
    minimumHeight: 640
    modality: Qt.ApplicationModal
    color: Material.background

    signal create(var reg)
    signal modify(int index, var reg)

    property var model: null
    property int index: -1
    property bool isEdit: false
    property var categoryNames: []
    readonly property bool isDuplicate: model !== null && nameInput.text !== ""
                                        && model.indexOfName(nameInput.text, index) !== -1

    function manage(i, reg){
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

    ListModel{ id: fieldList }

    component FormLabel: Text{
        font.family: "Montserrat Medium"
        font.pixelSize: 16
        color: Material.foreground
    }

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        GridLayout{
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 12
            FormLabel{ text: qsTr("Address") }
            TextField{
                id: addrInput
                Layout.fillWidth: true
                placeholderText: qsTr("e.g. 16 or 0x010")
                validator: RegularExpressionValidator { regularExpression: /(0[xX][0-9A-Fa-f]{1,3}|[0-9]{1,4})/ }
                selectByMouse: true
            }
            FormLabel{ text: qsTr("Size (bytes)") }
            ComboBox{
                id: sizeInput
                Layout.fillWidth: true
                model: ["1", "2", "4"]
            }
            FormLabel{ text: qsTr("Name") }
            TextField{
                id: nameInput
                Layout.fillWidth: true
                Layout.columnSpan: 3
                validator: RegularExpressionValidator { regularExpression: /[A-Za-z_][A-Za-z0-9_]*/ }
                selectByMouse: true
            }
            FormLabel{ text: qsTr("Category") }
            ComboBox{
                id: categoryInput
                Layout.fillWidth: true
                Layout.columnSpan: 3
                editable: true
                model: root.categoryNames
            }
            FormLabel{ text: qsTr("Description") }
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
            color: "#E53935"
            font.family: "Montserrat"
            font.pixelSize: 13
        }
        RowLayout{
            Layout.fillWidth: true
            FormLabel{ text: qsTr("Bit fields"); Layout.fillWidth: true }
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
                required property int index
                required property var model
                width: ListView.view.width
                spacing: 6
                TextField{
                    Layout.fillWidth: true
                    text: model.name
                    onTextEdited: fieldList.setProperty(index, "name", text)
                    validator: RegularExpressionValidator { regularExpression: /[A-Za-z_][A-Za-z0-9_]*/ }
                    selectByMouse: true
                }
                TextField{
                    Layout.preferredWidth: 60
                    text: model.msb
                    onTextEdited: fieldList.setProperty(index, "msb", text)
                    validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }
                }
                TextField{
                    Layout.preferredWidth: 60
                    text: model.lsb
                    onTextEdited: fieldList.setProperty(index, "lsb", text)
                    validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }
                }
                TextField{
                    Layout.preferredWidth: 90
                    text: model.dflt
                    placeholderText: "0"
                    onTextEdited: fieldList.setProperty(index, "dflt", text)
                    validator: RegularExpressionValidator { regularExpression: /(0[xX][0-9A-Fa-f]*|0[bB][01]*|[0-9]*)/ }
                }
                RoundButton{
                    Layout.preferredWidth: 40
                    icon.source: "qrc:/images/trash"
                    flat: true
                    onClicked: fieldList.remove(index)
                }
            }
        }
        RowLayout{
            Layout.alignment: Qt.AlignRight
            spacing: 5
            RoundButton{
                implicitWidth: 80
                text: root.isEdit ? qsTr("Save") : qsTr("Add")
                enabled: addrInput.acceptableInput && nameInput.acceptableInput && !root.isDuplicate
                onClicked: {
                    if(root.isEdit) root.modify(root.index, root.result())
                    else root.create(root.result())
                    root.close()
                }
            }
            RoundButton{
                implicitWidth: 80
                text: qsTr("Cancel")
                onClicked: root.close()
            }
        }
    }
}
