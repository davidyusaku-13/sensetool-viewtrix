import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Rectangle{
    id: root

    width: 1920
    height: 1080

    property int buttonSize: 50
    property int buttonMargin: 7
    property string buttonColor: "#ffffff"
    property string buttonHover: "#d6d6d6"
    property var firstSelected: selectedGroup.count > 0 ? selectedGroup.get(0) : ""
    property int i: firstSelected !== "" ? firstSelected.itemsIndex : 0

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
                        customColor: root.buttonColor
                        customHoveredColor: root.buttonHover
                        customImage: "images/import"

                        onClicked: {
                            workspace1.visible === true ? workspace1.visible=false : workspace1.visible=true
                        }
                    }
                }
            }

            //workspace1
            Rectangle{
                id: workspace1
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                        //color: "pink"

                        RowLayout{
                            anchors.fill: parent

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
                                PrjSetWindow{
                                    id: prjSetWindow
                                    onCreate: (object) => {
                                                  itemList.append(object);
                                              }
                                    onModify: (object) => {
                                                  itemList.set(root.i, object)
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
                                        if(selectedGroup.count > 0){
                                            // firstSelected = selectedGroup.get(0)
                                            // i = firstSelected.itemsIndex
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
                                        print(selectedGroup.count)
                                        for(let i = selectedGroup.count-1; i>=0; i--){
                                            let itemSelected = selectedGroup.get(i)
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
                                            print(i)
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
                        radius: 5

                        layer.enabled: true
                        layer.effect: DropShadow{
                            horizontalOffset: 0
                            verticalOffset: 0
                            radius: 3.0
                            color: "#80000000"
                        }

                        ListView{
                            anchors.fill: parent
                            clip: true

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
                                    customItem: model.name+checkState
                                    customValue: model.value
                                    customDesc: model.desc
                                    customWidth: ListView.view.width
                                    checkState: itemDel.DelegateModel.inSelected

                                    onChecked: (checkState) => {
                                                   itemDel.DelegateModel.inSelected = !itemDel.DelegateModel.inSelected
                                               }
                                }
                            }

                            //model: ListModel{
                            //id: itemList
                            // ListElement{item: "GUI_ENABLE"; value: ""; desc: "Used for enable the gui feature (DEBUG USE)"}
                            // ListElement{item: "OS_EVENT_QUEUE"; value: "8"; desc: "Queue deep value"}
                            // ListElement{item: "OS_MSG_LEN_QUEUE"; value: "12"; desc: "Message length for queue"}
                            // ListElement{item: "OS_UART_LEN_QUEUE"; value: "64"; desc: "Message length for UART queue"}
                            // ListElement{item: "EVT_FIFO_DEEP_MAX"; value: "16"; desc: ""}
                            // ListElement{item: "EVT_FIFO_LEN_MAX"; value: "sizeof(sEventFIFOmsg)"; desc: ""}
                            // ListElement{item: "CMD_FIFO_DEEP_MAX"; value: "8"; desc: ""}
                            //}
                        }
                    }
                }

            }
        }
    }
}

