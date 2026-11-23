import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtCharts

ChartView {
    id: chartView
    
    dropShadowEnabled: true
    antialiasing: true
    theme: Material.theme === Material.Dark ? ChartView.ChartThemeDark :  ChartView.ChartThemeLight
    // Shown until something is plotted.
    property string emptyText: ""
    // ChartView.count has no change signal, so track plotting ourselves.
    property bool plotted: false
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
    
    function drawWin(y){
        plotted = true
        chartView.createSeries(ChartView.SeriesTypeLine, "Window Coefficient Generator", xAxis, yAxis)
        for(let i=0; i<y.length; i++){
            chartView.series(0).append(i, y[i])
        }
        chartView.series(0).style = Qt.DotLine
        
        chartView.axes[0].max = y.length
    }
    
    function drawDemo(y_sin, y_cos){
        plotted = true
        // I Coef
        chartView.createSeries(ChartView.SeriesTypeLine, "I Coef", xAxis, yAxis)
        for(let i=0; i<y_sin.length; i++){
            chartView.series(0).append(i, y_sin[i])
        }
        chartView.series(0).style = Qt.DotLine
        
        // Q Coef
        chartView.createSeries(ChartView.SeriesTypeLine, "Q Coef", xAxis, yAxis)
        for(let i=0; i<y_cos.length; i++){
            chartView.series(1).append(i, y_cos[i])
        }
        chartView.series(1).style = Qt.DotLine
        
        chartView.axes[0].max = y_sin.length
    }
    
    function createWin(win_sample_number, win_a0, win_length){
        // WINDOW COEF
        plotted = true
        chartView.createSeries(ChartView.SeriesTypeLine, "Window Coefficient Generator", xAxis, yAxis)
        let y = window.logic.win_coef_gen(win_sample_number, win_a0, win_length)
        for(let i=0; i<y.length; i++){
            chartView.series(0).append(i, y[i])
        }
        chartView.series(0).style = Qt.binding(chartView.setStyle)
        
        chartView.axes[0].max = y.length
        
        return y
    }
    
    function createDemo(demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq){
        // Chart & Title creation
        plotted = true
        chartView.createSeries(ChartView.SeriesTypeLine, "I Coef", xAxis, yAxis)
        chartView.createSeries(ChartView.SeriesTypeLine, "Q Coef", xAxis, yAxis)

        // I Coef
        let y_sin = window.logic.demo_coef_gen(demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq)[0]
        for(let i=0; i<y_sin.length; i++){
            chartView.series(0).append(i, y_sin[i])
        }
        chartView.series(0).style = Qt.DotLine
        
        // Q Coef
        let y_cos = window.logic.demo_coef_gen(demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq)[1]
        for(let i=0; i<y_cos.length; i++){
            chartView.series(1).append(i, y_cos[i])
        }
        chartView.series(1).style = Qt.binding(chartView.setStyle)
        
        chartView.axes[0].max = demo_sample_number
        
        return [y_sin, y_cos]
    }
    
    function setStyle(){
        let _=Material.theme
        return Qt.DotLine
    }
    
    function clear(){
        plotted = false
        chartView.removeAllSeries()
    }
    
    ValueAxis {
        id: xAxis
        max: 50
        min: 0
    }
    ValueAxis {
        id: yAxis
        max: 256
        min: -max
    }
}