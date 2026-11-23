import QtQuick
import QtQuick.Controls

// Header checkbox for a DelegateModel-backed list: checked when every visible
// row is selected, partial when some are. The owner handles onClicked.
CheckBox{
    id: root
    // the group of rows that are shown (DelegateModel.items, or a filter group)
    required property var rows
    required property int selectedCount
    tristate: true
    checkState: selectedCount === 0 ? Qt.Unchecked
              : (selectedCount >= rows.count ? Qt.Checked : Qt.PartiallyChecked)
    nextCheckState: function(){ return checkState === Qt.Checked ? Qt.Unchecked : Qt.Checked }
    ToolTip.visible: hovered
    ToolTip.delay: 600
    ToolTip.text: qsTr("Select all (Ctrl+A)")
}
