pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

// A tooltip created only while `show` is true, for use inside list rows.
// `textFor` is a function, read only when the tip appears: a property *bound* to
// row data (as the attached ToolTip was) crashed the app when a filter removed
// rows, so nothing here follows row data while the tip is hidden.
Loader {
    id: tip
    property var textFor: null
    property bool show: false
    anchors.fill: parent
    active: show
    sourceComponent: ToolTip {
        visible: text !== ""
        delay: 400
        text: tip.textFor ? tip.textFor() : ""
    }
}
