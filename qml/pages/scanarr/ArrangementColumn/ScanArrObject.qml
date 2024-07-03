import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject{
    id: object
    property string name
    property string desc
    property var scans

    function set(object){
        scans = ["On", "Off"]
        name = object?.name ?? ""
        desc = object?.desc ?? ""
    }

    function get(){
        let obj = {
            "name": name,
            "desc": desc,
            "scans": scans
        }
        return obj
    }

    function reset(){
        set(null)
    }
}
