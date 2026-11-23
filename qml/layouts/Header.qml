import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"

ShadowRect{
    id: header
    Layout.fillWidth: true
    Layout.preferredHeight: 56
    Layout.maximumHeight: 56
    readonly property alias index: headerList.currentIndex
    // dependencies
    property var project: null     // ProjectController
    property bool folded: true
    signal toggleSidebar()
    signal openRequested()
    signal saveRequested()
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
            text: header.folded ? qsTr("Show workspace names") : qsTr("Hide workspace names")
            onClicked: header.toggleSidebar()
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
            text: (header.project.name !== "" ? header.project.name : qsTr("Untitled project"))
                  + (header.project.dirty ? "  ●" : "")
            elide: Text.ElideMiddle
            color: Material.foreground
            opacity: 0.75
            font.family: "Montserrat Medium"
            font.pixelSize: 15
            HoverHandler{ id: fileHover }
            ToolTip.visible: fileHover.hovered
            ToolTip.text: (header.project.path !== "" ? header.project.path : qsTr("Not saved yet"))
                          + (header.project.dirty ? qsTr("\nUnsaved changes") : "")
        }
        HeaderBtn{
            text: qsTr("Open")
            ToolTip.text: qsTr("Open a project: prjcfg.yaml, or import prjcfg.xlsx (Ctrl+O)")
            onClicked: header.openRequested()
        }
        HeaderBtn{
            text: qsTr("Save")
            ToolTip.text: qsTr("Save the project (Ctrl+S). Save As: Ctrl+Shift+S")
            primary: header.project.dirty
            onClicked: header.saveRequested()
        }
        HeaderBtn{
            text: "↶"
            font.pixelSize: 20
            enabled: header.project.canUndo
            ToolTip.text: qsTr("Undo (Ctrl+Z)")
            onClicked: header.project.undo()
        }
        HeaderBtn{
            text: "↷"
            font.pixelSize: 20
            enabled: header.project.canRedo
            ToolTip.text: qsTr("Redo (Ctrl+Shift+Z)")
            onClicked: header.project.redo()
        }
        HeaderList{
            id: headerList
            Layout.leftMargin: 10
        }
    }
}
