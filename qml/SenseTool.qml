import QtQuick
import QtCore
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import "components"
import "layouts"
import "pages/prjset"
import "pages/appset"
import "pages/scanarr"
import "pages/hwutil"

Rectangle{
    id: root
    property int theme: settings.isDarkTheme ? Material.Dark : Material.Light
    // One brand colour (Viewtrix orange), tuned per theme for contrast:
    // white text on the darker orange (light theme), dark text on the lighter one (dark theme).
    readonly property color accent: theme === Material.Dark ? "#F5A04D" : "#C45500"
    readonly property color onAccent: theme === Material.Dark ? "#1C1B1F" : "#FFFFFF"
    property alias scanArrPage: scanArrPage
    property alias currentPage: pages.currentIndex
    Material.theme: theme
    Material.accent: accent
    Settings{
        id: settings
        property alias isDarkTheme: popUp.isDarkTheme
        property alias sidebarFolded: sidebar.folded
    }
    ListModel{
        id: historyList
    }
    ColumnLayout{
        anchors.fill: parent
        spacing: 1
        //header rect
        Header{
            id: header
        }
        //sidebar + workspace
        RowLayout{
            Layout.fillHeight: true
            spacing: 0
            //sidebar
            SideBar{
                id: sidebar
            }
            //workspace and pop-up
            SplitView{
                Layout.fillHeight: true
                Layout.fillWidth: true
                //content
                StackLayout{
                    id: pages
                    SplitView.fillHeight: true
                    SplitView.fillWidth: true
                    SplitView.minimumWidth: 600
                    currentIndex: sidebar.index
                    PrjSetPage{}
                    AppSetPage{}
                    ScanArrPage{ id: scanArrPage }
                    HwUtilPage{}
                }
                //pop-up
                PopUpMenu{
                    id: popUp
                    SplitView.fillHeight: true
                    SplitView.preferredWidth: 320
                    SplitView.maximumWidth: 500
                    SplitView.minimumWidth: 240
                    visible: header.index !== -1
                    currentIndex: header.index
                }
            }
        }
    }
}
