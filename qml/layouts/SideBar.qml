import QtQuick 2.15
import QtQuick.Layouts
import "../components"

// Workspace switcher. Folded: icons only (with tooltips). Unfolded: icons and names.
ShadowRect{
    id: sidebar
    Layout.preferredWidth: folded ? 60 : 240
    Layout.fillHeight: true
    Behavior on Layout.preferredWidth { NumberAnimation { duration: 150 } }
    readonly property alias index: sidebarList.currentIndex
    property bool folded: true
    SideBarList{
        id: sidebarList
        folded: sidebar.folded
    }
}
