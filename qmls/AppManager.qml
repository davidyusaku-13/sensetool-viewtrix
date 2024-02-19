import QtQuick
import PrjSetModel
import AppLogic

QtObject {
    id: manager

    required property PrjSetModel prjSetModel
    required property var logic

    function add(item, val, desc){
      prjSetModel.addItem(item, val, desc)
    }
}
