import QtQuick
import QtTest
import "../../qml/layouts"

Item {
    width: 800
    height: 600

    SideBarList {
        id: sideBarList
        anchors.fill: parent
        anchors.centerIn: parent
    }

    TestCase {
        name: "SidebarListTestCase"
        when: windowShown

        function test_checkSidebar() {
            const firstButton = sideBarList.itemAtIndex(0)
            const secondButton = sideBarList.itemAtIndex(1)
            const thirdButton = sideBarList.itemAtIndex(2)
            const indexBeforeClick = sideBarList.currentIndex
            mouseClick(secondButton)
            const indexAfterClick = sideBarList.currentIndex
            verify(indexBeforeClick < indexAfterClick,
                   "Failed to change workspace by clicking on the sidebar button")
        }
    }
}
