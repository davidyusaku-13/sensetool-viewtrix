import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../../components"

// One row of the Project Setting table. Column widths match the header in PrjSetPage.
ShadowRect{
    id: root
    width: 1000
    height: 54
    property string name: "FILTER_THRES_MOTION_TOLERANCE_WINDOW"
    property string value: "(MSN_CH_LEN*MSN_FREQ_CNT*2)+AFE_CRC_LEN"
    property string desc: "Maximum count of timeslot in one mutual frame scan (need to consider for SingleTx, DTO and QTO scan option)"
    property string comment: ""
    property string resolved: ""
    property string issue: ""
    // true when only something this item refers to is wrong (not the item itself)
    property bool dependent: false
    property bool canDrag: true
    property alias dragArea: dragArea
    property alias checkBox: checkBox
    required property var content
    signal selected(bool status)
    signal activated()

    readonly property color issueColor: dependent ? "#EF8F00" : "#E53935"

    TapHandler{ onDoubleTapped: root.activated() }

    component CellText: Text{
        Layout.fillWidth: true
        color: Material.foreground
        font.pixelSize: 15
        font.family: "Montserrat Medium"
        elide: Text.ElideRight
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
    }
    component SubText: Text{
        Layout.fillWidth: true
        font.pixelSize: 12
        font.family: "Montserrat Medium"
        elide: Text.ElideRight
    }

    RowLayout{
        anchors.fill: parent
        spacing: 0
        ShadowRect{
            Layout.preferredWidth: 40
            Layout.fillHeight: true
            CheckBox{
                id: checkBox
                anchors.centerIn: parent
                onClicked: root.selected(checked)
            }
        }
        //item
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.horizontalStretchFactor: 10
            ColumnLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 0
                Item{ Layout.fillHeight: true }
                CellText{
                    id: nameText
                    text: root.name
                    HoverHandler{ id: nameHover }
                    ToolTip.visible: nameHover.hovered && nameText.truncated
                    ToolTip.text: root.name
                }
                SubText{
                    id: issueText
                    visible: root.issue !== ""
                    text: (root.dependent ? "↳ " : "⚠ ") + root.issue
                    color: root.issueColor
                    HoverHandler { id: issueHover }
                    ToolTip.visible: issueHover.hovered && issueText.truncated
                    ToolTip.text: root.issue
                }
                Item{ Layout.fillHeight: true }
            }
        }
        //value
        ShadowRect{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.horizontalStretchFactor: 10
            ColumnLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 0
                Item{ Layout.fillHeight: true }
                CellText{
                    id: valueText
                    text: root.value
                    HoverHandler{ id: valueHover }
                    ToolTip.visible: valueHover.hovered && valueText.truncated
                    ToolTip.text: root.value
                }
                SubText{
                    visible: root.resolved !== ""
                    text: "= " + root.resolved
                    color: Material.accent
                }
                Item{ Layout.fillHeight: true }
            }
        }
        //desc
        ShadowRect{
            Layout.fillHeight: true
            Layout.preferredWidth: root.width * 3/7
            RowLayout{
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 6
                spacing: 4
                Text{
                    id: descText
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.desc
                    color: Material.foreground
                    font.pixelSize: 14
                    font.family: "Montserrat Medium"
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    HoverHandler { id: descHover }
                    ToolTip.visible: descHover.hovered && descText.truncated
                    ToolTip.text: root.desc
                }
                // Review comment from the spreadsheet: kept out of the way, shown on hover.
                Text{
                    visible: root.comment !== ""
                    text: "ⓘ"
                    color: Material.foreground
                    opacity: commentHover.hovered ? 0.9 : 0.45
                    font.pixelSize: 16
                    HoverHandler { id: commentHover }
                    ToolTip.visible: commentHover.hovered
                    ToolTip.text: qsTr("Comment: ") + root.comment
                }
            }
        }
        //drag
        ShadowRect{
            Layout.preferredWidth: 45
            Layout.fillHeight: true
            Button{
                id: drag
                anchors.centerIn: parent
                flat: true
                enabled: root.canDrag
                opacity: root.canDrag ? 1 : 0.3
                icon.source: "qrc:/images/drag"
                icon.height: 15
                icon.color: Material.theme === Material.Light ? Material.color(Material.background, Material.Shade900) : Material.color(Material.background, Material.Shade200)
                padding: 0
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    enabled: root.canDrag
                    drag.target: pressed ? root.content: undefined
                    drag.axis: Drag.YAxis
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    hoverEnabled: true
                }
            }
        }
    }
}
