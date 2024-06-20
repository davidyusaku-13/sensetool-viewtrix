import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components"

Item{
    property alias scanItemList: scanItemList
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
        // Toolbar
        RowLayout{
            Layout.fillWidth: true
            implicitHeight: 25
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Add"
                onClicked: {
                    scanWindow.manage(-1,null)
                }
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Edit"
                enabled: selectedScanItem.count === 1
                onClicked: {
                    if(selectedScanItem.count === 1){
                        var selected = selectedScanItem.get(0)
                        scanWindow.manage(selected.itemsIndex, selected.model)
                    }
                }
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Delete"
                enabled: selectedScanItem.count > 0
                onClicked: {
                    for(let i = selectedScanItem.count-1; i>=0; i--){
                        let itemSelected = selectedScanItem.get(i)
                        var object = scanItemList.get(itemSelected.itemsIndex)
                        scanItemList.remove(itemSelected.itemsIndex)
                    }
                }
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Select All"
                onClicked: {
                    for(var i=0; i< scanItemModel.items.count; i++){
                        if(!scanItemModel.items.get(i).inSelected){
                            scanItemModel.items.get(i).inSelected = true
                        }
                    }
                }
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Deselect All"
                onClicked: {
                    for(var i=0; i< scanItemModel.items.count; i++){
                        if(scanItemModel.items.get(i).inSelected){
                            scanItemModel.items.get(i).inSelected = false
                        }
                    }
                }
            }
            ScanWindow{
                id: scanWindow
                onCreate: (object) => {
                              scanItemList.append(object);
                          }
                onModify: (index, object) => {
                              scanItemList.set(index, object);
                          }
            }
        }

        // Scan Items Content
        ShadowRect{
            id: scanContent
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
                    id: scanItemHeader
                    width: parent.width
                    height: 35
                    spacing: 0
                    z: 2
                    Repeater{
                        model: ["Scan Name", "Description"]
                        Rectangle{
                            required property string modelData
                            Layout.fillHeight: true
                            Layout.fillWidth: modelData === "Description" ? false : true
                            Layout.preferredWidth: modelData === "Description" ? parent.width*4/7 : 0
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
                }
                //item list
                model: DelegateModel{
                    id: scanItemModel
                    model: ListModel{
                        id: scanItemList
                    }
                    // model: window.manager.prjSetModel
                    groups: [
                        DelegateModelGroup {
                            id: selectedScanItem
                            name: "selected"
                        }
                    ]
                    delegate: ScanItem{
                        id: scanItemDel
                        required property var model
                        name: model.name
                        desc: model.desc
                        width: ListView.view.width
                        checkBox.checked: scanItemDel.DelegateModel.inSelected
                        onSelected: {
                            scanItemDel.DelegateModel.inSelected = !scanItemDel.DelegateModel.inSelected
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
                        text: selectedScanItem.count + " of " + scanItemModel.count + " selected"
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
                        color: Material.foreground
                    }
                }
                // Component {
                //     id: dragDelegate
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
