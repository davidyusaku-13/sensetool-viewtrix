import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

Window {
    id: root
    width: 400
    height: 100
    title: "Warning"

    signal saved(var state)

    property bool state

    ColumnLayout{
        anchors.fill: parent
        spacing: 10
        anchors.margins: 18
        Text {
            id: confirmText
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: "Are you sure want to change this item?"
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 13
            font.family: "Montserrat Medium"
        }
        RowLayout{
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            //yes
            Item{
                width: 60
                height: 30
                MyText{
                    anchors.fill: parent
                    customText: "YES"
                    customSize: 15
                    customFont: "Montserrat Medium"
                    customHAlignment: "Center"
                    customRadius: 20
                    onClicked: {
                        root.saved(true)
                        root.close()
                    }
                }
            }
            //no
            Item{
                width: 60
                height: 30
                MyText{
                    anchors.fill: parent
                    customText: "NO"
                    customSize: 15
                    customFont: "Montserrat Medium"
                    customHAlignment: "Center"
                    customRadius: 20
                    onClicked: {
                        root.saved(false)
                        root.close()
                    }
                }
            }
        }
    }
}
