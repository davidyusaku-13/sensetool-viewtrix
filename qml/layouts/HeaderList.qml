import QtQuick
import QtQuick.Layouts
import "../components"

ListView {
    id: headerList
    // As tall as its buttons and centred in the header, like the other header buttons.
    Layout.preferredHeight: 45
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: childrenRect.width
    spacing: 4
    interactive: false
    orientation: ListView.Horizontal
    model: [{
            "name": qsTr("Activity"),
            "icon": "qrc:/images/notification"
        }, {
            "name": qsTr("Settings"),
            "icon": "qrc:/images/setting"
        }]
    delegate: MyButton {
        required property var model
        required property int index
        icon.source: model.icon
        text: model.name
        isHeaderBtn: true
        highlighted: ListView.isCurrentItem
        onClicked: {
            ListView.view.currentIndex = ListView.isCurrentItem ? -1 : index
        }
    }
    Component.onCompleted: currentIndex = -1
}
