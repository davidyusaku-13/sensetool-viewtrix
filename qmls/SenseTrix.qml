import QtQuick 6.5
import QtQuick.Controls 6.5
import Qt5Compat.GraphicalEffects
import QtQuick.Dialogs
import QtQuick.Window

// ApplicationWindow{
//     width: 1920
//     height: 1080

//     property bool menuState: false
//     property bool settingState: false

    // Rectangle {
    //     id: root

    //     anchors.fill: parent
    //     color: "#ffffff"

        Rectangle{
            width: 1920
            height: 1080

            property bool menuState: false
            property bool settingState: false
            id: root

            anchors.fill: parent
            color: "#ffffff"

            //mouse area for close every window
            MouseArea {
                id: closeWindow

                x: 0
                y: root.y

                width: root.width - leftSidebar.width
                height: root.height

                anchors.right: parent.right
                anchors.rightMargin: 0

                onClicked: {
                    if(menuState === true){
                        lsAnimationOff.running = true
                        menuState = false
                    }if(settingState === true){
                        settingPopUp.visible = false
                        settingState = false
                    }
                }
            }

            // Drawer {
            //     id: drawer
            //     width: 0.66 * root.width
            //     height: root.height

            //     Label {
            //         text: "Content goes here!"
            //         anchors.centerIn: parent
            //     }
            // }



            //dictionary for project in left sidebar
            property list<Dictionary> menuModel:[
                Dictionary{
                    customName: "Project 1"
                    customWorkspace: workspace1
                },
                Dictionary{
                    customName: "Project 2"
                    customWorkspace: workspace2
                },
                Dictionary{
                    customName: "Project 3"
                    customWorkspace: workspace3
                }
            ]

            //dictionary for setting
            property list<Dictionary> settingModel:[
                Dictionary{
                    customName: "Theme"
                },
                Dictionary{
                    customName: "Setting 2"
                },
                Dictionary{
                    customName: "Setting 3"
                }
            ]

            //left sidebar
            Rectangle {
                id: leftSidebar

                x:-width
                y: root.y

                width: 150
                height: root.height

                visible: true

                color: "#ffffff"
                border.width: 0

                //animation
                PropertyAnimation{
                    id: lsAnimationOn
                    target: leftSidebar
                    property: "x"
                    to: root.x
                    duration: 150
                }

                PropertyAnimation{
                    id: lsAnimationOff
                    target: leftSidebar
                    property: "x"
                    to: -width
                    duration: 150
                }

                //project list
                Grid {
                    id: grid

                    x: 20
                    y: 105

                    width: leftSidebar.width-menu.anchors.leftMargin*2
                    height: leftSidebar.height - (menu.height +
                                                  menu.anchors.topMargin*3)
                    spacing: 10

                    rows: 5
                    columns: 1

                    Repeater{
                        id: repeaterMenu
                        model: root.menuModel
                        MyText{
                            width: grid.width
                            height: width/3

                            customText: model.customName
                            customSize: 13

                            onClicked: {
                                model.customWorkspace.visible = true
                                lsAnimationOff.running = true

                                menu.customColor = "#f4d7fb"
                                menu.customHoveredColor = "#E3BBED"

                                menuState = false
                            }
                        }
                    }
                }
            }

            //left sidebar shadow
            DropShadow{
                anchors.fill: leftSidebar
                horizontalOffset: 0
                verticalOffset: 0
                radius: 4.0
                color: "#80000000"
                source: leftSidebar
            }

            //menu button
            MyButton {
                id: menu

                anchors.left: root.left
                anchors.top: root.top
                anchors.leftMargin: 10
                anchors.topMargin: 10

                customImage: "images/menu-icon2.png"
                customColor: "#ffffff"
                customHoveredColor: "#E1E1E1"
                customRadius: 5

                MouseArea{
                    anchors.fill:parent
                    onClicked:{
                        if(menuState === false){
                            lsAnimationOn.running = true
                            menuState = true
                        }else{
                            lsAnimationOff.running = true
                            menuState = false
                        }
                    }
                }
            }

            //grid for left icon
            Grid {
                id: leftIcontGrid

                x: 1480

                anchors.right: root.right
                anchors.top: root.top
                anchors.rightMargin: menu.anchors.leftMargin
                anchors.topMargin: menu.anchors.topMargin

                spacing: 5
                layoutDirection: Qt.RightToLeft

                width: 420
                height: 45

                //setting
                MyButton {
                    id: setting

                    customImage: "images/setting.png"
                    customColor: "#ffffff"
                    customHoveredColor: "#e1e1e1"

                    MouseArea{
                        anchors.fill:parent
                        onClicked:{
                            if(settingState === false){
                                settingPopUp.visible = true
                                settingState = true
                            }else{
                                settingPopUp.visible = false
                                settingState = false
                            }
                        }
                    }
                }

                //notification icon
                MyButton {
                    id: notification

                    customImage: "images/notification.png"
                    customColor: "#ffffff"
                    customHoveredColor: "#e1e1e1"

                    MouseArea{
                        anchors.fill:parent
                        onClicked:{

                        }
                    }
                }
            }

            //workspace
            property list<Rectangle> workspace:[workspace1, workspace2, workspace3]
            Rectangle {
                id: workspace1

                width: root.width-100

                anchors.top: parent.top
                anchors.topMargin: menu.anchors.topMargin+menu.height+20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter

                color: "#ffffff"
                radius: 10
                border.width: 0

                visible: false

                layer.enabled: true
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 4.0
                    color: "#80000000"
                }

            }

            //setting pop up
            Rectangle{
                id: settingPopUp

                width: leftSidebar.width
                height: 30*3

                radius: 5*3

                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: menu.anchors.leftMargin
                anchors.topMargin: setting.height+leftIcontGrid.anchors.topMargin+10

                visible: false

                color: "#ffffff"

                layer.enabled: true
                layer.effect: DropShadow{
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 4.0
                    color: "#80000000"
                }

                Grid{
                    id: grid3
                    anchors.fill: parent

                    rows: 10
                    flow: Grid.TopToBottom

                    Repeater{
                        model: root.settingModel
                        MyText{
                            width: parent.width
                            height: 30

                            customText: model.customName
                            customSize: 15
                            customRadius: 5
                            customFont: "Montserrat"
                        }
                    }
                }
            }
        }
    // }
// }
