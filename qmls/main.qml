import QtQuick
import QtQuick.Controls
import PrjSetModel
import AppLogic

ApplicationWindow {
    id: root
    title: qsTr("Viewtrix")

    property int w: 1280
    property int h: 720
    property AppManager manager: AppManager{
        prjSetModel: PrjSetModel{}
        logic: AppLogic{}
    }

    visible: true
    width: root.w
    height: root.h

    // SenseTrix{
    //     anchors.fill: parent
    // }


    Rectangle{
        id: rect
        anchors.fill: parent
        color: "#fff"
        
        Coba{
            anchors.fill: parent
        }
        
        // ListView{
        //     anchors.fill: parent
        //     anchors.top: parent.bottom
        //     anchors.topMargin: btnAdd.height + 20

        //     model: root.manager.prjSetModel
        //     delegate: Text{
        //         height: 20
        //         verticalAlignment: Text.AlignVCenter
        //         text: setitem + " " + val + " " +  desc
        //     }
        // }

        // Button{
        //     id: btnAdd
        //     text: "Add"
        //     anchors.top: parent.top
        //     anchors.topMargin: 10
        //     anchors.left: parent.left
        //     anchors.leftMargin: 10

        //     onClicked: {
        //         root.manager.add("OS_EVENT_QUE", "8", "Queue deep value")
        //     }
        // }
    }
}