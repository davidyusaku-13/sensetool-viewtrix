import QtQuick
import PrjSetModel
import HistoryModel

QtObject {
    id: manager

    required property PrjSetModel prjSetModel
    required property HistoryModel historyModel
    
    function add(name, value, desc, state){
        prjSetModel.addItem(name, value, desc, state)
    }
    
    function edit(index, name, value, desc){
        prjSetModel.edit(index, name, value, desc)
    }
    
    function moveItem(source, dest){prjSetModel.move(source, dest)
    }
    
    function editState(index, state){
        prjSetModel.editState(index, state)
    }
    
    function addHistory(action, name, value, desc){
        historyModel.addHistory(action, name, value, desc)
    }
    
    function deselectAll(){
        prjSetModel.deselectAll()
    }
    
    function selectAll(){
        prjSetModel.selectAll()
    }
    
    function exportYAML(file){
        prjSetModel.exportYAML(file)
    }
    
    function importYAML(file){
        prjSetModel.importYAML(file)
    }
}
