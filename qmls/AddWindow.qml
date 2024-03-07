import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Window {
    id: root
    title: "Add File"
    minimumWidth:500
    minimumHeight: 500
    maximumWidth: 500
    maximumHeight: 500
    ColumnLayout{
        anchors.fill: parent
        spacing: 20
        anchors.margins: 20
        //item
        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5
            Text{
                text: "Item"
                font.family: "Montserrat Medium"
                font.pixelSize: 20
            }
            TextArea{
                id: itemName
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: ""
                font.family: "Montserrat"
                font.pixelSize: 17
                verticalAlignment: Text.AlignVTop
                wrapMode: Text.Wrap
                Layout.preferredHeight: 0
                Layout.preferredWidth: 0
                background: Shadow{}
            }
        }
        //value
        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5
            Text{
                text: "Value"
                font.family: "Montserrat Medium"
                font.pixelSize: 20
            }
            TextArea{
                id: value
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: ""
                font.family: "Montserrat"
                font.pixelSize: 17
                verticalAlignment: Text.AlignVTop
                wrapMode: Text.Wrap
                Layout.preferredHeight: 0
                Layout.preferredWidth: 0
                background: Shadow{}
            }
        }
        //desc
        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5
            Text{
                text: "Description"
                font.family: "Montserrat Medium"
                font.pixelSize: 20
            }
            TextArea{
                id: desc
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: ""
                font.family: "Montserrat"
                font.pixelSize: 17
                verticalAlignment: Text.AlignVTop
                wrapMode: Text.Wrap
                Layout.preferredHeight: 0
                Layout.preferredWidth: 0
                background: Shadow{}
            }
        }
        //button
        RowLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight
            spacing: 5
            MyText2{
                implicitWidth: 50
                implicitHeight: 30
                customRadius: 5
                customText: "Add"
                customTextColor: "#ffffff"
                customSize: 15
                customHAlignment: "Center"
                customColor: "#000000"
                customHoveredColor: "#332C2B"
            }
            MyText2{
                implicitWidth: 70
                implicitHeight: 30
                customRadius: 5
                customText: "Cancel"
                customTextColor: "#ffffff"
                customSize: 15
                customHAlignment: "Center"
                customColor: "#000000"
                customHoveredColor: "#332C2B"
            }
        }
    }
}
