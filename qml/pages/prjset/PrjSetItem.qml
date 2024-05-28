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
    property string customItem: "FILTER_THRES_MOTION_TOLERANCE_WINDOW"
    property string customValue: "(MSN_CH_LEN*MSN_FREQ_CNT*2)+AFE_CRC_LEN"
    property string customDesc: "Maximum count of timeslot in one mutual frame scan (need to consider for SingleTx, DTO and QTO scan option)"
    property alias dragArea: dragArea
    property alias checkBox: checkBox
    required property var content
    signal selected(bool status)
    RowLayout{
        anchors.fill: parent
        spacing: 0
        ShadowRect{
            implicitWidth: 35
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            CheckBox{
                id: checkBox
                // Layout.margins: 7
                // implicitWidth: 35
                // implicitHeight: 35
                anchors.centerIn: parent
                onClicked: {
                    root.selected(checked)
                }
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
                text: root.customItem
                color: Material.foreground
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
                text: root.customValue
                color: Material.foreground
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
                text: root.customDesc
                color: Material.foreground
                font.pixelSize: 15
                font.family: "Montserrat Medium"
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
            }
        }
        //drag
        ShadowRect{
            implicitWidth: 45
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Button{
                id: drag
                anchors.centerIn: parent
                // Layout.margins: 7
                flat: true
                icon.source: "qrc:/images/drag"
                icon.color: "#d6d6d6"
                padding: 0
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: pressed ? root.content: undefined
                    drag.axis: Drag.YAxis
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    hoverEnabled: true
                }
            }
        }
    }
}