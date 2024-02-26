import QtQuick 6.5
import QtQuick.Controls 6.5
import Qt5Compat.GraphicalEffects
import QtQuick.Dialogs
import QtQuick.Window
import PrjSetModel

// ApplicationWindow{
//     width: 1920
//     height: 1080

//     property bool menuState: false
//     property bool settingState: false

//     Rectangle {
//         id: root

//         anchors.fill: parent
//         color: "#ffffff"

        Rectangle{
            id: root

            width: 1920
            height: 1080

            property bool menuState: false
            property bool settingState: false
            property bool selectState: false

            anchors.fill: parent
            color: "#ffffff"

            Drawer{
                id: drawer
                width: 0.66 * root.width
                height: root.height
            }

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

                customImage: "images/menu-icon2"
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
                    id: workspaceItem
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.horizontalCenter: parent.horizontalCenter

                    color: "#ffffff"
                    radius: 5
                    border.width: 0
                    border.color: "#A1A1A1"

                    layer.enabled: true
                    layer.effect: DropShadow{
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 4.0
                        color: "#80000000"
                    }

                    ScrollView{
                        id: scrollItem
                        anchors.fill: parent
                        hoverEnabled: true
                        //enabled: itemModel.length*50>workspaceItem.height ? true : false
                        enabled: true

                        Grid{
                            anchors.fill: parent
                            rows: itemModel.length

                                DelegateModel {
                                    id: visualModel
                                    model: window.manager.prjSetModel

                                    groups: [
                                        DelegateModelGroup { name: "selected" }
                                    ]
                                    
                                    delegate: MyItem{
                                        id: listItem

                                        // customItemName: model.text + index + selectState
                                        customItemName: setitem + " | " + val + " | " + desc + " | " + selectState
                                        customWidth: workspaceItem.width
                                        customItemSize: 15
                                    }
                                }

                            ListView{
                                anchors.fill: parent
                                model: visualModel

                                // model: ListModel{
                                //     ListElement{text: "file 1 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 2 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 3 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 4 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 5 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 6 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 7 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 8 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 9 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 10 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 11 - csnjacbnjknbjcbn"}
                                //     ListElement{text: "file 12 - csnjacbnjknbjcbn"}
                                // }

                                // delegate: MyItem{
                                //     id: listItem

                                //     // customItemName: model.text + index + selectState
                                //     customItemName: setitem + " | " + val + " | " + desc + " | " + selectState
                                //     customWidth: workspaceItem.width
                                //     customItemSize: 15
                                // }
                            }
                        }
                    }
                }

                //function button icon
                // MyButton{
                //     width: 28
                //     height: 28

                //     customImage: model.customImage
                //     customColor: "#ffffff"
                //     customHoveredColor: "#DCDDDD"
                //     customRadius: 5
                // }

                //function button text
                //add
                MyText2{
                    id: addButton

                    x: 0
                    y: 0

                    width: 50
                    height: 28

                    customRadius: 5
                    customText: "Add"
                    customHAlignment: "Center"
                    customSize: 15
                    customColor: "#000000"
                    customHoveredColor: "#332C2B"
                    customTextColor: "#ffffff"

                    HoverHandler {
                        id: cursorHovered
                        acceptedDevices: PointerDevice.Mouse
                        cursorShape: Qt.PointingHandCursor
                    }

                    onClicked: {
                        window.manager.add("item", "value", "desc", "false")
                    }
                }

                //delete
                MyText2{
                    id: deleteButton

                    x: addButton.width+5
                    y: 0

                    width: 70
                    height: 28

                    customRadius: 5
                    customText: "Delete"
                    customHAlignment: "Center"
                    customSize: 15
                    customColor: "#000000"
                    customHoveredColor: "#332C2B"
                    customTextColor: "#ffffff"

                    HoverHandler {
                        id: cursorHovered1
                        acceptedDevices: PointerDevice.Mouse
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                //edit
                MyText2{
                    id: editButton

                    x: (addButton.width+5)+(deleteButton.width+5)
                    y: 0

                    width: 50
                    height: 28

                    customRadius: 5
                    customText: "Edit"
                    customHAlignment: "Center"
                    customSize: 15
                    customColor: "#000000"
                    customHoveredColor: "#332C2B"
                    customTextColor: "#ffffff"

                    HoverHandler {
                        id: cursorHovered2
                        acceptedDevices: PointerDevice.Mouse
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                //select button
                MyText2{
                    id: selectButton

                    x: workspace1.width-width
                    y: 0

                    width: 90
                    height: 28

                    customRadius: 5
                    customText: "Select All"
                    customHAlignment: "Center"
                    customSize: 15
                    customColor: "#000000"
                    customHoveredColor: "#332C2B"
                    customTextColor: "#ffffff"

                    HoverHandler {
                        id: cursorHovered3
                        acceptedDevices: PointerDevice.Mouse
                        cursorShape: Qt.PointingHandCursor
                    }

                    onClicked: {
                        window.manager.selectAll()
                        for(var i=0; i<visualModel.model.rowCount(); i++){
                            listItem.checklistIcon.visible = true
                        }
                    }
                }

                //deselect button
                MyText2{
                    id: deselectButton

                    x: workspace1.width-(width+selectButton.width+5)
                    y: 0

                    width: 110
                    height: 28

                    customRadius: 5
                    customText: "Deselect All"
                    customHAlignment: "Center"
                    customSize: 15
                    customColor: "#000000"
                    customHoveredColor: "#332C2B"
                    customTextColor: "#ffffff"

                    HoverHandler {
                        id: cursorHovered4
                        acceptedDevices: PointerDevice.Mouse
                        cursorShape: Qt.PointingHandCursor
                        enabled: parent.customColor === "#000000" ? true : false
                    }

                    onClicked: {
                        window.manager.deselectAll()
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
        }
//     }
// }
