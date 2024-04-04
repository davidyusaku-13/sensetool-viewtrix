import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

Rectangle{
    id: root
    width: 1920
    height: 1080
    //title: "Sense Trix"
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
                    id: layout
                    function history(status, object){
                        var temp = {
                            "status": status,
                            "name": object["name"],
                            "value": object["value"],
                            "desc": object["desc"]
                        }
                        historyList.append(temp)
                    }
                    SplitView.fillHeight: true
                    SplitView.fillWidth: true
                    currentIndex: sidebar.index
                    //project set workspace
                    PrjSetPage{
                    }
                    ScanArrPage{}
                }
                //pop-up
                PopUpPage{
                    currentIndex: header.index
                }
            }
        }
    }   
}