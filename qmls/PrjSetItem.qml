import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject{
    id: object
    property string name
    property string value
    property string desc
    
    function reset(){
        name = ""
        value = ""
        desc = ""
    }
}