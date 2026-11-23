import QtQuick 2.15
import QtQuick.Controls 2.15
import "../components"

ListView {
    id: sidebarList
    property bool folded: true
    anchors.fill: parent
    anchors.margins: 7
    spacing: 5
    clip: true
    model: sideModel
    delegate: MyButton {
        required property var model
        required property int index
        width: sidebarList.folded ? 45 : sidebarList.width
        radius: sidebarList.folded ? width / 2 : 10
        display: sidebarList.folded ? AbstractButton.IconOnly : AbstractButton.TextBesideIcon
        showToolTip: sidebarList.folded
        icon.source: model.icon
        text: model.name
        font.family: "Montserrat Medium"
        font.pixelSize: 14
        highlighted: ListView.isCurrentItem
        onClicked: {
            ListView.view.currentIndex = index
        }
    }
    ListModel {
        id: sideModel
        ListElement {
            name: "Project Setting"
            icon: "qrc:/images/tune"
        }
        ListElement {
            name: "App Setting"
            icon: "qrc:/images/chip"
        }
        ListElement {
            name: "Scan Arrangement"
            icon: "qrc:/images/scanarr"
        }
        ListElement {
            name: "Hardware Utilities"
            icon: "qrc:/images/graph"
        }
    }
}
