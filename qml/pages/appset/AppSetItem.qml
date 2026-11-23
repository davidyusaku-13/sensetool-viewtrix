import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../../components"

// One register row (cells only). Columns: Addr, Name, Size, Bit fields, Default, Description.
TableRow{
    id: root
    height: 70
    readonly property string issue: row ? row.issue : ""

    TableCell{ spec: root.columns[0]; listWidth: root.listWidth; text: root.row ? root.row.addrHex : ""; label.font.family: "Monospace" }
    TableCell{
        spec: root.columns[1]
        listWidth: root.listWidth
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2
            TableText{ Layout.fillWidth: true; Layout.fillHeight: true; text: root.row ? root.row.name : "" }
            TableText{
                Layout.fillWidth: true
                visible: root.issue !== ""
                text: "⚠ " + root.issue
                color: Theme.error
                font.pixelSize: 11
            }
        }
    }
    TableCell{ spec: root.columns[2]; listWidth: root.listWidth; text: root.row ? root.row.size : ""; horizontalAlignment: Text.AlignHCenter }
    TableCell{ spec: root.columns[3]; listWidth: root.listWidth; text: root.row ? root.row.layout : ""; label.font.family: "Monospace"; label.font.pixelSize: 13 }
    TableCell{ spec: root.columns[4]; listWidth: root.listWidth; text: root.row ? root.row.defaultValue : ""; label.font.family: "Monospace" }
    TableCell{
        spec: root.columns[5]
        listWidth: root.listWidth
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2
            TableText{ Layout.fillWidth: true; Layout.fillHeight: true; text: root.row ? root.row.desc : ""; lines: 2; font.pixelSize: 13 }
            Text{
                Layout.fillWidth: true
                visible: root.row && root.row.category !== ""
                text: root.row ? root.row.category : ""
                color: Material.accent
                font.pixelSize: 11
                font.family: "Montserrat SemiBold"
            }
        }
    }
}
