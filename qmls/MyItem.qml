import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Item{
    id: root
    width: customWidth
    height: customHeight

    property int customWidth: 1000
    property int customHeight: 50
    property string customItem: "OS_EVENT_QUEUE"
    property string customValue: "8"
    property string customDesc: "Queue deep value"
    property bool checkState: false

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
                    color: root.checkState ? "#000000" : "#ffffff"
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
            implicitWidth: 200
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
            Layout.fillWidth: true
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

                HoverHandler {
                    id: dragPointer
                    acceptedDevices: PointerDevice.Mouse
                    cursorShape: Qt.OpenHandCursor
                }
            }
        }
    }
}


