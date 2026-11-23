import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../../components"

// One scan item (an eAfeScanID_t value). Column widths match ScanItemColumn's header.
Item{
    id: root
    height: 44
    property string name: "AFE_END"
    property int value: 0
    property string desc: "To set a flag to indicate the end of a frame request"
    property alias checkBox: checkBox
    signal selected(bool status)
    signal activated()
    TapHandler{ onDoubleTapped: root.activated() }
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
            TableText{ text: root.value; horizontalAlignment: Text.AlignHCenter }
        }
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.horizontalStretchFactor: 12
            TableText{ text: root.name }
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
