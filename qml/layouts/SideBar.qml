import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"

ShadowRect{
    id: sidebar
    implicitWidth: 50
    Layout.fillHeight: true
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
    SideBarList{
        id: sidebarList
    }
}
