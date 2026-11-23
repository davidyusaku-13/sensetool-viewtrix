import QtQuick
import QtCore
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import "components"
import "layouts"
import "pages/prjset"
import "pages/appset"
import "pages/scanarr"
import "pages/hwutil"

// The main window's content: header, workspace sidebar, the workspace pages and
// the activity/settings panel. Everything it needs is passed in.
Rectangle{
    id: root
    required property var prjSetModel
    required property var appSetModel
    required property var scanArrModel
    required property var historyModel
    required property var project
    required property var updates
    required property var coefficients
    required property var translator
    signal openRequested()
    signal saveRequested()
    signal updateAvailable()
    property alias currentPage: pages.currentIndex

    Material.theme: Theme.theme
    Material.accent: Theme.accent
    color: Material.background
    Binding { target: Theme; property: "dark"; value: popUp.isDarkTheme }

    Settings{
        id: settings
        property alias isDarkTheme: popUp.isDarkTheme
        property alias sidebarFolded: sidebar.folded
        property alias languageIndex: popUp.languageIndex
    }
    // Apply the saved language once Settings has restored it.
    Component.onCompleted: Qt.callLater(() => { if(popUp.languageIndex === 1) root.translator.change_language("id") })

    ColumnLayout{
        anchors.fill: parent
        spacing: 1
        Header{
            id: header
            project: root.project
            folded: sidebar.folded
            onToggleSidebar: sidebar.folded = !sidebar.folded
            onOpenRequested: root.openRequested()
            onSaveRequested: root.saveRequested()
        }
        RowLayout{
            Layout.fillHeight: true
            spacing: 0
            SideBar{
                id: sidebar
            }
            SplitView{
                Layout.fillHeight: true
                Layout.fillWidth: true
                StackLayout{
                    id: pages
                    SplitView.fillHeight: true
                    SplitView.fillWidth: true
                    SplitView.minimumWidth: 600
                    currentIndex: sidebar.index
                    // clicking empty workspace space hides the sidebar labels
                    TapHandler{ onTapped: sidebar.folded = true }
                    PrjSetPage{ model: root.prjSetModel; history: root.historyModel }
                    AppSetPage{ model: root.appSetModel; history: root.historyModel }
                    ScanArrPage{ scanArr: root.scanArrModel; history: root.historyModel }
                    HwUtilPage{ coefficients: root.coefficients; history: root.historyModel }
                }
                PopUpMenu{
                    id: popUp
                    history: root.historyModel
                    updates: root.updates
                    translator: root.translator
                    onUpdateAvailable: root.updateAvailable()
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
