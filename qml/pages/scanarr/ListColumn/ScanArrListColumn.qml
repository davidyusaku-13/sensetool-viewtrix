import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../../components"

Item{
    id: root
    property int index: -1
    property var model: null
    readonly property int stepCount: model ? model.scans.count : 0

    // Where new steps go: after the single selected step, otherwise just before
    // the terminating AFE_END (or at the end if there is none).
    function insertPosition(){
        let scans = root.model.scans
        if(selectedChoose.count === 1) return selectedChoose.get(0).itemsIndex + 1
        if(scans.count > 0 && scans.get(scans.count-1).name === "AFE_END") return scans.count - 1
        return scans.count
    }
    function moveSelected(delta){
        if(!root.model || selectedChoose.count !== 1) return
        let i = selectedChoose.get(0).itemsIndex
        let j = i + delta
        if(j < 0 || j >= root.model.scans.count) return
        root.model.scans.move(i, j, 1)
    }
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
                        text: root.model ? (root.model.name + "  (" + root.stepCount + "/10)") : "Scan List"
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
                        source: "qrc:/images/close"
                        MouseArea{
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: scanArrListColumn.visible = false
                        }
                    }
                }
                RowLayout{
                    enabled: root.model !== null
                    RoundButton{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        icon.source: "qrc:/images/plus"
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
                        icon.source: "qrc:/images/checklist"
                        HoverHandler{
                            cursorShape: Qt.PointingHandCursor
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Select / deselect all steps")
                        // Select all, or deselect all when everything is selected.
                        onClicked: {
                            let all = selectedChoose.count === scanArrChooseModel.items.count
                            for(let i=0; i<scanArrChooseModel.items.count; i++){
                                scanArrChooseModel.items.get(i).inSelected = !all
                            }
                        }
                    }
                    RoundButton{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        icon.source: "qrc:/images/trash"
                        HoverHandler{
                            cursorShape: Qt.PointingHandCursor
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Remove selected steps")
                        onClicked: {
                            for(let i = selectedChoose.count-1; i>=0; i--){
                                root.model.scans.remove(selectedChoose.get(i).itemsIndex)
                            }
                        }
                    }
                    RoundButton{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        text: "\u25B2"
                        enabled: selectedChoose.count === 1
                        onClicked: root.moveSelected(-1)
                    }
                    RoundButton{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        text: "\u25BC"
                        enabled: selectedChoose.count === 1
                        onClicked: root.moveSelected(1)
                    }
                    ScanArrListWindow{
                        id: scanArrListWindow
                        onCreate: (object) => {
                                      if(!root.model) return
                                      let at = root.insertPosition()
                                      for(let i=0; i<object.names.length; i++){
                                          root.model.scans.insert(at + i, object.get(i));
                                      }
                                  }
                    }
                }
            }
            // Scan List
            model: DelegateModel{
                id: scanArrChooseModel
                model: root.model ? root.model.scans : []
                groups: [
                    DelegateModelGroup {
                        id: selectedChoose
                        name: "selected"
                    }
                ]
                delegate: ScanArrListItem{
                    id: scanArrChooseDel
                    required property var model
                    required property int index
                    name: "#" + (index + 1) + "   " + model.name
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
