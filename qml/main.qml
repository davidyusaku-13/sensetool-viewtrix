import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import PrjSetModel
import HistoryModel
import AppLogic
import QtCore

ApplicationWindow {
    id: window
    
    property PrjSetModel prjSetModel: PrjSetModel {}
    property HistoryModel historyModel: HistoryModel{}
    property AppLogic logic: AppLogic{
        parent: window
    }

    title: qsTr("SenseTool-v" + logic.getVersion())
    visible: true
    width: 1280
    height: 720
    
    SenseTrix{
        anchors.fill: parent
        UpdateWindow{
            id: update_window
        }
        Component.onCompleted: {
            if(logic.checkUpdate()["status"]){
                update_window.show()
            }
        }
    }
    
    Settings{
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }

    Connections {
        target: updateManager
        function onProgressChanged() {
            update_window.progressBar.visible = true
            update_window.progressBar.value = updateManager.getProgress()
            update_window.progressText.visible = true
            update_window.progressText.text = updateManager.getProgress() + qsTr("% completed")
            if (updateManager.getProgress() === 100) {
                update_window.restartDialog.open()
            }
        }
    }
}