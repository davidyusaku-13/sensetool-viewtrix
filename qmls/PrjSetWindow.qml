import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

Window {
    id: root
    title: isEdit === false ? "Add File" : "Edit File"
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
    ConfirmWindow{
        id: confirmWindow
        onSaved: (state) => {
                     if(state === true){
                         root.modify(root.object)
                         root.close()
                     }
                 }
    }
    ColumnLayout{
        anchors.fill: parent
        spacing: 20
        anchors.margins: 20
        //item
        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text{
                text: "Name"
                font.family: "Montserrat Medium"
                font.pixelSize: 20
            }
            Frame{
                Layout.fillWidth: true
                Layout.preferredHeight: itemInput.lineCount*childrenRect.height
                TextInput{
                    id: itemInput
                    anchors.fill: parent
                    text: root.object.name
                    onTextChanged: root.object.name = text
                    font.family: "Montserrat"
                    font.pixelSize: 17
                    wrapMode: Text.Wrap
                    clip: true
                    autoScroll: false
                    selectByMouse: true
                    validator: RegularExpressionValidator { regularExpression: /[0-9A-Z_]+/ }
                }
            }
        }
        //value
        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text{
                text: "Value"
                font.family: "Montserrat Medium"
                font.pixelSize: 20
            }
            Frame{
                Layout.fillWidth: true
                Layout.preferredHeight: valueInput.lineCount*childrenRect.height
                TextInput{
                    id: valueInput
                    anchors.fill: parent
                    text: root.object.value
                    onTextChanged: root.object.value = text
                    font.family: "Montserrat"
                    font.pixelSize: 17
                    wrapMode: Text.Wrap
                    clip: true
                    autoScroll: false
                    selectByMouse: true
<<<<<<< HEAD
                    validator: RegularExpressionValidator {regularExpression: /[0-9a-zA-Z*()_" "<>+-/:?]+/}
=======
                    validator: RegularExpressionValidator { regularExpression: /[0-9a-zA-Z*<>()_+?-]+/ }
>>>>>>> 14d5063a4139e7e57e33f7311424053db9c8f633
                }
            }
        }
        //desc
        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text{
                text: "Description"
                font.family: "Montserrat Medium"
                font.pixelSize: 20
            }
            Frame{
                Layout.fillWidth: true
                Layout.fillHeight: true
                TextEdit{
                    anchors.fill: parent
                    text: root.object.desc
                    onTextChanged: root.object.desc = text
                    font.family: "Montserrat"
                    font.pixelSize: 17
                    wrapMode: Text.Wrap
                    selectByMouse: true
                }
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
                customColor: root.object.name !== "" ? "#000000" : "#8B8B8C"
                customHoveredColor: root.object.name !== ""  ? "#332C2B" : customColor
                
                onClicked: {
                    if(root.isEdit == true){
                        confirmWindow.show()
                    }else{
                        root.create(root.object)
                        root.object.reset()
                        root.close()
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
                }
            }
        }
    }
}