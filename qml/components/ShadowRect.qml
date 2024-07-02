import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Rectangle{
    width: 100
    height: 100
    color: Material.theme === Material.Light ? Material.background : "#1C1B1F"
    layer.enabled: true
    layer.effect: DropShadow{
        horizontalOffset: 0
        verticalOffset: 0
        radius: 3
        // color: Material.theme === Material.Light ? "#80000000" : Material.background
        color: Material.color(Material.foreground, Material.Shade200)
    }
}