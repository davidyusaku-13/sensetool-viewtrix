import QtQuick

// The keyboard shortcuts every list page offers. Connect the signals you need;
// shortcuts work only while `active` (the page is shown).
Item {
    id: root
    property bool active: false
    property int selectedCount: 0
    // a text field has focus: let it keep Delete, Enter and Ctrl+A
    property bool typing: false
    property bool canFind: false
    signal add()
    signal edit()
    signal remove()
    signal selectAll()
    signal generate()
    signal find()

    Shortcut { sequences: [StandardKey.New]; enabled: root.active; onActivated: root.add() }
    Shortcut { sequences: ["Ctrl+G"]; enabled: root.active; onActivated: root.generate() }
    Shortcut { sequences: [StandardKey.Find]; enabled: root.active && root.canFind; onActivated: root.find() }
    Shortcut { sequences: [StandardKey.SelectAll]; enabled: root.active && !root.typing; onActivated: root.selectAll() }
    Shortcut {
        sequences: [StandardKey.Delete]
        enabled: root.active && !root.typing && root.selectedCount > 0
        onActivated: root.remove()
    }
    Shortcut {
        sequences: ["Return", "Enter", "F2"]
        enabled: root.active && !root.typing && root.selectedCount === 1
        onActivated: root.edit()
    }
}
