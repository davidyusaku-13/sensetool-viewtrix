import QtQuick
import "../../components"

// A scan arrangement. Columns: ID, Name, Description.
TableRow{
    id: root
    height: 44
    TableCell{ spec: root.columns[0]; listWidth: root.listWidth; text: root.row ? root.row.arrId : ""; horizontalAlignment: Text.AlignHCenter }
    TableCell{ spec: root.columns[1]; listWidth: root.listWidth; text: root.row ? root.row.name : "" }
    TableCell{ spec: root.columns[2]; listWidth: root.listWidth; text: root.row ? root.row.desc : ""; lines: 2; label.font.pixelSize: 13 }
}
