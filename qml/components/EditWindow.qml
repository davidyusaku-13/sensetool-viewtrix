import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

// One look and behaviour for every add/edit window: content on top, an error
// line, Save/Add and Cancel. Esc cancels, Ctrl+Enter saves.
//
// `save` is a function returning "" on success (the window closes) or an
// error to show (the window stays open), so model validation shows up here.
Window {
    id: root
    default property alias content: body.data
    property bool isEdit: false
    property bool canSave: true
    property var save: null
    property string error: ""
    readonly property string saveText: isEdit ? qsTr("Save") : qsTr("Add")

    modality: Qt.ApplicationModal
    color: Material.background
    Material.theme: Theme.theme
    Material.accent: Theme.accent
    width: minimumWidth
    height: minimumHeight

    function accept(){
        if(!canSave) return
        let err = save ? save() : ""
        if(err){ error = err; return }
        error = ""
        close()
    }
    onVisibleChanged: if(visible) error = ""

    Shortcut { sequences: ["Esc"]; enabled: root.visible; onActivated: root.close() }
    Shortcut { sequences: ["Ctrl+Return", "Ctrl+Enter"]; enabled: root.visible; onActivated: root.accept() }

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12
        ColumnLayout{
            id: body
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
        }
        Text{
            Layout.fillWidth: true
            visible: root.error !== ""
            text: "⚠ " + root.error
            wrapMode: Text.Wrap
            color: Theme.error
            font.family: "Montserrat Medium"
            font.pixelSize: 13
        }
        RowLayout{
            Layout.alignment: Qt.AlignRight
            spacing: 6
            ToolbarBtn{
                text: root.saveText
                primary: true
                enabled: root.canSave
                onClicked: root.accept()
            }
            ToolbarBtn{
                text: qsTr("Cancel")
                onClicked: root.close()
            }
        }
    }
}
