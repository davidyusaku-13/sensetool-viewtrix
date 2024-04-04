import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Rectangle{
    radius: 5
    layer.enabled: true
    layer.effect: DropShadow{
        horizontalOffset: 0
        verticalOffset: 0
        radius: 3
        color: "#80000000"
    }
}
