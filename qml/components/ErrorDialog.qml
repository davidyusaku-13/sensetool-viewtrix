import QtQuick
import QtQuick.Dialogs

// Shows a message from a slot that returns "" on success: if(!errors.show(model.importFile(url))) ...
MessageDialog {
    buttons: MessageDialog.Ok
    // Returns true when there was something to show (i.e. the action failed).
    function show(message){
        if(!message) return false
        text = message
        open()
        return true
    }
}
