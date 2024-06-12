import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

Item{
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
                height: 35
                spacing: 0
                z: 2
                Rectangle{
                    Layout.fillWidth: true
                    implicitHeight: 35
                    color: Material.accent
                    Text {
                        text: "Scan List"
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
                }
            }
            // Scan List
            model: DelegateModel{
                id: scanArrChooseModel
                model: ListModel{
                    id: scanArrChoose
                }
                groups: [
                    DelegateModelGroup {
                        id: selectedChoose
                        name: "selected"
                    }
                ]
                delegate: ScanItem{
                    id: scanArrChooseDel
                    required property var model
                    name: model.name
                    desc: model.desc
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