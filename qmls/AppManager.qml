import QtQuick
import PrjSetModel
import AppLogic

QtObject {
    id: manager

    required property PrjSetModel prjSetModel
    required property var logic

    function add(setitem, val, desc){
      prjSetModel.addItem(setitem, val, desc)
    }
}
