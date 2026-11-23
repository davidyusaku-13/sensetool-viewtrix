pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../components"

Item{
    id: popUp
    // dependencies
    property var history: null    // HistoryModel
    property var updates: null    // UpdateChecker
    property var translator: null // Translator
    signal updateAvailable()
    property alias currentIndex: popUpLayout.currentIndex
    property alias isDarkTheme: themeToggle.checked
    property alias languageIndex: langChoice.currentIndex
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
                    model: popUp.history
                    //header
                    headerPositioning: ListView.OverlayHeader
                    header: Rectangle{
                        width: parent.width
                        height: 50
                        color: Material.accent
                        z: 2
                        Text{
                            text: qsTr("Activity")
                            color: Theme.onAccent
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
                    Text{
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No activity yet.\nImports, saves, edits and generated files show up here.")
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width * 0.85
                        wrapMode: Text.Wrap
                        color: Material.foreground
                        opacity: 0.6
                        font.pixelSize: 14
                        font.family: "Montserrat Medium"
                    }
                }
                ToolbarBtn{
                    text: qsTr("Clear History")
                    Layout.margins: 10
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    onClicked: {
                        popUp.history.clear()
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
                        text: qsTr("Settings")
                        font.pixelSize: 20
                        font.family: "Montserrat SemiBold"
                        color: Theme.onAccent
                        anchors.centerIn: parent
                    }
                }
                RowLayout{
                    Layout.fillWidth: true
                    implicitHeight: 50
                    Layout.margins: 10
                    Text{
                        text: qsTr("Dark mode")
                        font.family: "Montserrat"
                        font.pixelSize: 15
                        Layout.fillWidth: true
                        color: Material.foreground
                    }
                    // On = dark. No state label: the switch itself is the state.
                    Switch{
                        id: themeToggle
                    }
                }
                RowLayout{
                    Layout.fillWidth: true
                    implicitHeight: 50
                    Layout.margins: 10
                    Text{
                        text: qsTr("Language")
                        font.family: "Montserrat"
                        font.pixelSize: 15
                        Layout.fillWidth: true
                        color: Material.foreground
                    }
                    ComboBox{
                        id: langChoice
                        model: ["English", "Bahasa Indonesia"]
                        implicitWidth: 190
                        onActivated: (i) => popUp.translator.change_language(i === 1 ? "id" : "en")
                    }
                }
                Button{
                    Layout.fillWidth: true
                    Layout.margins: 10
                    text: qsTr("Check for updates")
                    font.family: "Montserrat"
                    HoverHandler{
                        cursorShape: Qt.PointingHandCursor
                    }
                    onClicked: {
                        if(popUp.updates.checkNow()["status"]){
                            popUp.updateAvailable()
                        }
                    }
                }
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}