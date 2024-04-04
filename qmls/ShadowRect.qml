import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Rectangle{
    width: 100
    height: 100

    layer.enabled: true
    layer.effect: DropShadow{
        horizontalOffset: 0
        verticalOffset: 0
        radius: 4
        color: "#80000000"
    }
}
