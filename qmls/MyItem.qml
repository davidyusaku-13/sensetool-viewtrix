import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Item{
    width: customWidth
    height: customHeight

    property int customWidth: 1000
    property int customHeight: 50
    property string customItem: "OS_EVENT_QUEUE"
    property string customValue: "8"
    property string customDesc: "Queue deep value"
    property bool checkState: false

    RowLayout{
        anchors.fill: parent
        spacing: 0
        //checklist box
        Item{
            width: 50
            Layout.fillHeight: true
            Button{
                anchors.fill: parent
                anchors.margins: 15
                background: Rectangle{
                    color: checkState === false ? "#ffffff" : "#000000"
                    layer.enabled: true
                    radius: 3
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
                    checkState = !checkState
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
                customText: customItem
                customRadius: 0
            }
        }

        //value
        Item{
            width: 200
            Layout.fillHeight: true
            MyText{
                anchors.fill: parent
                customSize: 15
                customText: customValue
                customRadius: 0
            }
        }

        //desc
        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
            MyText{
                anchors.fill: parent
                customSize: 15
                customText: customDesc
                customRadius: 0
            }
        }

        //drag
        Item{
            width: 50
            Layout.fillHeight: true
            Image{
                anchors.fill: parent
                anchors.margins: 13
                source: "images/drag"

                HoverHandler {
                    id: dragPointer
                    acceptedDevices: PointerDevice.Mouse
                    cursorShape: Qt.OpenHandCursor
                }
            }
        }
    }
}


