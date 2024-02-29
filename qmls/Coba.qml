import QtQuick 2.15
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

    ColumnLayout{
        anchors.fill: parent
        spacing: 0
        //header
        RowLayout{
            height: 100
            Layout.fillWidth: true
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
                        sidebar.visible === true ? sidebar.visible=false : sidebar.visible=true
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

        //sidebar + workspace
        RowLayout{
            Layout.fillHeight: true
            spacing: 0

            //sidebar
            Rectangle{
                id: sidebar
                width: 50
                Layout.fillHeight: true
                visible: false

                // color: "blue"

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
                visible: false

                // color: "yellow"

                ColumnLayout{
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    //toolbar
                    Rectangle{
                        Layout.fillWidth: true
                        height: 28

                        // color: "pink"

                        RowLayout{
                            anchors.fill: parent

                            //addBtn
                            Item{
                                width: 50
                                height: 28
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
                                        // id: cursorHovered
                                        acceptedDevices: PointerDevice.Mouse
                                        cursorShape: Qt.PointingHandCursor
                                    }

                                    onClicked: {
                                        window.manager.add("item", "value", "desc", "false")
                                    }
                                }
                            }

                            //editBtn
                            Item{
                                width: 50
                                height: 28
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
                                        window.manager.add("item", "value", "desc", "false")
                                    }
                                }
                            }

                            //deleteBtn
                            Item{
                                width: 70
                                height: 28
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
                                        window.manager.add("item", "value", "desc", "false")
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
                                width: 110
                                height: 28
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
                                        window.manager.add("item", "value", "desc", "false")
                                    }
                                }
                            }

                            //selectAllBtn
                            Item{
                                width: 90
                                height: 28
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
                                        window.manager.add("item", "value", "desc", "false")
                                    }
                                }
                            }
                        }
                    }

                    //content
                    Rectangle{
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        color: "green"


                    }
                }
            }
        }
    }
}
