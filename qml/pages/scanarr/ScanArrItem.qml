import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import "../../components"

Rectangle{
    id: root
    Layout.fillWidth: true
    implicitHeight: desc.lineCount > 1 ? desc.lineCount*25 : 35
    // width: 1000
    // height: 35
    property int id: 1
    property string name: "AFE_END"
    property string desc: "To set a flag to indicate the end of a frame request"
    property alias dragArea: dragArea
    property alias checkBox: checkBox
    signal selected(bool status)
    RowLayout{
        anchors.fill: parent
        spacing: 0
        CheckBox{
            id: checkBox
            Layout.fillHeight: true
            Layout.preferredWidth: 35
            // Layout.margins: 7
            onClicked: {
                root.selected(checked)
            }
        }
        //ID
        ShadowRect{
            Layout.fillHeight: true
            // implicitWidth: (root.width/5)-70
            Layout.preferredWidth: root.width/5
            Text{
                id: id
                anchors.fill: parent
                anchors.margins: 10
                text: root.id
                font.pixelSize: 15
                font.family: "Montserrat Medium"
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
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
            }
        }
        //desc
        ShadowRect{
            Layout.fillHeight: true
            // implicitWidth: parent.width*3/7
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
            }
        }
        //drag
        Button{
            id: drag
            Layout.preferredWidth: 35
            // Layout.margins: 7
            flat: true
            // icon.source: "qrc:/images/drag"
            icon.source: "../../images/drag.png"
            icon.color: "#d6d6d6"
            padding: 0
            background: Rectangle{
                color: "transparent"
                HoverHandler {
                    cursorShape: Qt.OpenHandCursor
                }
            }
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
