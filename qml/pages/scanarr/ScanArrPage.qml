import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"
import "../prjset"

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
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Export"
            }
        }
        // ScanArr Row
        SplitView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            // ScanArr ITEMS
            Item{
                SplitView.fillHeight: true
                SplitView.preferredWidth: parent.width/2
                SplitView.minimumWidth: popUp.visible ? parent.width * 4/9 : parent.width/3
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
                                prjSetWindow.manage(-1,null)
                            }
                        }
                        ToolbarBtn{
                            Layout.fillWidth: true
                            text: "Edit"
                            enabled: selectedGroup.count === 1
                            onClicked: {
                                if(selectedGroup.count === 1){
                                    var selected = selectedGroup.get(0)
                                    prjSetWindow.manage(selected.itemsIndex, selected.model)
                                }
                            }
                        }
                        ToolbarBtn{
                            Layout.fillWidth: true
                            text: "Delete"
                            enabled: selectedGroup.count > 0
                            onClicked: {
                                for(let i = selectedGroup.count-1; i>=0; i--){
                                    let itemSelected = selectedGroup.get(i)
                                    // var object = itemList.get(itemSelected.itemsIndex)
                                    // layout.history("Deleted", object)
                                    // itemList.remove(itemSelected.itemsIndex)
                                    var object = window.manager.prjSetModel.get(itemSelected.itemsIndex)
                                    window.manager.addHistory("Deleted", object.name, object.value, object.desc)
                                    window.manager.prjSetModel.removeItem(itemSelected.itemsIndex)
                                }
                            }
                        }
                        ToolbarBtn{
                            Layout.fillWidth: true
                            text: "Select All"
                            onClicked: {
                                for(var i=0; i< itemModel.items.count; i++){
                                    if(!itemModel.items.get(i).inSelected){
                                        itemModel.items.get(i).inSelected = true
                                    }
                                }
                            }
                        }
                        ToolbarBtn{
                            Layout.fillWidth: true
                            text: "Deselect All"
                            onClicked: {
                                for(var i=0; i< itemModel.items.count; i++){
                                    if(itemModel.items.get(i).inSelected){
                                        itemModel.items.get(i).inSelected = false
                                    }
                                }
                            }
                        }
                        PrjSetWindow{
                            id: prjSetWindow
                            onCreate: (object) => {
                                        //   itemList.append(object);
                                        //   layout.history("Added", object)
                                        window.manager.add(object.name, object.value, object.desc)
                                        window.manager.addHistory("Added", object.name, object.value, object.desc)
                                    }
                            onModify: (index, object) => {
                                        //   itemList.set(index, object);
                                        //   layout.history("Modified", object)
                                        let i = selectedGroup.get(0).itemsIndex
                                        window.manager.edit(root.i, object.name, object.value, object.desc)
                                        window.manager.addHistory("Modified", object.name, object.value, object.desc)
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
                                id: workspace1Header
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
                                id: itemModel
                                model: ListModel{
                                    id: itemList
                                }
                                // model: window.manager.prjSetModel
                                groups: [
                                    DelegateModelGroup {
                                        id: selectedGroup
                                        name: "selected"}
                                ]
                                // delegate: MyItem{
                                //     id: itemDel
                                //     required property var model
                                //     customItem: model.name
                                //     customValue: model.value
                                //     customDesc: model.desc
                                //     width: ListView.view.width
                                //     color: itemDel.DelegateModel.inSelected ? "lightsteelblue" : "transparent"
                                //     // status: itemDel.DelegateModel.inSelected
                                //     onSelected: {
                                //         itemDel.DelegateModel.inSelected = !itemDel.DelegateModel.inSelected
                                //     }
                                // }
                                delegate: dragDelegate
                            }
                            //footer
                            footerPositioning: ListView.OverlayFooter
                            footer: Rectangle{
                                id: workspace1Footer
                                width: parent.width
                                height: 35
                                color: Material.accent
                                z: 2
                                Text{
                                    anchors.centerIn: parent
                                    text: selectedGroup.count + " of " + itemModel.count + " selected"
                                    font.pointSize: 12
                                    font.family: "Montserrat SemiBold"
                                    color: Material.foreground
                                }
                            }
                            Component {
                                id: dragDelegate
                                Rectangle {
                                    id: content
                                    required property var model
                                    required property int index
                                    width: ListView.view.width
                                    height: itemDel.height
                                    color: itemDel.dragArea.held ? "#d6d6d6": "white"
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    radius: 2
                                    ScanArrItem{
                                        id: itemDel
                                        states: State {
                                            when: itemDel.dragArea.pressed
                                            ParentChange {
                                                target: itemDel
                                                parent: content.ListView.view
                                            }
                                        }
                                        Drag.hotSpot.x: width / 2
                                        Drag.hotSpot.y: height / 2
                                        Drag.source: content
                                        Drag.active: itemDel.dragArea.pressed
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                        }
                                        height: 35
                                        width: parent.width
                                        name: model.name
                                        value: model.value
                                        desc: model.desc
                                        content: itemDel
                                        checkBox.checked: DelegateModel.inSelected
                                        color: checkBox.checked ? "lightsteelblue": "transparent"
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                    }
                                    DropArea {
                                        anchors.fill: parent
                                        onEntered: (drag) => {window.manager.moveItem(drag.source.index, content.index)}
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // ScanArr CONFIG
            Item{
                SplitView.fillHeight: true
                SplitView.preferredWidth: parent.width/2
                SplitView.minimumWidth: popUp.visible ? parent.width * 5/9 : parent.width * 5/12
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
                                prjSetWindow.manage(-1,null)
                            }
                        }
                        ToolbarBtn{
                            Layout.fillWidth: true
                            text: "Edit"
                            enabled: selectedGroup.count === 1
                            onClicked: {
                                if(selectedGroup.count === 1){
                                    var selected = selectedGroup.get(0)
                                    prjSetWindow.manage(selected.itemsIndex, selected.model)
                                }
                            }
                        }
                        ToolbarBtn{
                            Layout.fillWidth: true
                            text: "Delete"
                            enabled: selectedGroup.count > 0
                            onClicked: {
                                for(let i = selectedGroup.count-1; i>=0; i--){
                                    let itemSelected = selectedGroup.get(i)
                                    // var object = itemList.get(itemSelected.itemsIndex)
                                    // layout.history("Deleted", object)
                                    // itemList.remove(itemSelected.itemsIndex)
                                    var object = window.manager.prjSetModel.get(itemSelected.itemsIndex)
                                    window.manager.addHistory("Deleted", object.name, object.value, object.desc)
                                    window.manager.prjSetModel.removeItem(itemSelected.itemsIndex)
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
                                for(var i=0; i< itemModel.items.count; i++){
                                    if(!itemModel.items.get(i).inSelected){
                                        itemModel.items.get(i).inSelected = true
                                    }
                                }
                            }
                        }
                        ToolbarBtn{
                            Layout.fillWidth: true
                            text: "Deselect All"
                            onClicked: {
                                for(var i=0; i< itemModel.items.count; i++){
                                    if(itemModel.items.get(i).inSelected){
                                        itemModel.items.get(i).inSelected = false
                                    }
                                }
                            }
                        }
                        PrjSetWindow{
                            id: prjSetWindow2
                            onCreate: (object) => {
                                        //   itemList.append(object);
                                        //   layout.history("Added", object)
                                        window.manager.add(object.name, object.value, object.desc)
                                        window.manager.addHistory("Added", object.name, object.value, object.desc)
                                    }
                            onModify: (index, object) => {
                                        //   itemList.set(index, object);
                                        //   layout.history("Modified", object)
                                        let i = selectedGroup.get(0).itemsIndex
                                        window.manager.edit(root.i, object.name, object.value, object.desc)
                                        window.manager.addHistory("Modified", object.name, object.value, object.desc)
                                    }
                        }
                    }
                    //ScanArr rect
                    ShadowRect{
                        id: scanArrContent2
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
                                id: workspace1Header2
                                width: parent.width
                                height: 35
                                spacing: 0
                                z: 2
                                Repeater{
                                    model: ["Description", "ID", "Scan Arrangement Name"]
                                    Rectangle{
                                        required property string modelData
                                        Layout.fillHeight: true
                                        Layout.fillWidth: modelData === "ID" ? false : true
                                        Layout.preferredWidth: modelData === "ID" ? parent.width/7 : 0
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
                                id: itemModel2
                                // model: ListModel{
                                //     id: itemList
                                // }
                                model: window.manager.prjSetModel
                                groups: [
                                    DelegateModelGroup {
                                        id: selectedGroup2
                                        name: "selected"}
                                ]
                                // delegate: MyItem{
                                //     id: itemDel
                                //     required property var model
                                //     customItem: model.name
                                //     customValue: model.value
                                //     customDesc: model.desc
                                //     width: ListView.view.width
                                //     color: itemDel.DelegateModel.inSelected ? "lightsteelblue" : "transparent"
                                //     // status: itemDel.DelegateModel.inSelected
                                //     onSelected: {
                                //         itemDel.DelegateModel.inSelected = !itemDel.DelegateModel.inSelected
                                //     }
                                // }
                                delegate: dragDelegate
                            }
                            //footer
                            footerPositioning: ListView.OverlayFooter
                            footer: Rectangle{
                                id: workspace1Footer2
                                width: parent.width
                                height: 35
                                color: Material.accent
                                z: 2
                                Text{
                                    anchors.centerIn: parent
                                    text: selectedGroup.count + " of " + itemModel.count + " selected"
                                    font.pointSize: 12
                                    font.family: "Montserrat SemiBold"
                                    color: Material.foreground
                                }
                            }
                            Component {
                                id: dragDelegate2
                                Rectangle {
                                    id: content
                                    required property var model
                                    required property int index
                                    width: ListView.view.width
                                    height: itemDel.height
                                    color: itemDel.dragArea.held ? "#d6d6d6": "white"
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    radius: 2
                                    ScanArrItem{
                                        id: itemDel
                                        states: State {
                                            when: itemDel.dragArea.pressed
                                            ParentChange {
                                                target: itemDel
                                                parent: content.ListView.view
                                            }
                                        }
                                        Drag.hotSpot.x: width / 2
                                        Drag.hotSpot.y: height / 2
                                        Drag.source: content
                                        Drag.active: itemDel.dragArea.pressed
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                        }
                                        height: 35
                                        width: parent.width
                                        name: model.name
                                        value: model.value
                                        desc: model.desc
                                        content: itemDel
                                        checkBox.checked: DelegateModel.inSelected
                                        color: checkBox.checked ? "lightsteelblue": "transparent"
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                    }
                                    DropArea {
                                        anchors.fill: parent
                                        onEntered: (drag) => {window.manager.moveItem(drag.source.index, content.index)}
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
