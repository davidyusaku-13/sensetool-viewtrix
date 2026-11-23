import QtQuick
import "../../components"

// One step of the arrangement shown in the Scan List. Columns: #, Scan step.
TableRow{
    id: root
    height: 38
    TableCell{ spec: root.columns[0]; listWidth: root.listWidth; text: root.row ? "#" + root.row.step : ""; horizontalAlignment: Text.AlignHCenter; label.opacity: 0.7 }
    TableCell{ spec: root.columns[1]; listWidth: root.listWidth; text: root.row ? root.row.name : "" }
}
