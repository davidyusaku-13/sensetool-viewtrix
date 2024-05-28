import QtQuick
import PrjSetModel
import HistoryModel
import AppLogic

QtObject {
    id: manager
    
    required property PrjSetModel prjSetModel
    required property HistoryModel historyModel
    required property AppLogic logic
    
    function add(name, value, desc){
        prjSetModel.addItem(name, value, desc)
    }
    
    function edit(index, name, value, desc){
        prjSetModel.edit(index, name, value, desc)
    }
    
    function moveItem(source, dest){
        prjSetModel.move(source, dest)
    }
    
    function addHistory(action, name, value, desc){
        historyModel.addHistory(action, name, value, desc)
    }
    
    function exportYAML(file){
        prjSetModel.exportYAML(file)
    }
    
    function importYAML(file){
        prjSetModel.importYAML(file)
    }
    
    function clearHistory(){
        historyModel.clear()
    }
}