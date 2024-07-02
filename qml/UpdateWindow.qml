import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "components"

Window {
    width: 400
    height: 300
    title: "New update available"
    property alias progressBar: progressBar
    property alias progressText: progressText
    property alias restartDialog: restartDialog
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
            Frame{
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Text {
                    text: qsTr("We have added new features and fix some bugs to make your experience seamless")
                    anchors.fill: parent
                    font.family: "Montserrat SemiBold"
                    font.pixelSize: 15
                    color: Material.foreground
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }
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
                id: progressText
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Material.foreground
                visible: false
            }
            Button{
                Layout.fillWidth: true
                text: qsTr("Download")
                font.family: "Montserrat"
                onClicked: {
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