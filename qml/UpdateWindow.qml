import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
  id: root
  title: qsTr("New Version Available!!!")
  minimumWidth: 300
  minimumHeight: 200
  ColumnLayout{
    anchors.fill: parent
    Frame{
      Layout.fillWidth: true
      Layout.fillHeight: true
      Text{
        anchors.centerIn: parent
        text: qsTr("Update available!")
      }
    }
    RowLayout{
      Layout.fillWidth: true
      Layout.fillHeight: true
      RoundButton{
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 10
        text: qsTr("Cancel")
        onClicked: root.close()
      }
      RoundButton{
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 10
        text: qsTr("Download")
      }
    }
  }
}