pragma Singleton
import QtQuick
import QtQuick.Controls.Material

// App-wide look. SenseTool binds `dark` to the user's setting.
// One brand colour (Viewtrix orange), tuned per theme for contrast:
// white text on the darker orange (light theme), dark text on the lighter one (dark theme).
QtObject {
    property bool dark: false
    readonly property int theme: dark ? Material.Dark : Material.Light
    readonly property color accent: dark ? "#F5A04D" : "#C45500"
    readonly property color onAccent: dark ? "#1C1B1F" : "#FFFFFF"
    readonly property color error: "#E53935"
    // a problem caused by something else (e.g. an item that depends on a broken one)
    readonly property color warning: "#EF8F00"
}
