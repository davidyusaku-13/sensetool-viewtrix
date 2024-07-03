import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"
import "./ArrangementColumn"
import "./ItemColumn"
import "./ListColumn"

ShadowRect{
    Layout.fillWidth: true
    Layout.fillHeight: true
    ColumnLayout{
        anchors.fill: parent
        // Import Export Row
        RowLayout{
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 20
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Import"
                Material.background: Material.accent
            }
            ToolbarBtn{
                Layout.fillWidth: true
                text: "Export"
                Material.background: Material.accent
            }
        }
        SplitView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Scan Items
            ScanItemColumn{
                id: itemColumn
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 6/15 : parent.width * 2/7
            }
            // ScanArr Items
            ScanArrColumn{
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 6/15  : parent.width * 3/7
                onFocusIndex: (index, model) => {
                                  scanArrListColumn.index = index
                                  scanArrListColumn.model = model
                              }
            }
            // ScanArrList Column
            ScanArrListColumn{
                id: scanArrListColumn
                SplitView.fillHeight: true
                SplitView.minimumWidth: popUp.visible ? parent.width * 3/15  : parent.width * 1/7
            }
        }
    }
}
