import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

RoundButton{
    text: "Import"
    Layout.preferredHeight: 25
    verticalPadding: 0
    font.pixelSize: 15
    font.family: "Montserrat Medium"
    radius: 5
    palette {
        button: "#000000"
        buttonText: "white"
    }
    HoverHandler{
        cursorShape: Qt.PointingHandCursor
    }
}
