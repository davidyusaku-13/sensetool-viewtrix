import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtCharts

ChartView {
    id: chartView
    
    dropShadowEnabled: true
    antialiasing: true
    theme: Material.theme === Material.Dark ? ChartView.ChartThemeDark :  ChartView.ChartThemeLight
    
    function drawWin(y){
        chartView.createSeries(ChartView.SeriesTypeLine, "Window Coefficient Generator", xAxis, yAxis)
        for(let i=0; i<y.length; i++){
            chartView.series(0).append(i, y[i])
        }
        chartView.series(0).style = Qt.DotLine
        
        chartView.axes[0].max = y.length
    }
    
    function drawDemo(coefficients){
        // Single series for coefficients
        chartView.createSeries(ChartView.SeriesTypeLine, "Demodulator Coefficients", xAxis, yAxis)
        for(let i=0; i<coefficients.length; i++){
            chartView.series(0).append(i, coefficients[i])
        }
        chartView.series(0).style = Qt.DotLine

        chartView.axes[0].max = coefficients.length
    }
    
    function createWin(win_sample_number, win_a0, win_length){
        // WINDOW COEF
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
        chartView.createSeries(ChartView.SeriesTypeLine, "Demodulator Coefficients", xAxis, yAxis)

        // Single coefficient list
        let coefficients = window.logic.demo_coef_gen(demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq)
        for(let i=0; i<coefficients.length; i++){
            chartView.series(0).append(i, coefficients[i])
        }
        chartView.series(0).style = Qt.binding(chartView.setStyle)

        chartView.axes[0].max = demo_sample_number

        return coefficients
    }
    
    function setStyle(){
        let _=Material.theme
        return Qt.DotLine
    }
    
    function clear(){
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