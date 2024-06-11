import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
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
}