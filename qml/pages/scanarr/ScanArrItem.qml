import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import "../../components"

Rectangle{
    id: root
    width: 1000
    height: 75
    Behavior on color { ColorAnimation { duration: 100 } }
    property string name: "FILTER_THRES_MOTION_TOLERANCE_WINDOW"
    property string value: "(MSN_CH_LEN*MSN_FREQ_CNT*2)+AFE_CRC_LEN"
    property string desc: "Maximum count of timeslot in one mutual frame scan (need to consider for SingleTx, DTO and QTO scan option)"
    property alias dragArea: dragArea
    property alias checkBox: checkBox
    required property var content
    signal selected(bool status)
    RowLayout{
        anchors.fill: parent
        spacing: 0
        CheckBox{
            id: checkBox
            Layout.margins: 7
            implicitWidth: 35
            implicitHeight: 35
            onClicked: {
                root.selected(checked)
            }
        }
        //item
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
        //value
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Text{
                id: value
                anchors.fill: parent
                anchors.margins: 10
                text: root.value
                font.pixelSize: 15
                font.family: "Montserrat Medium"
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
            }
        }
        //desc
        ShadowRect{
            Layout.fillHeight: true
            implicitWidth: parent.width*3/7
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
            Layout.margins: 7
            flat: true
            icon.source: "qrc:/images/drag"
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
                drag.target: pressed ? root.content: undefined
                drag.axis: Drag.YAxis
                cursorShape: Qt.OpenHandCursor
                hoverEnabled: true
            }
        }
    }
}