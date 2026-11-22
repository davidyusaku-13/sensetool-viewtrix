import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject{
    id: object
    property string name
    property string desc
    property var scans: []

    function set(object){
        // The scan list itself is edited in the Scan List column, not here.
        scans = []
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
