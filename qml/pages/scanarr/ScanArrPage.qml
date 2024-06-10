import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

ShadowRect{
    Layout.fillWidth: true
    Layout.fillHeight: true
    ColumnLayout{
        anchors.fill: parent
        // Import Export Row
        RowLayout{
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 20
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Import"
                Material.background: Material.accent
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Export"
                Material.background: Material.accent
            }
        }
        SplitView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Scan Items
            Item{
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 6/15 : parent.width * 2/7
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
                                id: scanHeader
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
            // ScanArr Items
            Item{
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 6/15  : parent.width * 3/7
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
                        ScanWindow{
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
                                    list: scanArrListPopUp
                                    itemID: index+1
                                    name: model.name
                                    desc: model.desc
                                    width: ListView.view.width
                                    checkBox.checked: scanArrDel.DelegateModel.inSelected
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
            // ScanArr List
            Item{
                id: scanArrListPopUp
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 3/15  : parent.width * 1/7
                //scan list rect
                ShadowRect{
                    anchors.fill: parent
                    anchors.margins: 20
                    color: Material.background
                    ListView{
                        anchors.fill: parent
                        interactive: true
                        clip: true
                        //header
                        headerPositioning: ListView.OverlayHeader
                        header: ColumnLayout{
                            id: chooseHeader
                            width: parent.width
                            height: 35
                            spacing: 0
                            z: 2
                            Rectangle{
                                Layout.fillWidth: true
                                implicitHeight: 35
                                color: Material.accent
                                Text {
                                    text: "Scan List"
                                    font.pointSize: 12
                                    font.family: "Montserrat SemiBold"
                                    anchors.centerIn: parent
                                    color: Material.foreground
                                }
                                Image{
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin: 7
                                    fillMode: Image.PreserveAspectFit
                                    height: parent.height-12
                                    source: "../../images/close"
                                    MouseArea{
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: scanArrListPopUp.visible = false
                                    }
                                }
                            }
                            RowLayout{
                                RoundButton{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    icon.source: "../../images/plus.png"
                                    HoverHandler{
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                                RoundButton{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    icon.source: "../../images/checklist.png"
                                    HoverHandler{
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                                RoundButton{
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    icon.source: "../../images/trash.png"
                                    HoverHandler{
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                        // Scan List
                        model: DelegateModel{
                            id: scanArrChooseModel
                            model: ListModel{
                                id: scanArrChoose
                            }
                            groups: [
                                DelegateModelGroup {
                                    id: selectedChoose
                                    name: "selected"
                                }
                            ]
                            delegate: ScanItem{
                                id: scanArrChooseDel
                                required property var model
                                name: model.name
                                desc: model.desc
                                width: ListView.view.width
                                checkBox.checked: scanArrChooseDel.DelegateModel.inSelected
                                onSelected: {
                                    scanArrChooseDel.DelegateModel.inSelected = !scanArrChooseDel.DelegateModel.inSelected
                                }
                            }
                            //delegate: dragDelegate
                        }
                    }
                }
            }
        }
    }
}
