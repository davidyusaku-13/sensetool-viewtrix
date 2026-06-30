import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "components"

Window {
    width: 400
    height: 420
    title: qsTr("New update available")
    property alias progressBar: progressBar
    property alias progressText: progressText
    property alias restartDialog: restartDialog
    property string releaseNotes: ""
    onVisibleChanged: {
        if (visible && !releaseNotes) {
            releaseNotes = window.logic.checkUpdate()["changelog"]
        }
    }
    ShadowRect{
        anchors.fill: parent
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 50
            Text {
                text: qsTr("App Update Required!")
                font.family: "Richard Clean Personal Use"
                font.pixelSize: 30
                color: "#F08519"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                Text {
                    text: releaseNotes || qsTr("We have added new features and fixed some bugs to make your experience seamless")
                    textFormat: Text.MarkdownText
                    wrapMode: Text.WordWrap
                    width: parent.width
                    font.family: "Montserrat"
                    font.pixelSize: 13
                    color: Material.foreground
                    topPadding: 8
                    bottomPadding: 8
                }
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
            }
            ProgressBar{
                id: progressBar
                Layout.preferredHeight: 10
                Layout.fillWidth: true
                from: 0
                to: 100
                value: 0
                visible: false
            }
            Text{
                id: preparingText
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Material.foreground
                text: qsTr("Preparing download...")
                visible: false
            }
            Text{
                id: progressText
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Material.foreground
                visible: false
            }
            BaseButton{
                Layout.fillWidth: true
                text: qsTr("Download")
                font.family: "Montserrat"
                onClicked: {
                    preparingText.visible = true
                    progressBar.visible = true
                    progressBar.value = 0
                    updateManager.download_update(window.logic.checkUpdate()["link"])
                }
            }
        }
        MessageDialog {
            id: restartDialog
            title: qsTr("Download Complete")
            text: qsTr("The download is complete. Would you like to restart the application now?")
            buttons: MessageDialog.Yes | MessageDialog.No
            onAccepted: {
                updateManager.restartApplication()
            }
        }
    }
}
