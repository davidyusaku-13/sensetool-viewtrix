import QtQuick
import QtQuick.Controls 2.15
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
    property bool sidebarState: false

    ColumnLayout{
        anchors.fill: parent
        spacing: 1
        //header
        Rectangle{
            id: header
            Layout.fillWidth: true
            height: 50

            layer.enabled: true
            layer.effect: DropShadow{
                horizontalOffset: 0
                verticalOffset: 0
                radius: 4.0
                color: "#80000000"
            }
            RowLayout{
                anchors.fill: parent
                //menuBtn
                Item{
                    id: menuBtn
                    width: buttonSize
                    height: buttonSize
                    MyButton{
                        anchors.fill: parent
                        anchors.margins: buttonMargin
                        customColor: buttonColor
                        customHoveredColor: buttonHover

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
                    width: buttonSize
                    height: buttonSize
                    anchors.right: settingBtn.left
                    anchors.rightMargin: -10
                    MyButton{
                        anchors.fill: parent
                        anchors.margins: buttonMargin
                        customColor: buttonColor
                        customHoveredColor: buttonHover
                        customImage: "images/notification"

                        onClicked: {

                        }
                    }
                }
                //setting
                Item{
                    id: settingBtn
                    width: buttonSize
                    height: buttonSize
                    MyButton{
                        anchors.fill: parent
                        anchors.margins: buttonMargin
                        customColor: buttonColor
                        customHoveredColor: buttonHover
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
                width: 50
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
                        PropertyChanges{target: sidebar; width: 50}
                        PropertyChanges{target: sidebar; visible: true}
                    },
                    State{
                        name:"Invisible"
                        PropertyChanges{target: sidebar; width: 0.0}
                        PropertyChanges{target: sidebar; visible: false}
                    }
                ]

                //ws1btn
                Item{
                    id: ws1btn
                    width: buttonSize
                    height: buttonSize
                    MyButton{
                        anchors.fill: parent
                        anchors.margins: buttonMargin
                        customColor: buttonColor
                        customHoveredColor: buttonHover
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
                                        // let item = {item:"fewfe", value:"9", desc:"vekfi"}
                                        // itemList.append(item);
                                        addWindow.show()
                                    }
                                }
                                AddWindow{
                                    id: addWindow
                                    visible: false
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
                                    }
                                }
                            }
                        }
                    }

                    //content
                    Rectangle{
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

                        //addButton.clicked: {

                        //}

                        ListView{
                            anchors.fill: parent
                            clip: true

                            // FROM BACKEND DO NOT DELETE
                            // model: visualModel

                            model: ListModel{
                                id: itemList
                                // ListElement{item: "GUI_ENABLE"; value: ""; desc: "Used for enable the gui feature (DEBUG USE)"}
                                // ListElement{item: "OS_EVENT_QUEUE"; value: "8"; desc: "Queue deep value"}
                                // ListElement{item: "OS_MSG_LEN_QUEUE"; value: "12"; desc: "Message length for queue"}
                                // ListElement{item: "OS_UART_LEN_QUEUE"; value: "64"; desc: "Message length for UART queue"}
                                // ListElement{item: "EVT_FIFO_DEEP_MAX"; value: "16"; desc: ""}
                                // ListElement{item: "EVT_FIFO_LEN_MAX"; value: "sizeof(sEventFIFOmsg)"; desc: ""}
                                // ListElement{item: "CMD_FIFO_DEEP_MAX"; value: "8"; desc: ""}
                            }

                            delegate: MyItem{
                                id: listItem
                                customItem: model.item
                                customValue: model.value
                                customDesc: model.desc
                                customWidth: ListView.view.width
                            }
                        }
                    }
                }
            }
        }
    }
}