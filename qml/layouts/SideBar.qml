import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"

ShadowRect{
    id: sidebar
    Layout.preferredWidth: folded ? 0 : 50
    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: 200 }
    }
    Layout.fillHeight: true
    clip: true
    
    readonly property alias index: sidebarList.currentIndex
    property alias model: sidebarList.model
    property bool folded: false

    SideBarList{
        id: sidebarList
    }
}
