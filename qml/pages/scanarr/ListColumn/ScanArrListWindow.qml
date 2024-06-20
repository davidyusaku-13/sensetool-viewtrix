import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../"

Window {
    id: root
    title: isEdit === false ? "Add File" : "Edit File"
    minimumWidth: 500
    minimumHeight: 400
    maximumWidth: 500
    maximumHeight: 00
    color: Material.background

    signal create(var object)
    signal modify(int index, var object)
    property var names: []
    property ScanArrListObject object: ScanArrListObject{}
    property int index: -1
    property bool isEdit: false
    property HoverHandler cursor: HoverHandler{
        cursorShape: Qt.IBeamCursor
    }
    function manage(i: int, model: var){
        if(i !== -1){
            isEdit = true
            object.set(model)
        } else {
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
        // List to choose
        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text{
                text: "Scan Items"
                font.family: "Montserrat Medium"
                font.pixelSize: 20
                color: Material.foreground
            }
            Frame{
                Layout.fillWidth: true
                Layout.fillHeight: true
                ListView{
                    anchors.fill: parent
                    interactive: true
                    clip: true
                    //item list
                    model: DelegateModel{
                        id: scanArrListModelGroup
                        model: itemColumn.scanItemList
                        // model: window.manager.prjSetModel
                        groups: [
                            DelegateModelGroup {
                                id: selectedScanArrList
                                name: "selected"
                            }
                        ]
                        delegate: ScanArrListItem{
                            id: scanArrListDel
                            required property var model
                            name: model.name
                            width: ListView.view.width
                            checkBox.checked: scanArrListDel.DelegateModel.inSelected
                            onSelected: {
                                scanArrListDel.DelegateModel.inSelected = !scanArrListDel.DelegateModel.inSelected
                                if(scanArrListDel.DelegateModel.inSelected){
                                    root.names.push(name)
                                } else {
                                    let index = names.indexOf(name)
                                    root.names.splice(index, 1)
                                }
                                root.object.names = root.names
                            }
                        }
                        // delegate: dragDelegate
                    }
                    //footer
                    footerPositioning: ListView.OverlayFooter
                    footer: Rectangle{
                        id: scanItemFooter
                        width: parent.width
                        height: 35
                        color: Material.accent
                        z: 2
                        Text{
                            anchors.centerIn: parent
                            text: selectedScanArrList.count + " of " + itemColumn.scanItemList.count + " selected"
                            font.pointSize: 12
                            font.family: "Montserrat SemiBold"
                            color: Material.foreground
                        }
                    }
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
            RoundButton{
                implicitWidth: 80
                text: root.isEdit ? "Save" : "Add"
                enabled: (text === "Add" && selectedScanArrList.count >= 0) ? true : false
                HoverHandler{
                    cursorShape: Qt.PointingHandCursor
                }
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
            RoundButton{
                implicitWidth: 80
                text: "Cancel"
                HoverHandler{
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
