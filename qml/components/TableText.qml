import QtQuick
import QtQuick.Controls.Material

// Cell text: never breaks words; elides and shows the full text on hover.
Text{
    id: root
    property int lines: 1
    color: Material.foreground
    font.pixelSize: 14
    font.family: "Montserrat Medium"
    wrapMode: lines > 1 ? Text.Wrap : Text.NoWrap
    maximumLineCount: lines
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    HoverHandler{ id: hover }
    HoverTip{ show: hover.hovered && root.truncated; textFor: () => root.text }
}
