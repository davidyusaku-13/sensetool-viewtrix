import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Controls.Material

RoundButton{
    Layout.preferredHeight: 45
    font.pixelSize: 15
    font.family: "Montserrat Medium"
    HoverHandler{
        cursorShape: Qt.PointingHandCursor
    }
}
