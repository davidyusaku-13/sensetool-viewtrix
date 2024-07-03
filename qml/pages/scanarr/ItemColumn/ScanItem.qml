import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import "../../../components"

Item{
    id: root
    height: desc.lineCount > 1 ? desc.lineCount*25 : 35
    property string name: "AFE_END"
    property string desc: "To set a flag to indicate the end of a frame request"
    property alias dragArea: dragArea
    property alias checkBox: checkBox
    signal selected(bool status)
    RowLayout{
        anchors.fill: parent
        spacing: 0
        ShadowRect{
            Layout.preferredWidth: 35
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            CheckBox{
                id: checkBox
                anchors.centerIn: parent
                onClicked: {
                    root.selected(checked)
                }
            }
        }
        //scan arr name
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Text{
                id: name
                anchors.fill: parent
                anchors.margins: 10
                text: root.name
                font.pixelSize: 15
                font.family: "Montserrat Medium"
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
                color: Material.foreground
            }
        }
        //desc
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Text{
                id: desc
                anchors.fill: parent
                anchors.margins: 10
                text: root.desc
                font.pixelSize: 15
                font.family: "Montserrat Medium"
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
                color: Material.foreground
            }
        }
        //drag
        ShadowRect{
            Layout.preferredWidth: 35
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Button{
                id: drag
                anchors.centerIn: parent
                flat: true
                icon.source: "qrc:/images/drag.png"
                icon.color: Material.foreground
                padding: 0
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: pressed ? root.content : undefined
                    drag.axis: Drag.YAxis
                    cursorShape: Qt.OpenHandCursor
                    hoverEnabled: true
                }
            }
        }
    }
}
