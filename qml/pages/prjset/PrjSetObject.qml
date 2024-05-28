import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject{
    id: root
    property string name
    property string value
    property string desc
    
    function reset(){
        set(null)
    }

    function set(object){
        name = object?.name ?? ""
        value = object?.value ?? ""
        desc = object?.desc ?? ""
    }

    function get(){
        let obj = {
            "name": name,
            "value": value,
            "desc": desc
        }
        return obj
    }
}