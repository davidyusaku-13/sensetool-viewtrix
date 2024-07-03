import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject{
    id: object
    property string name
    property string desc

    function set(object){
        name = object?.name ?? ""
        desc = object?.desc ?? ""
    }

    function get(){
        let obj = {
            "name": name,
            "desc": desc
        }
        return obj
    }

    function reset(){
        set(null)
    }
}
