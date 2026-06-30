import QtQuick 2.15
import "../components"

ListView {
    id: sidebarList
    anchors.fill: parent
    anchors.margins: 7
    spacing: 5
    delegate: IconButton {
        required property var model
        required property int index
        anchors.horizontalCenter: parent.horizontalCenter
        icon.source: model.icon
        text: model.name
        highlighted: ListView.isCurrentItem
        onClicked: {
            ListView.view.currentIndex = index
        }
    }

}
