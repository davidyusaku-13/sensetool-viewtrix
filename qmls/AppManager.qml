import QtQuick
import PrjSetModel
import AppLogic

QtObject {
    id: manager

    required property PrjSetModel prjSetModel
    required property var logic

    function add(item, val, desc, state){
      prjSetModel.addItem(item, val, desc, state)
    }

    function editState(index, val){
      prjSetModel.editState(index, val)
    }

    function deselectAll(){
      prjSetModel.deselectAll()
    }

    function selectAll(){
      prjSetModel.selectAll()
    }
}
