import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

// One column title of a table header; sized by the same spec as TableCell.
Rectangle{
    property var spec: ({})
    property real listWidth: 0
    property alias text: label.text
    Layout.fillHeight: true
    Layout.fillWidth: spec.stretch !== undefined
    Layout.horizontalStretchFactor: spec.stretch !== undefined ? spec.stretch : -1
    Layout.preferredWidth: spec.width !== undefined ? spec.width
                         : spec.fraction !== undefined ? listWidth * spec.fraction : 0
    color: Material.accent
    Text{
        id: label
        text: parent.spec.title || ""
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.pointSize: 12
        font.family: "Montserrat SemiBold"
        color: Theme.onAccent
    }
}
