import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

ShadowRect{
    id: sidebar
    implicitWidth: 50
    Layout.fillHeight: true
    color: "#ffffff"
    transitions: [
        Transition {
            NumberAnimation {
                properties: "width,opacity"
                duration: 200
            }
        }
    ]
    readonly property alias index: sidebarList.currentIndex
    property bool folded: false
    state: !folded ? "Visible" : "Invisible"
    states: [
        State{
            name: "Visible"
            PropertyChanges{target: sidebar; width: 50; visible: true}
        },
        State{
            name:"Invisible"
            PropertyChanges{target: sidebar; width: 0.0; visible: false}
        }
    ]
    ListView{
        id: sidebarList
        anchors.fill: parent
        anchors.margins: 7
        spacing: 5
        model: sideModel
        delegate: MyButton{
            required property var model
            required property int index
            icon.source: model.icon
            text: model.name
            highlighted: ListView.isCurrentItem
            onClicked: {
                ListView.view.currentIndex = index
            }
        }
    }
    ListModel{
        id: sideModel
        ListElement{
            name: "Project Set"
            icon: "images/import"
        }
        ListElement{
            name: "Scan Arrangement"
            icon: "images/plus"
        }
    }
}
