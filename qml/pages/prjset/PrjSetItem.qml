import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../../components"

// One Project Setting row (cells only; SelectableTable adds the checkbox and drag handle).
// Columns: Item, Value, Description.
TableRow{
    id: root
    height: 54

    readonly property string issue: row ? row.issue : ""
    // only something this item refers to is wrong, not the item itself
    readonly property bool dependent: row ? row.dependent : false

    component SubText: Text{
        Layout.fillWidth: true
        font.pixelSize: 12
        font.family: "Montserrat Medium"
        elide: Text.ElideRight
    }

    TableCell{
        spec: root.columns[0]
        listWidth: root.listWidth
        ColumnLayout{
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 0
            Item{ Layout.fillHeight: true }
            TableText{ Layout.fillWidth: true; text: root.row ? root.row.name : ""; font.pixelSize: 15 }
            SubText{
                id: issueText
                visible: root.issue !== ""
                text: (root.dependent ? "↳ " : "⚠ ") + root.issue
                color: root.dependent ? Theme.warning : Theme.error
                HoverHandler { id: issueHover }
                HoverTip { show: issueHover.hovered && issueText.truncated; textFor: () => root.issue }
            }
            Item{ Layout.fillHeight: true }
        }
    }
    TableCell{
        spec: root.columns[1]
        listWidth: root.listWidth
        ColumnLayout{
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 0
            Item{ Layout.fillHeight: true }
            TableText{ Layout.fillWidth: true; text: root.row ? root.row.value : ""; font.pixelSize: 15 }
            SubText{
                visible: root.row && root.row.resolved !== ""
                text: "= " + (root.row ? root.row.resolved : "")
                color: Material.accent
            }
            Item{ Layout.fillHeight: true }
        }
    }
    TableCell{
        spec: root.columns[2]
        listWidth: root.listWidth
        RowLayout{
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 6
            spacing: 4
            TableText{
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.row ? root.row.desc : ""
                lines: 2
            }
            // Review comment from the spreadsheet: kept out of the way, shown on hover.
            Text{
                visible: root.row && root.row.comment !== ""
                text: "ⓘ"
                color: Material.foreground
                opacity: commentHover.hovered ? 0.9 : 0.45
                font.pixelSize: 16
                HoverHandler { id: commentHover }
                HoverTip { show: commentHover.hovered; textFor: () => qsTr("Comment: ") + (root.row ? root.row.comment : "") }
            }
        }
    }
}
