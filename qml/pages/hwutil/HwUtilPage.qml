import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

// Hardware Utilities: window and demodulator coefficient generators.
// The maths and the input rules are in CoefficientGenerator (Python).
Item{
    id: page
    Layout.fillHeight: true
    Layout.fillWidth: true

    // dependencies, passed in by SenseTool
    required property var coefficients   // CoefficientGenerator
    required property var history        // HistoryModel
    property alias currentTab: bar.currentIndex

    function plotWindow(){
        if(errors.show(page.coefficients.checkWindow(sampleNumber.text, a0.text))) return false
        win.plot([{name: qsTr("Window coefficients"),
                   values: page.coefficients.windowCoefficients(sampleNumber.text, a0.text, winLength.currentText)}])
        return true
    }
    function plotDemodulator(){
        if(errors.show(page.coefficients.checkDemodulator(step.text, sample.text, cycle.text, adcFreq.text))) return false
        let d = page.coefficients.demodulatorCoefficients(step.text, sample.text, cycle.text)
        demo.plot([{name: qsTr("I Coef"), values: d.i}, {name: qsTr("Q Coef"), values: d.q}])
        return true
    }

    ErrorDialog{ id: errors; title: qsTr("Hardware Utility") }
    FileDialog {
        id: importWin
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: {
            let r = page.coefficients.importWindow(selectedFile)
            if(errors.show(r.error)) return
            sampleNumber.text = r.sampleNumber
            a0.text = r.a0
            winLength.currentIndex = Math.max(0, winLength.find(r.length))
            win.plot([{name: qsTr("Window coefficients"), values: r.values}])
            page.history.addHistory("Imported", selectedFile, "", "")
        }
    }
    FileDialog {
        id: exportWin
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: {
            if(errors.show(page.coefficients.exportWindow(selectedFile, sampleNumber.text, a0.text, winLength.currentText))) return
            page.plotWindow()
            page.history.addHistory("Exported", selectedFile, "", "")
        }
    }
    FileDialog {
        id: importDemo
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: {
            let r = page.coefficients.importDemodulator(selectedFile)
            if(errors.show(r.error)) return
            step.text = r.step
            sample.text = r.sample
            cycle.text = r.cycle
            adcFreq.text = r.adcFreq
            demo.plot([{name: qsTr("I Coef"), values: r.i}, {name: qsTr("Q Coef"), values: r.q}])
            page.history.addHistory("Imported", selectedFile, "", "")
        }
    }
    FileDialog {
        id: exportDemo
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("YAML files (*.yaml *.yml)")]
        onAccepted: {
            if(errors.show(page.coefficients.exportDemodulator(selectedFile, step.text, sample.text, cycle.text, adcFreq.text))) return
            page.plotDemodulator()
            page.history.addHistory("Exported", selectedFile, "", "")
        }
    }

    ShadowRect{
        anchors.fill: parent
        color: Material.background
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            TabBar {
                id: bar
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                font.family: "Montserrat SemiBold"
                font.pixelSize: 17
                TabButton { text: qsTr("Window Coefficient Generator") }
                TabButton { text: qsTr("Demodulator Coefficient Generator") }
            }
            // Plain stacked pages rather than a StackLayout: a chart laid out while its
            // tab was hidden stayed 0 px tall when the tab was shown.
            Item{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 10
                ColumnLayout{
                    anchors.fill: parent
                    visible: bar.currentIndex === 0
                    spacing: 10
                    RowLayout{
                        ToolbarBtn{ text: qsTr("Import"); onClicked: importWin.open() }
                        ToolbarBtn{ text: qsTr("Export"); onClicked: if(!errors.show(page.coefficients.checkWindow(sampleNumber.text, a0.text))) exportWin.open() }
                    }
                    CoefGenChart{
                        id: win
                        objectName: "windowChart"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        emptyText: qsTr("Enter the sample number and a0 below, then press Plot.\nOr Import a window coefficient file.")
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.margins: 20
                        spacing: 20
                        LabeledField{ id: sampleNumber; Layout.fillWidth: true; label: qsTr("Sample Number")
                                      validator: RegularExpressionValidator { regularExpression: /[0-9]{1,5}/ } }
                        LabeledField{ id: a0; Layout.fillWidth: true; label: "a0"
                                      validator: RegularExpressionValidator { regularExpression: /[01]?(\.[0-9]{0,6})?/ } }
                        ColumnLayout{
                            Layout.fillWidth: true
                            spacing: 2
                            Label{ text: qsTr("Window length"); opacity: 0.7; font.pixelSize: 12 }
                            ComboBox { id: winLength; Layout.fillWidth: true; model: [ "Half", "Full" ] }
                        }
                        ToolbarBtn{ Layout.alignment: Qt.AlignBottom; text: qsTr("Plot"); primary: true; onClicked: page.plotWindow() }
                    }
                }
                ColumnLayout{
                    anchors.fill: parent
                    visible: bar.currentIndex === 1
                    spacing: 10
                    RowLayout{
                        ToolbarBtn{ text: qsTr("Import"); onClicked: importDemo.open() }
                        ToolbarBtn{ text: qsTr("Export"); onClicked: if(!errors.show(page.coefficients.checkDemodulator(step.text, sample.text, cycle.text, adcFreq.text))) exportDemo.open() }
                    }
                    CoefGenChart{
                        id: demo
                        objectName: "demodulatorChart"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        emptyText: qsTr("Enter step, sample, cycle and ADC frequency below, then press Plot.\nOr Import a demodulator coefficient file.")
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.margins: 20
                        spacing: 20
                        LabeledField{ id: step; Layout.fillWidth: true; label: qsTr("Step"); validator: RegularExpressionValidator { regularExpression: /[0-9]{1,7}/ } }
                        LabeledField{ id: sample; Layout.fillWidth: true; label: qsTr("Sample"); validator: RegularExpressionValidator { regularExpression: /[0-9]{1,7}/ } }
                        LabeledField{ id: cycle; Layout.fillWidth: true; label: qsTr("Cycle"); validator: RegularExpressionValidator { regularExpression: /[0-9]{1,7}/ } }
                        LabeledField{ id: adcFreq; Layout.fillWidth: true; label: qsTr("ADC Freq"); validator: RegularExpressionValidator { regularExpression: /[0-9]{1,7}/ } }
                        ToolbarBtn{ Layout.alignment: Qt.AlignBottom; text: qsTr("Plot"); primary: true; onClicked: page.plotDemodulator() }
                    }
                }
            }
        }
    }
    // inputs and charts, for tests
    property alias sampleNumberField: sampleNumber
    property alias a0Field: a0
    property alias stepField: step
    property alias sampleField: sample
    property alias cycleField: cycle
    property alias adcFreqField: adcFreq
    property alias windowChart: win
    property alias demodulatorChart: demo
}
