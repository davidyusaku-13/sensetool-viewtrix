import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Controls

Rectangle{
    id: root
    width: 1920
    height: 1080
    //title: "Sense Trix"

    property int buttonSize: 50
    property int buttonMargin: 7
    property string buttonColor: "#ffffff"
    property string buttonHover: "#d6d6d6"
    property var firstSelected: selectedGroup.count > 0 ? selectedGroup.get(0) : ""
    property int i: firstSelected !== "" ? firstSelected.itemsIndex : 0

    function history(status, object){
        var temp = {
            "status": status,
            "name": object["name"],
            "value": object["value"],
            "desc": object["desc"]
        }
        historyList.append(temp)
    }
    ListModel{
        id: historyList
    }
    ColumnLayout{
        anchors.fill: parent
        spacing: 1
        //header
        Rectangle{
            id: header
            Layout.fillWidth: true
            implicitHeight: 50

            layer.enabled: true
            layer.effect: DropShadow{
                horizontalOffset: 0
                verticalOffset: 0
                radius: 4.0
                color: "#80000000"
            }
            RowLayout{
                anchors.fill: parent
                spacing: 0
                //menuBtn
                Item{
                    id: menuBtn
                    implicitWidth: root.buttonSize
                    implicitHeight: root.buttonSize
                    MyButton{
                        anchors.fill: parent
                        anchors.margins: root.buttonMargin
                        customColor: root.buttonColor
                        customHoveredColor: root.buttonHover

                        onClicked: {
                            sidebar.folded = !sidebar.folded
                        }
                    }
                }
                //fill empty space
                Item{
                    Layout.fillWidth: true
                }
                //notif
                Item{
                    implicitWidth: root.buttonSize
                    implicitHeight: root.buttonSize
                    MyButton{
                        anchors.fill: parent
                        anchors.margins: root.buttonMargin
                        customColor: root.buttonColor
                        customHoveredColor: root.buttonHover
                        customImage: "images/notification"

                        onClicked: {
                            notif.visible = !notif.visible
                            for(let i=0; i<historyList.count; i++){
                                    print(JSON.stringify(historyList.get(i)))
                                }
                        }
                    }
                }
                //setting
                Item{
                    id: settingBtn
                    implicitWidth: root.buttonSize
                    implicitHeight: root.buttonSize
                    MyButton{
                        anchors.fill: parent
                        anchors.margins: root.buttonMargin
                        customColor: root.buttonColor
                        customHoveredColor: root.buttonHover
                        customImage: "images/setting"

                        onClicked: {

                        }
                    }
                }
            }
        }
        //sidebar + workspace
        RowLayout{
            Layout.fillHeight: true
            spacing: 0
            //sidebar
            Rectangle{
                id: sidebar
                implicitWidth: 50
                Layout.fillHeight: true
                color: "#ffffff"

                layer.enabled: true
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 4.0
                    color: "#80000000"
                }
                transitions: [
                    Transition {
                        NumberAnimation {
                            properties: "width,opacity"
                            duration: 200
                        }
                    }
                ]
                property bool folded: false
                state: !folded ? "Visible" : "Invisible"
                states: [
                    State{
                        name: "Visible"
                        PropertyChanges{target: sidebar; width: 50; visible: true}
                    },
                    State{
                        name:"Invisible"
                        PropertyChanges{target: sidebar; width: 0.0; visible: false}
                    }
                ]
                //ws1btn
                Item{
                    id: ws1btn
                    width: root.buttonSize
                    height: root.buttonSize
                    MyButton{
                        anchors.fill: parent
                        anchors.margins: root.buttonMargin
                        customColor: workspace1.visible === false ? root.buttonColor : root.buttonHover
                        customHoveredColor: workspace1.visible === false ? root.buttonHover : "#C2C2C2"
                        customImage: "images/import"

                        onClicked: {
                            workspace1.visible === true ? workspace1.visible = false : workspace1.visible = true
                        }
                    }
                }
            }
            //workspace
            StackLayout{
                id: layout
                Layout.fillHeight: true
                Layout.fillWidth: true
                currentIndex: 0
                //workspace1
                Rectangle{
                    id: workspace1
                    anchors.fill: parent
                    color: "#00000000"
                    visible: true

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
                        Rectangle{
                            Layout.fillWidth: true
                            implicitHeight: 28
                            RowLayout{
                                anchors.fill: parent
                                //add or edit window
                                PrjSetWindow{
                                    id: prjSetWindow
                                    onCreate: (object) => {
                                                  itemList.append(object);
                                                  root.history("Added", object)
                                              }
                                    onModify: (object) => {
                                                  itemList.set(root.i, object)
                                                  root.history("Modified", object)
                                              }
                                }
                                //importBtn
                                Item{
                                    implicitWidth: 70
                                    implicitHeight: 28
                                    MyText2{
                                        id: importBtn
                                        anchors.fill: parent

                                        customRadius: 5
                                        customText: "Import"
                                        customHAlignment: "Center"
                                        customSize: 15
                                        customColor: "#000000"
                                        customHoveredColor: "#332C2B"
                                        customTextColor: "#ffffff"

                                        HoverHandler {
                                            acceptedDevices: PointerDevice.Mouse
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                                //exportBtn
                                Item{
                                    implicitWidth: 70
                                    implicitHeight: 28
                                    MyText2{
                                        id: exportBtn
                                        anchors.fill: parent

                                        customRadius: 5
                                        customText: "Export"
                                        customHAlignment: "Center"
                                        customSize: 15
                                        customColor: "#000000"
                                        customHoveredColor: "#332C2B"
                                        customTextColor: "#ffffff"

                                        HoverHandler {
                                            acceptedDevices: PointerDevice.Mouse
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                                //addBtn
                                Item{
                                    implicitWidth: 50
                                    implicitHeight: 28
                                    MyText2{
                                        id: addButton
                                        anchors.fill: parent

                                        customRadius: 5
                                        customText: "Add"
                                        customHAlignment: "Center"
                                        customSize: 15
                                        customColor: "#000000"
                                        customHoveredColor: "#332C2B"
                                        customTextColor: "#ffffff"

                                        HoverHandler {
                                            acceptedDevices: PointerDevice.Mouse
                                            cursorShape: Qt.PointingHandCursor
                                        }

                                        onClicked: {
                                            //window.manager.add("item", "value", "desc", "false")
                                            prjSetWindow.manage(-1,null)
                                        }
                                    }
                                }
                                //editBtn
                                Item{
                                    implicitWidth: 50
                                    implicitHeight: 28
                                    MyText2{
                                        id: editBtn
                                        anchors.fill: parent
                                        customRadius: 5
                                        customText: "Edit"
                                        customHAlignment: "Center"
                                        customSize: 15
                                        customColor: selectedGroup.count === 1 ? "#000000" : "#8B8B8C"
                                        customHoveredColor: selectedGroup.count === 1 ? "#332C2B" : customColor
                                        customTextColor: "#ffffff"

                                        HoverHandler {
                                            id: cursorHovered
                                            acceptedDevices: PointerDevice.Mouse
                                            cursorShape: Qt.PointingHandCursor
                                            enabled: selectedGroup.count === 1 ? true : false
                                        }

                                        onClicked: {
                                            //window.manager.add("item", "value", "desc", "false")
                                            if(selectedGroup.count === 1){
                                                prjSetWindow.manage(root.i, root.firstSelected.model)
                                            }
                                        }
                                    }
                                }
                                //deleteBtn
                                Item{
                                    implicitWidth: 70
                                    implicitHeight: 28
                                    MyText2{
                                        id: deleteBtn
                                        anchors.fill: parent
                                        customRadius: 5
                                        customText: "Delete"
                                        customHAlignment: "Center"
                                        customSize: 15
                                        customColor: selectedGroup.count > 0 ? "#000000" : "#8B8B8C"
                                        customHoveredColor: selectedGroup.count > 0 ? "#332C2B" : customColor
                                        customTextColor: "#ffffff"

                                        HoverHandler {
                                            // id: cursorHovered
                                            acceptedDevices: PointerDevice.Mouse
                                            cursorShape: Qt.PointingHandCursor
                                        }

                                        onClicked: {
                                            //window.manager.add("item", "value", "desc", "false")
                                            print(selectedGroup.count)
                                            for(let i = selectedGroup.count-1; i>=0; i--){
                                                    let itemSelected = selectedGroup.get(i)
                                                    var object = itemList.get(itemSelected.itemsIndex)
                                                    root.history("Deleted", object)
                                                    itemList.remove(itemSelected.itemsIndex)
                                            }
                                        }
                                    }
                                }
                                //fill empty space
                                Item{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                                //deselectAllBtn
                                Item{
                                    implicitWidth: 110
                                    implicitHeight: 28
                                    MyText2{
                                        id: deselectAllBtn

                                        anchors.fill: parent

                                        customRadius: 5
                                        customText: "Deselect All"
                                        customHAlignment: "Center"
                                        customSize: 15
                                        customColor: "#000000"
                                        customHoveredColor: "#332C2B"
                                        customTextColor: "#ffffff"

                                        HoverHandler {
                                            // id: cursorHovered
                                            acceptedDevices: PointerDevice.Mouse
                                            cursorShape: Qt.PointingHandCursor
                                        }

                                        onClicked: {
                                            //window.manager.add("item", "value", "desc", "false")
                                            for(var i=0; i< itemModel.items.count; i++){
                                                if(itemModel.items.get(i).inSelected){
                                                    itemModel.items.get(i).inSelected = false
                                                }
                                            }
                                        }
                                    }
                                }
                                //selectAllBtn
                                Item{
                                    implicitWidth: 90
                                    implicitHeight: 28
                                    MyText2{
                                        id: selectAllBtn

                                        anchors.fill: parent

                                        customRadius: 5
                                        customText: "Select All"
                                        customHAlignment: "Center"
                                        customSize: 15
                                        customColor: "#000000"
                                        customHoveredColor: "#332C2B"
                                        customTextColor: "#ffffff"

                                        HoverHandler {
                                            // id: cursorHovered
                                            acceptedDevices: PointerDevice.Mouse
                                            cursorShape: Qt.PointingHandCursor
                                        }

                                        onClicked: {
                                            //window.manager.add("item", "value", "desc", "false")
                                            for(var i=0; i< itemModel.items.count; i++){
                                                if(!itemModel.items.get(i).inSelected){
                                                    itemModel.items.get(i).inSelected = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        //content
                        Rectangle{
                            id: content
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#ffffff"

                            layer.enabled: true
                            layer.effect: DropShadow{
                                horizontalOffset: 0
                                verticalOffset: 0
                                radius: 3.0
                                color: "#80000000"
                            }
                            ColumnLayout{
                                anchors.fill: parent
                                ListView{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    interactive: true
                                    clip: true
                                    //header
                                    headerPositioning: ListView.OverlayHeader
                                    header: RowLayout{
                                        id: workspace1Header
                                        width: parent.width
                                        height: 50
                                        spacing: 0
                                        z: 2
                                        Rectangle{
                                            implicitWidth: 50
                                            Layout.fillHeight: true
                                            color: "#d6d6d6"
                                        }
                                        Repeater{
                                            model: ["Item", "Value", "Description"]
                                            Rectangle{
                                                required property string modelData
                                                Layout.fillHeight: true
                                                Layout.fillWidth: modelData === "Description" ? false : true
                                                implicitWidth: modelData === "Description" ? 500 : 0
                                                color: "#d6d6d6"

                                                // layer.enabled: true
                                                // layer.effect: DropShadow{
                                                //     horizontalOffset: 2
                                                //     verticalOffset: 0
                                                //     radius: 2.0
                                                //     color: "#80767676"
                                                // }
                                                Text {
                                                    text: parent.modelData
                                                    anchors.centerIn: parent
                                                    font.pointSize: 15
                                                    font.family: "Montserrat SemiBold"
                                                }
                                            }
                                        }
                                        Rectangle{
                                            implicitWidth: 50
                                            Layout.fillHeight: true
                                            color: "#d6d6d6"
                                        }
                                    }
                                    //item list
                                    model: DelegateModel{
                                        id: itemModel
                                        model: ListModel{
                                            id: itemList
                                        }
                                        groups: [
                                            DelegateModelGroup {
                                                id: selectedGroup
                                                name: "selected"}
                                        ]
                                        delegate: MyItem{
                                            id: itemDel
                                            required property var model
                                            customItem: model.name
                                            customValue: model.value
                                            customDesc: model.desc
                                            customWidth: ListView.view.width
                                            checkState: itemDel.DelegateModel.inSelected

                                            onChecked: (checkState) => {
                                                           itemDel.DelegateModel.inSelected = !itemDel.DelegateModel.inSelected
                                                       }
                                        }
                                    }
                                    //footer
                                    footerPositioning: ListView.OverlayFooter
                                    footer: Rectangle{
                                        id: workspace1Footer
                                        width: parent.width
                                        height: 35
                                        color: "#d6d6d6"
                                        z: 2
                                        Text{
                                            anchors.centerIn: parent
                                            text: selectedGroup.count + " of " + itemModel.count + " selected"
                                            font.pointSize: 12
                                            font.family: "Montserrat SemiBold"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
            //notif pop-up
            Rectangle{
                id: notif
                implicitWidth:  350
                Layout.fillHeight: true
                color: "#ffffff"
                visible: false

                layer.enabled: true
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 4.0
                    color: "#80000000"
                }
                ColumnLayout{
                    anchors.fill: parent
                    ListView{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        model: historyList
                        //header
                        header: Rectangle{
                            width: parent.width
                            height: 50
                            color: "#d6d6d6"
                            Text{
                                text: "Notification"
                                font.pixelSize: 20
                                font.family: "Montserrat Medium"
                                anchors.centerIn: parent
                            }
                        }
                        delegate: Text{
                            required property var model
                            width: parent.width
                            text: model.status+"(name: "+model.name+", value: "+model.value+", desc: "+model.desc+")"
                            font.pixelSize: 15
                            font.family: "Montserrat Medium"
                            wrapMode: Text.WordWrap
                        }
                    }
                    Item{
                        implicitWidth: 90
                        implicitHeight: 28
                        anchors.margins: 20
                        MyText2{
                            anchors.fill: parent

                            customRadius: 5
                            customText: "Clear All"
                            customHAlignment: "Center"
                            customSize: 15
                            customColor: "transparent"
                            customHoveredColor: "#332C2B"
                            customTextColor: "#000000"

                            HoverHandler {
                                acceptedDevices: PointerDevice.Mouse
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }
}

