import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import PrjSetModel
import HistoryModel
import AppLogic

ApplicationWindow {
    id: window
    title: "SenseTool v" + manager.logic.get_version()
    visible: true
    width: 1280
    height: 720
    property AppManager manager: AppManager{
        prjSetModel: PrjSetModel {}
        historyModel: HistoryModel{}
        logic: AppLogic{}
    }
    SenseTrix{
        anchors.fill: parent
    }
    Settings{
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }
    Window{
        id: updateWindow
        width: 500
        height: 300
        title: "Update Available!"
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 7
            Text{
                id: tag_name
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Text{
                id: changelog
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.Wrap
            }
            RoundButton{
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                text: qsTr("Download")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/davidyusaku-13/sensetool-viewtrix/releases/")
                }
            }
        }
    }
    Component.onCompleted:{
        if(manager.logic.check_update()["status"]){
            updateWindow.show()
            tag_name.text = "New version available! v" + manager.logic.check_update()["tag_name"]
            changelog.text = manager.logic.check_update()["changelog"]
        }
    }
}