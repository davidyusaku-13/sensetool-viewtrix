import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components"

Item{
    Layout.fillHeight: true
    Layout.fillWidth: true
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
                }
                TabButton {
                    text: qsTr("Demodulator Coefficient Generator")
                }
            }
            StackLayout{
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 10
                
                currentIndex: bar.currentIndex
                // Window Coef Layout
                ColumnLayout{
                    RowLayout{
                        Layout.preferredHeight: 4
                        ToolbarBtn{
                            Layout.fillWidth: true
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
                                win.clear()
                                win.drawWin(importRes[0])
                                winFields.itemAt(0).text = importRes[1]
                                winFields.itemAt(1).text = importRes[2]
                                winLength.currentIndex = winLength.find(importRes[3])
                                window.historyModel.addHistory("Imported", selectedFile, "", "")
                            }
                        }
                        ToolbarBtn{
                            Layout.fillWidth: true
                            text: qsTr("Export")
                            onClicked: {
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
                                let y = win.createWin(winFields.itemAt(0).text, winFields.itemAt(1).text, winFields.itemAt(2).text)
                                window.logic.exportWinCoef(selectedFile, y, winFields.itemAt(0).text, winFields.itemAt(1).text, winFields.itemAt(2).text)
                                window.historyModel.addHistory("Exported", selectedFile)
                            }
                        }
                    }
                    CoefGenChart{
                        id: win
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 20
                        spacing: 20
                        Repeater{
                            id: winFields
                            model: ListModel{
                                id: winGraphModel
                                ListElement{
                                    text: "Sample Number"
                                }
                                ListElement{
                                    text: "a0"
                                }
                            }
                            
                            delegate: TextField{
                                required property var model
                                required property int index
                                Layout.fillWidth: true
                                placeholderText: model.text
                                validator: RegularExpressionValidator {
                                    regularExpression: /[0-9.]+/
                                }
                            }
                        }
                        ComboBox {
                            id: winLength
                            Layout.fillWidth: true
                            model: [ "Half", "Full" ]
                        }
                        Button{
                            id: winBtn
                            implicitWidth: 80
                            text: "OK"
                            HoverHandler{
                                cursorShape: Qt.PointingHandCursor
                            }
                            onClicked: {
                                win.clear()
                                win.createWin(winFields.itemAt(0).text, winFields.itemAt(1).text, winLength.textAt(winLength.currentIndex))
                            }
                        }
                    }
                }
                
                // Demodulator Coef Layout
                ColumnLayout{
                    RowLayout{
                        Layout.preferredHeight: 4
                        ToolbarBtn{
                            text: qsTr("Import")
                            Layout.fillWidth: true
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
                            Layout.fillWidth: true
                            onClicked: {
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
                                window.logic.exportDemoCoef(selectedFile, y, demoFields.itemAt(0).text, demoFields.itemAt(1).text, demoFields.itemAt(2).text, demoFields.itemAt(3).text)
                                window.historyModel.addHistory("Exported", selectedFile)
                            }
                        }
                    }
                    CoefGenChart{
                        id: demo
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 20
                        spacing: 20
                        Repeater{
                            id: demoFields
                            model: ListModel{
                                id: demoGraphModel
                                ListElement{
                                    text: "Step"
                                }
                                ListElement{
                                    text: "Sample"
                                }
                                ListElement{
                                    text: "Cycle"
                                }
                                ListElement{
                                    text: "ADC Freq"
                                }
                            }
                            
                            delegate: TextField{
                                required property var model
                                Layout.fillWidth: true
                                placeholderText: model.text
                                validator: RegularExpressionValidator { regularExpression: /[0-9.]+/ }
                            }
                        }
                        Button{
                            id: demoBtn
                            implicitWidth: 80
                            text: qsTr("OK")
                            HoverHandler{
                                cursorShape: Qt.PointingHandCursor
                            }
                            onClicked: {
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