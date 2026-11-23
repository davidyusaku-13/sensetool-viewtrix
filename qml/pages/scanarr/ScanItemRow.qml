import QtQuick
import "../../components"

// A scan item (eAfeScanID_t value). Columns: #, Name, Description.
TableRow{
    id: root
    height: 44
    TableCell{ spec: root.columns[0]; listWidth: root.listWidth; text: root.row ? String(root.row.value) : ""; horizontalAlignment: Text.AlignHCenter }
    TableCell{ spec: root.columns[1]; listWidth: root.listWidth; text: root.row ? root.row.name : "" }
    TableCell{ spec: root.columns[2]; listWidth: root.listWidth; text: root.row ? root.row.desc : ""; lines: 2; label.font.pixelSize: 13 }
}
