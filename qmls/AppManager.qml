import QtQuick
import PrjSetModel
import AppLogic

QtObject {
  id: manager

  required property PrjSetModel prjSetModel

  function add(name, value, desc, state)
  {
    prjSetModel.addItem(name, value, desc, state)
  }

  function editState(index, state)
  {
    prjSetModel.editState(index, state)
  }

  function deselectAll()
  {
    prjSetModel.deselectAll()
  }

  function selectAll()
  {
    prjSetModel.selectAll()
  }
}
