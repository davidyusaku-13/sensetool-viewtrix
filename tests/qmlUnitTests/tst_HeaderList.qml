import QtQuick
import QtTest
import "../../qml/layouts"

Item {
    width: 800
    height: 600

    HeaderList {
        id: headerList
        anchors.fill: parent
        anchors.centerIn: parent
    }

    TestCase {
        name: "HeaderListTestCase"
        when: windowShown

        function test_checkHeader() {
            const firstButton = headerList.itemAtIndex(0)
            const secondButton = headerList.itemAtIndex(1)
            const indexBeforeClick = headerList.currentIndex
            mouseClick(secondButton)
            const indexAfterClick = headerList.currentIndex
            verify(indexBeforeClick < indexAfterClick,
                   "Failed to change popup page by clicking the header button")
        }
    }
}
