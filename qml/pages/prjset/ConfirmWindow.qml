import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../components"

Window {
    id: root
    width: 400
    height: 100
    title: "Warning"
    
    signal saved(var state)
    
    property bool state
    
    ColumnLayout{
        anchors.fill: parent
        spacing: 10
        anchors.margins: 18
        Text {
            id: confirmText
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: qsTr("Are you sure want to change this item?")
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 13
            font.family: "Montserrat Medium"
        }
        RowLayout{
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            //yes
            Item{
                implicitWidth: 60
                implicitHeight: 30
                RoundButton{
                    anchors.fill: parent
                    text: qsTr("YES")
                    display: AbstractButton.TextOnly
                    onClicked: {
                        root.saved(true)
                        root.close()
                    }
                }
            }
            //no
            Item{
                implicitWidth: 60
                implicitHeight: 30
                RoundButton{
                    anchors.fill: parent
                    text: qsTr("NO")
                    display: AbstractButton.TextOnly
                    onClicked: {
                        root.saved(false)
                        root.close()
                    }
                }
            }
        }
    }
}