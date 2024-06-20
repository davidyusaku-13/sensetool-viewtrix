import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject{
    id: object
    property var names: []

    function set(pNames){
        names = pNames
    }

    function get(index){
        let obj = {
            "name": names[index],
        }
        return obj
    }

    function reset(){
        names = []
    }
}
