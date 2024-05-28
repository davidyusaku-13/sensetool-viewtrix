import QtQuick
import QtQuick.Layouts
import "../components"

ListView {
    id: headerList
    Layout.fillHeight: true
    Layout.preferredWidth: childrenRect.width
    orientation: ListView.Horizontal
    model: [{
            "name": "Notification",
            "icon": "qrc:/images/notification"
        }, {
            "name": "Setting",
            "icon": "qrc:/images/setting"
        }]
    delegate: MyButton {
        required property var model
        required property int index
        anchors.verticalCenter: parent.verticalCenter
        icon.source: model.icon
        text: model.name
        isHeaderBtn: true
        highlighted: ListView.isCurrentItem
        onClicked: {
            ListView.view.currentIndex = ListView.isCurrentItem ? -1 : index
        }
    }
}
