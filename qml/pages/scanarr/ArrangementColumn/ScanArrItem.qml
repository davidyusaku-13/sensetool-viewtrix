import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../../components"

// One scan arrangement. Clicking it shows its steps in the Scan List column.
Item{
    id: root
    height: 44
    property string itemID: "1"
    property string name: "AFE_SCAN_ACTIVE"
    property string desc: ""
    // shown in the Scan List column right now
    property bool current: false
    property alias checkBox: checkBox
    signal selected(bool status)
    signal focused()
    signal activated()
    TapHandler{
        onTapped: root.focused()
        onDoubleTapped: root.activated()
    }
    HoverHandler{ cursorShape: Qt.PointingHandCursor }
    Rectangle{
        anchors.fill: parent
        z: 1
        color: Material.accent
        opacity: root.current ? 0.18 : 0
    }
    RowLayout{
        anchors.fill: parent
        spacing: 0
        ShadowRect{
            Layout.preferredWidth: 40
            Layout.fillHeight: true
            CheckBox{
                id: checkBox
                anchors.centerIn: parent
                onClicked: root.selected(checked)
            }
        }
        ShadowRect{
            Layout.preferredWidth: 44
            Layout.fillHeight: true
            TableText{ text: root.itemID; horizontalAlignment: Text.AlignHCenter }
        }
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.horizontalStretchFactor: 12
            TableText{ text: root.name; font.family: root.current ? "Montserrat SemiBold" : "Montserrat Medium" }
        }
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.horizontalStretchFactor: 10
            TableText{ text: root.desc; lines: 2; font.pixelSize: 13 }
        }
    }
}
