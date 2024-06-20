import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

Item{
    id: root
    property int index: -1
    property var model: null
    onModelChanged: print(JSON.stringify(model))
    //scan list rect
    ShadowRect{
        anchors.fill: parent
        anchors.margins: 20
        color: Material.background
        ListView{
            anchors.fill: parent
            interactive: true
            clip: true
            //header
            headerPositioning: ListView.OverlayHeader
            header: ColumnLayout{
                id: chooseHeader
                width: parent.width
                height: 70
                spacing: 0
                z: 2
                Rectangle{
                    Layout.fillWidth: true
                    implicitHeight: 35
                    color: Material.accent
                    Text {
                        text: "Scan List " + root.index
                        font.pointSize: 12
                        font.family: "Montserrat SemiBold"
                        anchors.centerIn: parent
                        color: Material.foreground
                    }
                    Image{
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 7
                        fillMode: Image.PreserveAspectFit
                        height: parent.height-12
                        source: "../../images/close"
                        MouseArea{
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: scanArrListColumn.visible = false
                        }
                    }
                }
                RowLayout{
                    RoundButton{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        icon.source: "../../images/plus.png"
                        HoverHandler{
                            cursorShape: Qt.PointingHandCursor
                        }
                        onClicked: {
                            scanArrListWindow.manage(-1,null)
                        }
                    }
                    RoundButton{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        icon.source: "../../images/checklist.png"
                        HoverHandler{
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                    RoundButton{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        icon.source: "../../images/trash.png"
                        HoverHandler{
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                    ScanArrListWindow{
                        id: scanArrListWindow
                        onCreate: (object) => {
                                      for(let i=0; i<object.names.length; i++){
                                          scanArrChoose.append(object.get(i));
                                      }
                                  }
                        onModify: (index, object) => {
                                      scanArrChoose.set(index, object);
                                  }
                    }
                }
            }
            // Scan List
            model: DelegateModel{
                id: scanArrChooseModel
                model: root.model?.scans ?? []
                groups: [
                    DelegateModelGroup {
                        id: selectedChoose
                        name: "selected"
                    }
                ]
                delegate: ScanArrListItem{
                    id: scanArrChooseDel
                    required property string modelData
                    name: modelData
                    width: ListView.view.width
                    checkBox.checked: scanArrChooseDel.DelegateModel.inSelected
                    onSelected: {
                        scanArrChooseDel.DelegateModel.inSelected = !scanArrChooseDel.DelegateModel.inSelected
                    }
                }
                //delegate: dragDelegate
            }
        }
    }
}
