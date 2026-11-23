import QtQuick
import QtQuick.Controls.Material
import QtCharts

// Draws coefficient series; it computes nothing. plot([{name, values}, ...]).
ChartView {
    id: chartView
    dropShadowEnabled: true
    antialiasing: true
    theme: Material.theme === Material.Dark ? ChartView.ChartThemeDark : ChartView.ChartThemeLight
    // Shown until something is plotted.
    property string emptyText: ""
    // ChartView.count has no change signal, so track plotting ourselves.
    property bool plotted: false

    function plot(series){
        clear()
        let longest = 0
        for(let s of series){
            let line = chartView.createSeries(ChartView.SeriesTypeLine, s.name, xAxis, yAxis)
            line.style = Qt.DotLine
            for(let i = 0; i < s.values.length; i++) line.append(i, s.values[i])
            longest = Math.max(longest, s.values.length)
        }
        xAxis.max = Math.max(1, longest - 1)
        plotted = series.length > 0
    }
    function clear(){
        plotted = false
        chartView.removeAllSeries()
    }

    Text{
        anchors.centerIn: parent
        visible: !chartView.plotted && chartView.emptyText !== ""
        width: parent.width * 0.7
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: chartView.emptyText
        color: Material.foreground
        opacity: 0.6
        font.pixelSize: 16
        font.family: "Montserrat Medium"
    }
    ValueAxis { id: xAxis; min: 0; max: 49 }
    ValueAxis { id: yAxis; min: -256; max: 256 }
}
