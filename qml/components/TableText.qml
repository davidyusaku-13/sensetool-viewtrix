import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

// Cell text for table rows: never breaks words; elides and shows the full text on hover.
Text{
    id: root
    property int lines: 1
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    color: Material.foreground
    font.pixelSize: 14
    font.family: "Montserrat Medium"
    wrapMode: lines > 1 ? Text.Wrap : Text.NoWrap
    maximumLineCount: lines
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    HoverHandler{ id: hover }
    ToolTip.visible: hover.hovered && root.truncated
    ToolTip.text: root.text
    ToolTip.delay: 400
}
