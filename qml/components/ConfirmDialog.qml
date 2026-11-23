import QtQuick
import QtQuick.Dialogs

// Asks before a destructive action: confirm.ask(qsTr("Delete 3 items?"), () => {...})
MessageDialog {
    id: root
    property var onYes: null
    buttons: MessageDialog.Yes | MessageDialog.No
    function ask(message, callback){
        text = message
        informativeText = qsTr("You can undo this with Ctrl+Z.")
        onYes = callback
        open()
    }
    onButtonClicked: (button, role) => {
        if(button === MessageDialog.Yes && root.onYes) root.onYes()
        root.onYes = null
    }
}
