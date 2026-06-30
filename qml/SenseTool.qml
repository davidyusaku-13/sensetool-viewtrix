import QtQuick
import QtCore
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import "components"
import "layouts"
import "pages/prjset"
import "pages/scanarr"
import "pages/hwutil"

Rectangle{
    property int theme: settings.isDarkTheme ? Material.Dark : Material.Light
    Material.theme: theme
    Settings{
        id: settings
        property alias isDarkTheme: popUp.isDarkTheme
        property alias language: popUp.language
    }
    ListModel{
        id: historyList
    }
    ListModel {
        id: mainSidebarModel
        ListElement {
            name: "Project Set"
            icon: "qrc:/images/import"
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
                model: mainSidebarModel
            }
            //workspace and pop-up
            SplitView{
                Layout.fillHeight: true
                Layout.fillWidth: true
                //content
                StackLayout{
                    SplitView.fillHeight: true
                    SplitView.fillWidth: true
                    currentIndex: sidebar.index
                    PrjSetPage{}
                    ScanArrPage{}
                    HwUtilPage{}
                }
                //pop-up
                PopUpMenu{
                    id: popUp
                    SplitView.fillHeight: true
                    SplitView.preferredWidth: 350
                    SplitView.maximumWidth: 500
                    SplitView.minimumWidth: 200
                    visible: header.index !== -1
                    currentIndex: header.index
                }
            }
        }
    }
}