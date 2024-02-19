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

    SenseTrix{
        anchors.fill: parent
    }

    // Rectangle{
    //     id: rect
    //     anchors.fill: parent
    //     color: "#fff"
        
    //     ListView{
    //         anchors.fill: parent
    //         model: root.manager.prjSetModel
    //         delegate: Text{
    //             height: 20
    //             verticalAlignment: Text.AlignVCenter
    //             text: setitem + " " + val + " " +  desc
    //         }
    //     }

    //     Button {
    //         width: 100
    //         height: width/3
    //         text: "Add Item"
    //         onClicked: {
    //             root.manager.add("OS_EVENT_QUE", "8", "Queue deep value")
    //         }
    //     }
    // }
}
