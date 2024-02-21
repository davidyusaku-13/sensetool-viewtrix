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

                        if(workspace1.visible === true){
                            workspace1.anchors.leftMargin = 50
                        }
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
            property list<Dictionary> menuList:[
                Dictionary{
                    customImage: "images/import.png"
                    customWorkspace: workspace1
                }
                // Dictionary{
                //     customWorkspace: workspace2
                // },
                // Dictionary{
                //     customWorkspace: workspace3
                // }
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

                width: menu.width+menu.anchors.leftMargin*2
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

                //list menu
                Grid {
                    id: grid

                    x: menu.anchors.leftMargin
                    y: menu.height+menu.anchors.topMargin*2

                    width: leftSidebar.width-menu.anchors.leftMargin*2
                    height: leftSidebar.height - (menu.height +
                                                  menu.anchors.topMargin*2)
                    spacing: 10

                    rows: 1
                    columns: 1
                    Repeater{
                        id: repeater
                        model: root.menuList
                        MyButton{
                            customIconWidth: 25
                            customIconHeight: 25
                            customImage: model.customImage
                            customColor: "#ffffff"
                            customHoveredColor: "#DCDDDD"
                            customRadius: 5

                            onClicked: {
                                customColor = "#DCDDDD"
                                if(model.customWorkspace === workspace1){
                                    workspace1.visible = true
                                    workspace1.anchors.leftMargin = 50 +
                                            leftSidebar.width
                                }
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
                customHoveredColor: "#DCDDDD"
                customRadius: 5

                MouseArea{
                    anchors.fill:parent
                    onClicked:{
                        if(menuState === false){
                            lsAnimationOn.running = true
                            menuState = true

                            if(workspace1.visible === true){
                                workspace1.anchors.leftMargin = 50+leftSidebar.width
                            }
                        }else{
                            lsAnimationOff.running = true
                            menuState = false

                            if(workspace1.visible === true){
                                workspace1.anchors.leftMargin = 50
                            }
                        }
                    }
                }
            }

            //grid for right icon
            Grid {
                id: rightIconGrid

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
                    customHoveredColor: "#DCDDDC"
                    customRadius: 5

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
                    customHoveredColor: "#DCDDDD"
                    customRadius: 5

                    MouseArea{
                        anchors.fill:parent
                        onClicked:{

                        }
                    }
                }
            }

            //setting pop up
            Rectangle{
                id: settingPopUp

                width: 150
                height: 30*3

                radius: 5*3

                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: menu.anchors.leftMargin
                anchors.topMargin: setting.height+rightIconGrid.anchors.topMargin+10

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
                    id: settingGrid
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
            //function button in workspace1
            property list<Dictionary> funcBtnModel:[
                Dictionary{
                    customName: "Add"
                    customImage: "images/plus"
                    customWidth: 50
                },
                Dictionary{
                    customName: "Delete"
                    customImage: "images/trash"
                    customWidth: 70
                },
                Dictionary{
                    customName: "Edit"
                    customImage: "images/trash"
                    customWidth: 50
                }
            ]

            //workspace1
            Rectangle {
                id: workspace1

                anchors.top: parent.top
                anchors.topMargin: ((menu.anchors.topMargin*2)+menu.height)
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50
                anchors.left: parent.left
                anchors.leftMargin: 50
                anchors.right: parent.right
                anchors.rightMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter

                color: "#ffffff"
                radius: 5
                border.width: 0
                border.color: "#332C2B"

                visible: false

                Rectangle{
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.horizontalCenter: parent.horizontalCenter

                    color: "#ffffff"
                    radius: 5
                    border.width: 0
                    border.color: "#332C2B"

                    layer.enabled: true
                    layer.effect: DropShadow{
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 4.0
                        color: "#80000000"
                    }
                }

                //function button
                Grid {
                    id: grid1

                    x: 0
                    y: parent.y-(menu.height+(menu.anchors.topMargin*2))

                    width: 300
                    height: 38

                    spacing: 5
                    columns: 3

                    Repeater{
                        model: root.funcBtnModel
                        // MyButton{
                        //     width: 28
                        //     height: 28

                        //     customImage: model.customImage
                        //     customColor: "#ffffff"
                        //     customHoveredColor: "#DCDDDD"
                        //     customRadius: 5
                        // }
                        MyText{
                            width: model.customWidth
                            height: 28

                            customRadius: 5
                            customText: model.customName
                            customHAlignment: "Center"
                            customSize: 15
                            customColor: down ? "#332C2B" : customHoveredColor
                            customHoveredColor: "#000000"
                            customTextColor: "#ffffff"

                            HoverHandler {
                                id: cursorHovered
                                acceptedDevices: PointerDevice.Mouse
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    // }
// }
