import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

StackLayout{
    SplitView.fillHeight: true
    SplitView.preferredWidth: 350
    SplitView.maximumWidth: 500
    SplitView.minimumWidth: 150
    visible: currentIndex !== -1
    //notif pop-up
    ShadowRect{
        id: notif
        color: "#ffffff"
        ColumnLayout{
            anchors.fill: parent
            ListView{
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                model: historyList
                // model: window.manager.historyModel
                //header
                headerPositioning: ListView.OverlayHeader
                header: Rectangle{
                    width: parent.width
                    height: 50
                    color: "#d6d6d6"
                    Text{
                        text: "Notification"
                        font.pixelSize: 20
                        font.family: "Montserrat SemiBold"
                        anchors.centerIn: parent
                    }
                }
                delegate: Text{
                    required property var model
                    width: ListView.view.width
                    // text: model.status+"(name: "+model.name+", value: "+model.value+", desc: "+model.desc+")"
                    text: model.history + "\n\n"
                    font.pixelSize: 15
                    font.family: "Montserrat Medium"
                    wrapMode: Text.WordWrap
                }
            }
            ToolbarBtn{
                text: "Clear History"
                Layout.margins: 10
                onClicked: {
                    // historyList.clear()
                    window.manager.clearHistory()
                }
            }
        }
    }
    //setting pop-up
    ShadowRect{
        id: setting
        color: "#ffffff"
        ListView{
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            model: historyList
            //header
            header: Rectangle{
                width: parent.width
                height: 50
                color: "#d6d6d6"
                Text{
                    text: "Setting"
                    font.pixelSize: 20
                    font.family: "Montserrat SemiBold"
                    anchors.centerIn: parent
                }
            }
            delegate: Text{
                required property var model
                width: parent.width
                text: model.status+"(name: "+model.name+", value: "+model.value+", desc: "+model.desc+")"
                font.pixelSize: 15
                font.family: "Montserrat Medium"
                wrapMode: Text.WordWrap
            }
        }
    }
}
