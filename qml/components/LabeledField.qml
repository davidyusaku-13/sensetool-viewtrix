import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// A text field with a caption above it, so the field stays labelled once filled in.
ColumnLayout{
    id: root
    property alias label: caption.text
    property alias text: field.text
    property alias validator: field.validator
    property alias placeholderText: field.placeholderText
    spacing: 2
    Label{ id: caption; opacity: 0.7; font.pixelSize: 12 }
    TextField{ id: field; Layout.fillWidth: true; selectByMouse: true }
}
