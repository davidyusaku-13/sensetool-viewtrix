import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../components"

Window {
    id: root
    title: isEdit === false ? "Add File" : "Edit File"
    minimumWidth: 500
    minimumHeight: 500
    maximumWidth: 500
    maximumHeight: 500
    
    signal create(var object)
    signal modify(int index, var object)
    
    property PrjSetObject object: PrjSetObject{}
    property int index: -1
    property bool isEdit: false
    property HoverHandler cursor: HoverHandler{
        cursorShape: Qt.IBeamCursor
    }
    
    function manage(i: int, model: var){
        if(i !== -1){
            isEdit = true
            object.set(model)
        }else {
            isEdit = false
            root.object.reset()
        }
        index = i
        root.show()
    }
    ConfirmWindow{
        id: confirmWindow
        onSaved: (state) => {
                     if(state === true){
                         root.modify(root.index, root.object.get())
                         root.object.reset()
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
                    validator: RegularExpressionValidator {regularExpression: /[0-9A-Z_]+/}
                    HoverHandler {
                        cursorShape: Qt.IBeamCursor
                    }
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
                    validator: RegularExpressionValidator {regularExpression: /[0-9a-zA-Z*()_" "<>+-/:?]+/}
                    HoverHandler {
                        cursorShape: Qt.IBeamCursor
                    }
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
            RoundButton {
                implicitWidth: 80
                text: root.isEdit ? "Save" : "Add"
                enabled: (text === "Add"
                          && root.object.name === "") ? false : true
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                onClicked: {
                    if (root.isEdit == true) {
                        confirmWindow.show()
                    } else {
                        root.create(root.object)
                        root.object.reset()
                        root.close()
                    }
                }
            }
            //cancel
            RoundButton {
                implicitWidth: 80
                text: "Cancel"
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                onClicked: {
                    root.object.reset()
                    root.close()
                }
            }
        }
    }
}