import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../../components"

Item{
    id: root
    property var arrangements: []
    signal focusIndex(int index, var model)
    MouseArea{
        anchors.fill: parent
        onClicked:{
            sidebar.folded = true
        }
    }
    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        //toolbar
        RowLayout{
            Layout.fillWidth: true
            implicitHeight: 25
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Add"
                onClicked: {
                    scanArrWindow.manage(-1,null)
                }
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Edit"
                enabled: selectedScanArr.count === 1
                onClicked: {
                    if(selectedScanArr.count === 1){
                        var selected = selectedScanArr.get(0)
                        scanArrWindow.manage(selected.itemsIndex, selected.model)
                    }
                }
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Delete"
                enabled: selectedScanArr.count > 0
                onClicked: {
                    for(let i = selectedScanArr.count-1; i>=0; i--){
                        let itemSelected = selectedScanArr.get(i)
                        var object = scanArrList.get(itemSelected.itemsIndex)
                        scanArrList.remove(itemSelected.itemsIndex)
                    }
                }
            }
            Item{
                Layout.fillWidth: true
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Select All"
                onClicked: {
                    for(var i=0; i< scanArrModel.items.count; i++){
                        if(!scanArrModel.items.get(i).inSelected){
                            scanArrModel.items.get(i).inSelected = true
                        }
                    }
                }
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Deselect All"
                onClicked: {
                    for(var i=0; i< scanArrModel.items.count; i++){
                        if(scanArrModel.items.get(i).inSelected){
                            scanArrModel.items.get(i).inSelected = false
                        }
                    }
                }
            }
            ScanArrWindow{
                id: scanArrWindow
                onCreate: (object) => {
                              scanArrList.append(object);
                          }
                onModify: (index, object) => {
                              scanArrList.set(index, object);
                          }
            }
        }
        //ScanArr rect
        ShadowRect{
            id: scanArrContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Material.background
            ListView{
                anchors.fill: parent
                interactive: true
                clip: true
                //header
                headerPositioning: ListView.OverlayHeader
                header: RowLayout{
                    id: scanArrHeader
                    width: parent.width
                    height: 35
                    spacing: 0
                    z: 2
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 35
                        color: Material.accent
                    }
                    Repeater{
                        model: ["ID", "Scan Arrangement Name", "Description"]
                        Rectangle{
                            required property string modelData
                            Layout.fillHeight: true
                            Layout.fillWidth: modelData === "ID" ? false : true
                            Layout.preferredWidth: modelData === "ID" ? parent.width/5 : 0
                            color: Material.accent
                            Text {
                                text: parent.modelData
                                anchors.centerIn: parent
                                font.pointSize: 12
                                font.family: "Montserrat SemiBold"
                                color: Material.foreground
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 35
                        color: Material.accent
                    }
                }
                //scan arr item list
                model: DelegateModel{
                    id: scanArrModel
                    model: ListModel{
                        id: scanArrList
                    }
                    groups: [
                        DelegateModelGroup {
                            id: selectedScanArr
                            name: "selected"
                        }
                    ]
                    delegate: ScanArrItem{
                        id: scanArrDel
                        required property int index
                        required property var model
                        scanArrList: scanArrListColumn
                        itemID: index+1
                        name: model.name
                        desc: model.desc
                        width: ListView.view.width
                        checkBox.checked: scanArrDel.DelegateModel.inSelected
                        onFocused: root.focusIndex(index, model)
                        onSelected: {
                            scanArrDel.DelegateModel.inSelected = !scanArrDel.DelegateModel.inSelected
                        }
                    }
                    //delegate: dragDelegate
                }
                //footer
                footerPositioning: ListView.OverlayFooter
                footer: Rectangle{
                    id: scanArrFooter
                    width: parent.width
                    height: 35
                    color: Material.accent
                    z: 2
                    Text{
                        anchors.centerIn: parent
                        text: selectedScanArr.count + " of " + scanArrModel.count + " selected"
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
                        color: Material.foreground
                    }
                }
                // Component {
                //     id: dragDelegate2
                //     Rectangle {
                //         id: content
                //         required property var model
                //         required property int index
                //         width: ListView.view.width
                //         height: itemDel.height
                //         color: itemDel.dragArea.held ? "#d6d6d6": "white"
                //         Behavior on color { ColorAnimation { duration: 100 } }
                //         radius: 2
                //         ScanArrItem{
                //             id: itemDel
                //             states: State {
                //                 when: itemDel.dragArea.pressed
                //                 ParentChange {
                //                     target: itemDel
                //                     parent: content.ListView.view
                //                 }
                //             }
                //             Drag.hotSpot.x: width / 2
                //             Drag.hotSpot.y: height / 2
                //             Drag.source: content
                //             Drag.active: itemDel.dragArea.pressed
                //             anchors {
                //                 left: parent.left
                //                 right: parent.right
                //             }
                //             height: 35
                //             width: parent.width
                //             name: model.name
                //             desc: model.desc
                //             content: itemDel
                //             checkBox.checked: DelegateModel.inSelected
                //             color: checkBox.checked ? "lightsteelblue": "transparent"
                //             Behavior on color { ColorAnimation { duration: 100 } }
                //         }
                //         DropArea {
                //             anchors.fill: parent
                //             onEntered: (drag) => {window.manager.moveItem(drag.source.index, content.index)}
                //         }
                //     }
                // }
            }
        }
    }
}
