import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"

ShadowRect{
    id: header
    Layout.fillWidth: true
    Layout.maximumHeight: 50
    readonly property alias index: headerList.currentIndex
    color: Material.background
    //header button
    RowLayout{
        anchors.fill: parent
        MyButton{
            id: menuBtn
            display: AbstractButton.IconOnly
            icon.source: "qrc:/images/menu-icon2"
            text: "Menu"
            onClicked: {
                sidebar.folded = !sidebar.folded
            }
        }
        Text{
            text: "Sense Tool"
            font.family: "Richard Clean Personal Use"
            font.pixelSize: 35
            color: "#F08519"
        }
        Item{
            Layout.fillWidth: true
        }
        HeaderList{
            id: headerList
        }
    }
}