import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"

ShadowRect{
    id: sidebar
    Layout.preferredWidth: 50
    Layout.fillHeight: true
    transitions: [
        Transition {
            NumberAnimation {
                properties: "x,visible"
                duration: 200
            }
        }
    ]
    readonly property alias index: sidebarList.currentIndex
    property bool folded: false
    state: folded ? "Invisible" : "Visible"
    states: [
        State{
            name: "Visible"
            PropertyChanges{
                target: sidebar
                x: 0
                visible: true
            }
        },
        State{
            name:"Invisible"
            PropertyChanges{
                target: sidebar
                x: -sidebar.width
                visible: false
            }
        }
    ]
    SideBarList{
        id: sidebarList
    }
}
