import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import PrjSetModel
import HistoryModel
import AppLogic

ApplicationWindow {
    id: window
    
    title: qsTr("Sense Trix")
    visible: true
    width: 1280
    height: 720
    
    property AppManager manager: AppManager{
        prjSetModel: PrjSetModel { }
        historyModel: HistoryModel{ }
    }
    
    SenseTrix{
        anchors.fill: parent
    }
}