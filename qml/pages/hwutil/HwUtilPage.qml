import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

Item{
    id: page
    Layout.fillHeight: true
    Layout.fillWidth: true

    // Input checks: "" when the fields can be plotted/exported, else what to fix.
    function winError(){
        let n = Number(winFields.itemAt(0).text), a0 = Number(winFields.itemAt(1).text)
        if(winFields.itemAt(0).text === "" || !Number.isInteger(n) || n < 2)
            return qsTr("Sample Number must be a whole number of at least 2.")
        if(winFields.itemAt(1).text === "" || isNaN(a0) || a0 < 0 || a0 > 1)
            return qsTr("a0 must be between 0 and 1 (0.5 = Hann, 0.54 = Hamming).")
        return ""
    }
    function demoError(){
        for(let i = 0; i < 4; i++){
            let f = demoFields.itemAt(i), v = Number(f.text)
            if(f.text === "" || !Number.isInteger(v) || v < 1)
                return qsTr("%1 must be a whole number of at least 1.").arg(f.label)
        }
        return ""
    }
    function complain(message){
        if(message === "") return false
        hwErrorDialog.text = message
        hwErrorDialog.open()
        return true
    }
    MessageDialog {
        id: hwErrorDialog
        title: qsTr("Hardware Utility")
        buttons: MessageDialog.Ok
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
                TabButton {
                    text: qsTr("Window Coefficient Generator")
                    HoverHandler{
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                TabButton {
                    text: qsTr("Demodulator Coefficient Generator")
                    HoverHandler{
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
            // Plain stacked pages rather than a StackLayout: a chart laid out while its
            // tab was hidden stayed 0 px tall when the tab was shown.
            Item{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 10

                // Window Coef Layout
                ColumnLayout{
                    anchors.fill: parent
                    visible: bar.currentIndex === 0
                    spacing: 10
                    RowLayout{
                        ToolbarBtn{
                            text: qsTr("Import")
                            onClicked: {
                                importWinCoef.open()
                            }
                        }
                        FileDialog {
                            id: importWinCoef
                            selectedNameFilter.index: 1
                            fileMode: FileDialog.OpenFile
                            nameFilters: ["YAML files (*.yaml *.yml)"]
                            onAccepted: {
                                let importRes = window.logic.importWinCoef(selectedFile)
                                if(importRes.length === 0){
                                    hwErrorDialog.text = window.logic.lastError()
                                    hwErrorDialog.open()
                                    return
                                }
                                win.clear()
                                win.drawWin(importRes[0])
                                winFields.itemAt(0).text = importRes[1]
                                winFields.itemAt(1).text = importRes[2]
                                winLength.currentIndex = winLength.find(importRes[3])
                                window.historyModel.addHistory("Imported", selectedFile, "", "")
                            }
                        }
                        ToolbarBtn{
                            text: qsTr("Export")
                            onClicked: {
                                if(page.complain(page.winError())) return
                                exportWinCoef.open()
                            }
                        }
                        FileDialog {
                            id: exportWinCoef
                            selectedNameFilter.index: 1
                            fileMode: FileDialog.SaveFile
                            nameFilters: ["YAML files (*.yaml *.yml)"]
                            onAccepted: {
                                win.clear()
                                let y = win.createWin(winFields.itemAt(0).text, winFields.itemAt(1).text, winLength.textAt(winLength.currentIndex))
                                let err = window.logic.exportWinCoef(selectedFile, y, winFields.itemAt(0).text, winFields.itemAt(1).text, winLength.textAt(winLength.currentIndex))
                                if(err !== ""){
                                    hwErrorDialog.text = err
                                    hwErrorDialog.open()
                                    return
                                }
                                window.historyModel.addHistory("Exported", selectedFile, "", "")
                            }
                        }
                    }
                    CoefGenChart{
                        id: win
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        emptyText: qsTr("Enter the sample number and a0 below, then press Plot.\nOr Import a window coefficient file.")
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.margins: 20
                        spacing: 20
                        Repeater{
                            id: winFields
                            model: ListModel{
                                id: winGraphModel
                                ListElement{
                                    text: QT_TR_NOOP("Sample Number")
                                }
                                ListElement{
                                    text: "a0"
                                }
                            }
                            
                            delegate: LabeledField{
                                required property var model
                                required property int index
                                Layout.fillWidth: true
                                label: qsTr(model.text)
                                // sample number: whole number; a0: decimal 0..1
                                validator: RegularExpressionValidator {
                                    regularExpression: index === 0 ? /[0-9]{1,5}/ : /[01]?(\.[0-9]{0,6})?/
                                }
                            }
                        }
                        ColumnLayout{
                            Layout.fillWidth: true
                            spacing: 2
                            Label{ text: qsTr("Window length"); opacity: 0.7; font.pixelSize: 12 }
                            ComboBox {
                                id: winLength
                                Layout.fillWidth: true
                                model: [ "Half", "Full" ]
                            }
                        }
                        ToolbarBtn{
                            id: winBtn
                            Layout.alignment: Qt.AlignBottom
                            text: qsTr("Plot")
                            primary: true
                            onClicked: {
                                if(page.complain(page.winError())) return
                                win.clear()
                                win.createWin(winFields.itemAt(0).text, winFields.itemAt(1).text, winLength.textAt(winLength.currentIndex))
                            }
                        }
                    }
                }
                
                // Demodulator Coef Layout
                ColumnLayout{
                    anchors.fill: parent
                    visible: bar.currentIndex === 1
                    spacing: 10
                    RowLayout{
                        ToolbarBtn{
                            text: qsTr("Import")
                            onClicked: {
                                importDemoCoef.open()
                            }
                        }
                        FileDialog {
                            id: importDemoCoef
                            selectedNameFilter.index: 1
                            fileMode: FileDialog.OpenFile
                            nameFilters: ["YAML files (*.yaml *.yml)"]
                            onAccepted: {
                                let importRes = window.logic.importDemoCoef(selectedFile)
                                if(importRes.length === 0){
                                    hwErrorDialog.text = window.logic.lastError()
                                    hwErrorDialog.open()
                                    return
                                }
                                let y = importRes[0]
                                demo.clear()
                                demo.drawDemo(y[0], y[1])
                                demoFields.itemAt(0).text = importRes[1]
                                demoFields.itemAt(1).text = importRes[2]
                                demoFields.itemAt(2).text = importRes[3]
                                demoFields.itemAt(3).text = importRes[4]
                                window.historyModel.addHistory("Imported", selectedFile, "", "")
                            }
                        }
                        ToolbarBtn{
                            text: qsTr("Export")
                            onClicked: {
                                if(page.complain(page.demoError())) return
                                exportDemoCoef.open()
                            }
                        }
                        FileDialog {
                            id: exportDemoCoef
                            selectedNameFilter.index: 1
                            fileMode: FileDialog.SaveFile
                            nameFilters: ["YAML files (*.yaml *.yml)"]
                            onAccepted: {
                                demo.clear()
                                let y = demo.createDemo(demoFields.itemAt(0).text, demoFields.itemAt(1).text, demoFields.itemAt(2).text, demoFields.itemAt(3).text)
                                let err = window.logic.exportDemoCoef(selectedFile, y, demoFields.itemAt(0).text, demoFields.itemAt(1).text, demoFields.itemAt(2).text, demoFields.itemAt(3).text)
                                if(err !== ""){
                                    hwErrorDialog.text = err
                                    hwErrorDialog.open()
                                    return
                                }
                                window.historyModel.addHistory("Exported", selectedFile, "", "")
                            }
                        }
                    }
                    CoefGenChart{
                        id: demo
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        emptyText: qsTr("Enter step, sample, cycle and ADC frequency below, then press Plot.\nOr Import a demodulator coefficient file.")
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.margins: 20
                        spacing: 20
                        Repeater{
                            id: demoFields
                            model: ListModel{
                                id: demoGraphModel
                                ListElement{
                                    text: QT_TR_NOOP("Step")
                                }
                                ListElement{
                                    text: QT_TR_NOOP("Sample")
                                }
                                ListElement{
                                    text: QT_TR_NOOP("Cycle")
                                }
                                ListElement{
                                    text: QT_TR_NOOP("ADC Freq")
                                }
                            }
                            
                            delegate: LabeledField{
                                required property var model
                                Layout.fillWidth: true
                                label: qsTr(model.text)
                                validator: RegularExpressionValidator { regularExpression: /[0-9]{1,7}/ }
                            }
                        }
                        ToolbarBtn{
                            id: demoBtn
                            Layout.alignment: Qt.AlignBottom
                            text: qsTr("Plot")
                            primary: true
                            onClicked: {
                                if(page.complain(page.demoError())) return
                                demo.clear()
                                demo.createDemo(demoFields.itemAt(0).text, demoFields.itemAt(1).text, demoFields.itemAt(2).text, demoFields.itemAt(3).text)
                            }
                        }
                    }
                }
            }
        }
    }
}