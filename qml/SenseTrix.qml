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
    id: root
    Material.theme: settings.isDarkTheme ? Material.Dark : Material.Light
    Settings{
        id: settings
        property alias isDarkTheme: popUp.isDarkTheme
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