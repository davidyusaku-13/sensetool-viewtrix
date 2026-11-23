import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Controls.Material

// Toolbar button. `primary` marks the page's main action (accent colour);
// there should be at most one per toolbar.
RoundButton{
    property bool primary: false
    highlighted: primary
    Layout.preferredHeight: 45
    font.pixelSize: 15
    font.family: "Montserrat Medium"
    HoverHandler{
        cursorShape: Qt.PointingHandCursor
    }
    ToolTip.visible: hovered && ToolTip.text !== ""
    ToolTip.delay: 600
}
