import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Item{
    id: root
    width: customWidth
    height: name.lineCount>1 ? name.lineCount*(customHeight/2) :
                               value.lineCount>1 ? value.lineCount*(customHeight/2) :
                                                   desc.lineCount ? desc.lineCount*(customHeight/2) : customHeight


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
                implicitWidth: 25
                implicitHeight: 25
                anchors.centerIn: parent
                background: Rectangle{
                    color: root.checkState ? "#000000" : "#ffffff"
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
            Layout.fillHeight: true
            Layout.fillWidth: true
            MyText{
                id: name
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
                id: value
                anchors.fill: parent
                customSize: 15
                customText: root.customValue
                customRadius: 0
            }
        }
        //desc
        Item{
            id: desc
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
                HoverHandler {
                    id: dragPointer
                    acceptedDevices: PointerDevice.Mouse
                    cursorShape: Qt.OpenHandCursor
                }
            }
        }
    }
}


