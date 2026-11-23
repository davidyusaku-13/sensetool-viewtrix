import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../../components"

// One step of the arrangement shown in the Scan List column.
Item{
    id: root
    height: 38
    property int step: 1
    property string name: "AFE_END"
    property alias checkBox: checkBox
    signal selected(bool status)
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
            Layout.preferredWidth: 36
            Layout.fillHeight: true
            TableText{ text: "#" + root.step; opacity: 0.7; horizontalAlignment: Text.AlignHCenter; anchors.leftMargin: 2; anchors.rightMargin: 2 }
        }
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            TableText{ text: root.name }
        }
    }
}
