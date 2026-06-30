import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../components"

Item{
    property alias currentIndex: popUpLayout.currentIndex
    property alias isDarkTheme: themeToggle.checked
    property string language: "en"
    onLanguageChanged: {
        translator.change_language(language)
    }
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
                    model: window.historyModel
                    //header
                    headerPositioning: ListView.OverlayHeader
                    header: Rectangle{
                        width: parent.width
                        height: 50
                        color: Material.accent
                        z: 2
                        Text{
                            text: "Notification"
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
                    text: qsTr("Clear History")
                    Layout.margins: 10
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    onClicked: {
                        window.historyModel.clear()
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
                        text: qsTr("App Settings")
                        font.pixelSize: 20
                        font.family: "Montserrat SemiBold"
                        color: Material.foreground
                        anchors.centerIn: parent
                    }
                }
                RowLayout{
                    Layout.fillWidth: true
                    implicitHeight: 50
                    Layout.margins: 10
                    Text{
                        text: qsTr("Theme")
                        font.family: "Montserrat"
                        font.pixelSize: 15
                        Layout.fillWidth: true
                        color: Material.foreground
                    }
                    Switch{
                        id: themeToggle
                        display: AbstractButton.TextBesideIcon
                        text: qsTr("Dark Mode")
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
                        id: langCombo
                        Layout.fillWidth: true
                        model: [qsTr("English"), qsTr("Indonesia")]
                        currentIndex: language === "id" ? 1 : 0
                        onActivated: {
                            language = currentIndex === 1 ? "id" : "en"
                        }
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
                        if(logic.checkUpdate()["status"]){
                            update_window.show()
                        }
                    }
                }
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: 10
                    text: "v" + logic.getVersion()
                    color: Material.foreground
                    opacity: 0.5
                    font.pixelSize: 12
                    font.family: "Montserrat"
                }
            }
        }
    }
}