import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Rectangle{
    id: root
    width: customWidth
    height: customHeight

    property int customWidth: 1000
    property int customHeight: 50
    property string customItem: "OS_EVENT_QUEUE"
    property string customValue: "8"
    property string customDesc: "Queue deep value"
    property bool checkState: false
    property alias dragArea: dragArea
    required property var content

    signal checked(bool status)
    RowLayout{
        anchors.fill: parent
        spacing: 0
        //checklist box
        Item{
            implicitWidth: 50
            Layout.fillHeight: true
            Button{
                id: btn
                anchors.fill: parent
                anchors.margins: 15
                background: Rectangle{
                    color: root.checkState ? "#000000": "#ffffff"
                    Behavior on color { ColorAnimation { duration: 100 } }
                    radius: 3
                    layer.enabled: true
                    layer.effect: DropShadow{
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 3
                        color: "#80000000"
                    }
                }
                HoverHandler {
                    acceptedDevices: PointerDevice.Mouse
                    cursorShape: Qt.PointingHandCursor
                }
                onClicked: {
                    root.checked(root.checkState)
                }
            }
        }
        //item
        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
            MyText{
                anchors.fill: parent
                customSize: 15
                customText: root.customItem
                customRadius: 0
            }
        }
        //value
        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
            MyText{
                anchors.fill: parent
                customSize: 15
                customText: root.customValue
                customRadius: 0
            }
        }
        //desc
        Item{
            //Layout.fillWidth: true
            implicitWidth: 500
            Layout.fillHeight: true
            MyText{
                anchors.fill: parent
                customSize: 15
                customText: root.customDesc
                customRadius: 0
            }
        }
        //drag
        Item{
            implicitWidth: 50
            Layout.fillHeight: true
            Image{
                anchors.fill: parent
                anchors.margins: 13
                source: "images/drag"
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
}


