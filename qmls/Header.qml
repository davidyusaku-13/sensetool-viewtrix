import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

ShadowRect{
    id: header
    Layout.fillWidth: true
    implicitHeight: 50
    readonly property alias index: headerList.currentIndex
    //header button
    RowLayout{
        anchors.fill: parent
        anchors.margins: 5
        MyButton{
            id: menuBtn
            icon.source: "images/menu-icon2.png"
            text: "Menu"
            onClicked: {
                sidebar.folded = !sidebar.folded
            }
        }
        Item{
            Layout.fillWidth: true
        }
        ListView{
            id: headerList
            Layout.fillHeight: true
            Layout.preferredWidth: childrenRect.width
            orientation: ListView.Horizontal
            spacing: 5
            model: [
                {
                    "name": "Notification",
                    "icon": "images/notification"
                },
                {
                    "name": "Setting",
                    "icon": "images/setting"
                }
            ]
            delegate: MyButton{
                required property var model
                required property int index
                icon.source: model.icon
                text: model.name
                highlighted: ListView.isCurrentItem
                onClicked: {
                    ListView.view.currentIndex = ListView.isCurrentItem ? -1 : index
                }
            }
        }
    }
}
