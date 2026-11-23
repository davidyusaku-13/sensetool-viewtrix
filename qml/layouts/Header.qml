import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"

ShadowRect{
    id: header
    Layout.fillWidth: true
    Layout.preferredHeight: 56
    Layout.maximumHeight: 56
    readonly property alias index: headerList.currentIndex
    color: Material.background

    component HeaderBtn: ToolbarBtn{
        Layout.preferredHeight: 42
        font.pixelSize: 14
    }

    //header button
    RowLayout{
        anchors.fill: parent
        anchors.leftMargin: 7
        anchors.rightMargin: 7
        spacing: 6
        MyButton{
            id: menuBtn
            display: AbstractButton.IconOnly
            icon.source: "qrc:/images/menu-icon2"
            text: sidebar.folded ? qsTr("Show workspace names") : qsTr("Hide workspace names")
            onClicked: {
                sidebar.folded = !sidebar.folded
            }
        }
        Text{
            text: qsTr("Sense Tool")
            font.family: "Richard Clean Personal Use"
            font.pixelSize: 35
            color: Material.accent
        }
        // Project file: everything prjcfg.xlsx used to hold.
        Text{
            Layout.leftMargin: 16
            Layout.fillWidth: true
            text: (window.projectName !== "" ? window.projectName : qsTr("Untitled project"))
                  + (window.dirty ? "  ●" : "")
            elide: Text.ElideMiddle
            color: Material.foreground
            opacity: 0.75
            font.family: "Montserrat Medium"
            font.pixelSize: 15
            HoverHandler{ id: fileHover }
            ToolTip.visible: fileHover.hovered
            ToolTip.text: (window.projectPath !== "" ? window.projectPath : qsTr("Not saved yet"))
                          + (window.dirty ? qsTr("\nUnsaved changes") : "")
        }
        HeaderBtn{
            text: qsTr("Open")
            ToolTip.text: qsTr("Open a project: prjcfg.yaml, or import prjcfg.xlsx (Ctrl+O)")
            onClicked: window.openProjectDialog()
        }
        HeaderBtn{
            text: qsTr("Save")
            ToolTip.text: qsTr("Save the project (Ctrl+S). Save As: Ctrl+Shift+S")
            primary: window.dirty
            onClicked: window.saveProject(false)
        }
        HeaderBtn{
            text: "↶"
            font.pixelSize: 20
            enabled: window.canUndo
            ToolTip.text: qsTr("Undo (Ctrl+Z)")
            onClicked: window.undo()
        }
        HeaderBtn{
            text: "↷"
            font.pixelSize: 20
            enabled: window.canRedo
            ToolTip.text: qsTr("Redo (Ctrl+Shift+Z)")
            onClicked: window.redo()
        }
        HeaderList{
            id: headerList
            Layout.leftMargin: 10
        }
    }
}
