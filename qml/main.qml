import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import PrjSetModel
import HistoryModel
import AppLogic
import QtCore

ApplicationWindow {
    id: window
    
    property AppManager manager: AppManager{
        prjSetModel: PrjSetModel {}
        historyModel: HistoryModel{}
        logic: AppLogic{}
    }

    title: manager.logic.getVersion()
    visible: true
    width: 1280
    height: 720
    
    SenseTrix{
        anchors.fill: parent
    }
    
    Settings{
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }
}