import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

// One column title of a table header. Width rules mirror the row cells:
// set Layout.preferredWidth for fixed columns or Layout.fillWidth for flexible ones.
Rectangle{
    property alias text: label.text
    Layout.fillHeight: true
    color: Material.accent
    Text{
        id: label
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.pointSize: 12
        font.family: "Montserrat SemiBold"
        color: sensetool.onAccent
    }
}
