import QtQuick
import QtTest
import "../../qml/pages/hwutil"

Item {
    width: 1000
    height: 700

    // Stand-ins for CoefficientGenerator / HistoryModel (the real maths is tested in Python).
    QtObject {
        id: fakeCoefficients
        property string windowError: ""
        function checkWindow(n, a0) { return windowError }
        function windowCoefficients(n, a0, length) { return [20, 128, 256, 128, 20] }
        function checkDemodulator(step, sample, cycle, adc) { return "" }
        function demodulatorCoefficients(step, sample, cycle) { return {"i": [0, 128, 0, -128], "q": [128, 0, -128, 0]} }
    }
    QtObject { id: fakeHistory; function addHistory() {} }

    HwUtilPage {
        id: page
        anchors.fill: parent
        coefficients: fakeCoefficients
        history: fakeHistory
    }

    TestCase {
        name: "HwUtilPage"
        when: windowShown

        function test_window_plot() {
            page.currentTab = 0
            fakeCoefficients.windowError = ""
            verify(page.plotWindow())
            verify(page.windowChart.plotted)
            compare(page.windowChart.series(0).count, 5)
        }

        function test_invalid_input_plots_nothing() {
            page.currentTab = 0
            page.windowChart.clear()
            fakeCoefficients.windowError = "Sample Number must be a whole number of at least 2."
            verify(!page.plotWindow())
            verify(!page.windowChart.plotted)
        }

        // Regression: the chart on the second tab used to be laid out while hidden
        // and stayed 0 px tall, so nothing was visible after pressing Plot.
        function test_demodulator_chart_is_visible_on_its_tab() {
            page.currentTab = 1
            waitForRendering(page)
            verify(page.demodulatorChart.height > 100, "chart height " + page.demodulatorChart.height)
            verify(page.plotDemodulator())
            compare(page.demodulatorChart.count, 2)
            compare(page.demodulatorChart.series(1).count, 4)
        }
    }
}
