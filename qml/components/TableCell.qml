import QtQuick
import QtQuick.Layouts

// A table cell sized from a column spec shared with the header:
//   {title, width: px} | {title, fraction: of the list width} | {title, stretch: factor}
// Set `text` for a plain cell, or put your own content inside.
ShadowRect{
    id: cell
    property var spec: ({})
    property real listWidth: 0
    property string text: ""
    property int lines: 1
    property int horizontalAlignment: Text.AlignLeft
    property alias label: label
    Layout.fillHeight: true
    Layout.fillWidth: spec.stretch !== undefined
    Layout.horizontalStretchFactor: spec.stretch !== undefined ? spec.stretch : -1
    Layout.preferredWidth: spec.width !== undefined ? spec.width
                         : spec.fraction !== undefined ? listWidth * spec.fraction : 0
    TableText{
        id: label
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        visible: cell.text !== ""
        text: cell.text
        lines: cell.lines
        horizontalAlignment: cell.horizontalAlignment
    }
}
