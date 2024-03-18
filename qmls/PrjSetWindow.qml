import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

Window {
    id: root
    title: "Add File"
    minimumWidth: 500
    minimumHeight: 500
    maximumWidth: 500
    maximumHeight: 500

    signal create(var object)
    signal modify(var object)

    property PrjSetItem object: PrjSetItem{}
    property int index: -1
    property bool isEdit: false

    function manage(i: int, model: var){
        if(i !== -1){
            isEdit = true
            object.name = model.name
            object.value = model.value
            object.desc = model.desc

        }else {
            isEdit = false
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
                text: root.object.name
                onTextChanged: root.object.name = text
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
                text: root.object.value
                onTextChanged: root.object.value = text
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
                text: root.object.desc
                onTextChanged: root.object.desc = text
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
                implicitWidth: root.isEdit === false ? 50 : 55
                implicitHeight: 30
                customRadius: 5
                customText: root.isEdit === false ? "Add" : "Save"
                customTextColor: "#ffffff"
                customSize: 15
                customHAlignment: "Center"
                customColor: "#000000"
                customHoveredColor: "#332C2B"

                onClicked: {
                    if(isEdit == true){
                        root.modify(root.object)
                        root.object.reset()
                        root.close()
                    }else{
                        root.create(root.object)
                        root.object.reset()
                        root.close()
                        //root.visible = false
                    }
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
                    root.object.reset()
                    root.close()
                    //root.visible = false
                }
            }
        }
    }
}
