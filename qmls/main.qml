import QtQuick
import QtQuick.Controls
import PrjSetModel
import AppLogic

ApplicationWindow {
  id: window
  title: qsTr("Viewtrix")

  property int w: 1280
  property int h: 400

  AppManager{
    id: manager
    prjSetModel: PrjSetModel { }
  }

  visible: true
  width: window.w
  height: window.h

  SenseTrix {
    anchors.fill: parent
  }
}