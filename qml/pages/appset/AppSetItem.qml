import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../components"

// One register row of the Application Setting table.
ShadowRect{
    id: root
    width: 1000
    height: 70
    property string addrHex: "0x000"
    property string name: "ScanState_Ctrl"
    property string size: "1"
    property string layout: "[0] sstat_idle_en = 0x1"
    property string defaultValue: "0x01"
    property string desc: ""
    property string category: ""
    property string issue: ""
    property alias checkBox: checkBox
    signal selected(bool status)

    component Cell: ShadowRect{
        Layout.fillHeight: true
    }
    component CellText: Text{
        anchors.fill: parent
        anchors.margins: 8
        color: Material.foreground
        font.pixelSize: 14
        font.family: "Montserrat Medium"
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    RowLayout{
        anchors.fill: parent
        spacing: 0
        Cell{
            implicitWidth: 40
            CheckBox{
                id: checkBox
                anchors.centerIn: parent
                onClicked: root.selected(checked)
            }
        }
        Cell{
            implicitWidth: 70
            CellText{ text: root.addrHex; font.family: "Monospace" }
        }
        Cell{
            Layout.preferredWidth: root.width * 0.17
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2
                Text{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.name
                    color: Material.foreground
                    font.pixelSize: 14
                    font.family: "Montserrat Medium"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                Text{
                    Layout.fillWidth: true
                    visible: root.issue !== ""
                    text: "⚠ " + root.issue
                    color: "#E53935"
                    font.pixelSize: 11
                    font.family: "Montserrat Medium"
                    elide: Text.ElideRight
                    HoverHandler { id: issueHover }
                    ToolTip.visible: issueHover.hovered
                    ToolTip.text: root.issue
                }
            }
        }
        Cell{
            implicitWidth: 50
            CellText{ text: root.size; horizontalAlignment: Text.AlignHCenter }
        }
        Cell{
            Layout.fillWidth: true
            CellText{
                text: root.layout
                font.family: "Monospace"
                font.pixelSize: 13
                HoverHandler { id: layoutHover }
                ToolTip.visible: layoutHover.hovered && truncated
                ToolTip.text: root.layout
            }
        }
        Cell{
            implicitWidth: 80
            CellText{ text: root.defaultValue; font.family: "Monospace" }
        }
        Cell{
            Layout.preferredWidth: root.width * 0.25
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2
                Text{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.desc
                    color: Material.foreground
                    font.pixelSize: 13
                    font.family: "Montserrat Medium"
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    HoverHandler { id: descHover }
                    ToolTip.visible: descHover.hovered && truncated
                    ToolTip.text: root.desc
                }
                Text{
                    Layout.fillWidth: true
                    visible: root.category !== ""
                    text: root.category
                    color: Material.accent
                    font.pixelSize: 11
                    font.family: "Montserrat SemiBold"
                }
            }
        }
    }
}
