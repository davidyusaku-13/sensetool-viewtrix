import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Item{
    width: customWidth
    height: customHeight

    property int customWidth: 1000
    property int customHeight: 50

    property Rectangle shadow: Rectangle{
        layer.enabled: true
        layer.effect: DropShadow{
            horizontalOffset: 0
            verticalOffset: 0
            radius: 4.0
            color: "#80000000"
        }
    }

    RowLayout{
        anchors.fill: parent
        spacing: 0
        //checklist box
        CheckBox{

        }
        //item
        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
            MyText{
                anchors.fill: parent
            }
        }

        //value
        Item{
            width: 200
            Layout.fillHeight: true
            MyText{
                anchors.fill: parent
            }
        }

        //desc
        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
            MyText{
                anchors.fill: parent
            }
        }

        //drag
        Item{
            width: 50
            Layout.fillHeight: true
            Image{
                anchors.fill: parent
                anchors.margins: 10
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


