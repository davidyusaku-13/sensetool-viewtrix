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

    signal create(var object)
    property PrjSetItem object: PrjSetItem{}
    property int index: -1

    function edit(i: int, model: var){
        if(i != -1){
            object.name = model.name
            object.value = model.value
            object.desc = model.desc
        } else {
            object.reset()
        }
        index = i
        root.show()
    }

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
                text: "Name"
                font.family: "Montserrat Medium"
                font.pixelSize: 20
            }
            TextArea{
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: object.name
                onTextChanged: object.name = text
                font.family: "Montserrat"
                font.pixelSize: 17
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
                selectionColor: "#6d6d6d"
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
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: object.value
                onTextChanged: object.value = text
                font.family: "Montserrat"
                font.pixelSize: 17
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
                selectionColor: "#6d6d6d"
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
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: object.desc
                onTextChanged: object.desc = text
                font.family: "Montserrat"
                font.pixelSize: 17
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
                selectionColor: "#6d6d6d"
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
            //add
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

                onClicked: {
                    root.create(object)
                    object.reset()
                    root.close()
                    //root.visible = false
                }
            }
            //cancel
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

                onClicked: {
                    object.reset()
                    root.close()
                    //root.visible = false
                }
            }
        }
    }
}
