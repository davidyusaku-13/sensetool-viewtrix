import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../components"

Item{
    property alias currentIndex: popUpLayout.currentIndex
    property alias isDarkTheme: themeToggle.checked
    ShadowRect{
        anchors.fill: parent
        color: Material.background
        StackLayout{
            id: popUpLayout
            anchors.fill: parent
            anchors.margins: 20
            visible: currentIndex !== -1
            //notif pop-up
            ColumnLayout{
                Layout.fillHeight: true
                Layout.fillWidth: true
                ListView{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    // model: historyList
                    model: window.manager.historyModel
                    //header
                    headerPositioning: ListView.OverlayHeader
                    header: Rectangle{
                        width: parent.width
                        height: 50
                        color: Material.accent
                        Text{
                            text: qsTr("Notification")
                            color: Material.foreground
                            font.pixelSize: 20
                            font.family: "Montserrat SemiBold"
                            anchors.centerIn: parent
                        }
                    }
                    delegate: Text{
                        required property var model
                        width: ListView.view.width
                        // text: model.status+"(name: "+model.name+", value: "+model.value+", desc: "+model.desc+")"
                        text: model.history + "\n\n"
                        color: Material.foreground
                        font.pixelSize: 15
                        font.family: "Montserrat Medium"
                        padding: 10
                        wrapMode: Text.WordWrap
                    }
                }
                ToolbarBtn{
                    text: "Clear History"
                    Layout.margins: 10
                    onClicked: {
                        // historyList.clear()
                        window.manager.clearHistory()
                    }
                }
            }
            //setting pop-up
            ColumnLayout{
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: Material.accent
                    Text{
                        text: "Setting"
                        font.pixelSize: 20
                        font.family: "Montserrat SemiBold"
                        color: Material.foreground
                        anchors.centerIn: parent
                    }
                }
                Switch{
                    id: themeToggle
                    display: AbstractButton.TextBesideIcon
                    text: "Theme"
                }
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}