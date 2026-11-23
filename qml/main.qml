import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore
import "components"

// The main window. Models and services are created in Python (src/app.py) and
// passed in, then handed down to the pages. Project logic (open/save, unsaved
// changes, undo) is in ProjectController; this file only adds the dialogs.
ApplicationWindow {
    id: window
    // provided by main.py (QQmlApplicationEngine.setInitialProperties)
    required property var prjSet          // PrjSetModel
    required property var appSet          // AppSetModel
    required property var scanArr         // ScanArrModel
    required property var history         // HistoryModel
    required property var updateChecker   // UpdateChecker
    required property var coefficientGen  // CoefficientGenerator
    required property var projectCtl      // ProjectController
    required property var translator      // Translator
    required property var updateManager   // UpdateManager

    property bool quitting: false

    function openProject(url){
        if(errors.show(window.projectCtl.open(url))) return
        window.history.addHistory(window.projectCtl.hasPath ? "Opened" : "Imported", url, "", "")
        let skipped = window.projectCtl.lastSkipped()
        if(skipped.length > 0)
            errors.show(qsTr("Imported. These ScanArrg rows had no name and were skipped:\n") + skipped.join("\n"))
    }
    function openProjectDialog(){
        if(window.projectCtl.dirty) askUnsaved(() => projectOpenDialog.open())
        else projectOpenDialog.open()
    }
    // then: run after a successful save (e.g. quit or open another project)
    property var afterSave: null
    function saveProject(asAs, then){
        afterSave = then || null
        if(asAs || !window.projectCtl.hasPath){ projectSaveDialog.open(); return }
        finishSave(window.projectCtl.save())
    }
    function finishSave(err){
        if(errors.show(err)){ afterSave = null; return }
        window.history.addHistory("Saved", window.projectCtl.path, "", "")
        if(afterSave){ let f = afterSave; afterSave = null; f() }
    }
    function askUnsaved(proceed){
        unsavedDialog.proceed = proceed
        unsavedDialog.open()
    }

    title: qsTr("SenseTool") + "-v" + window.updateChecker.version() + "  —  "
           + (window.projectCtl.name !== "" ? window.projectCtl.name : qsTr("Untitled project")) + (window.projectCtl.dirty ? " *" : "")
    visible: true
    width: 1280
    height: 720
    minimumWidth: 1000
    minimumHeight: 600

    Component.onCompleted: {
        // Reopen the last project, so work carries over between sessions.
        window.projectCtl.openLast()
        // In the background, so a slow or missing network never blocks startup.
        window.updateChecker.checkAsync()
    }

    SenseTool{
        id: sensetool
        anchors.fill: parent
        prjSetModel: window.prjSet
        appSetModel: window.appSet
        scanArrModel: window.scanArr
        historyModel: window.history
        project: window.projectCtl
        updates: window.updateChecker
        coefficients: window.coefficientGen
        translator: window.translator
        onOpenRequested: window.openProjectDialog()
        onSaveRequested: window.saveProject(false)
        onUpdateAvailable: updateWindow.show()
    }
    UpdateWindow{
        id: updateWindow
        updates: window.updateChecker
        downloader: window.updateManager
    }

    onClosing: (close) => {
        if(window.projectCtl.dirty && !quitting){
            close.accepted = false
            askUnsaved(() => { window.quitting = true; window.close() })
        }
    }

    Shortcut{ sequences: [StandardKey.Open]; onActivated: window.openProjectDialog() }
    Shortcut{ sequences: [StandardKey.Save]; onActivated: window.saveProject(false) }
    Shortcut{ sequences: [StandardKey.SaveAs, "Ctrl+Shift+S"]; onActivated: window.saveProject(true) }
    Shortcut{ sequences: [StandardKey.Undo]; onActivated: window.projectCtl.undo() }
    Shortcut{ sequences: [StandardKey.Redo, "Ctrl+Shift+Z"]; onActivated: window.projectCtl.redo() }

    FileDialog{
        id: projectOpenDialog
        title: qsTr("Open project")
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Project (*.yaml *.yml *.xlsx)"), qsTr("Project YAML (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
        onAccepted: window.openProject(selectedFile)
    }
    FileDialog{
        id: projectSaveDialog
        title: qsTr("Save project")
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("Project YAML (*.yaml *.yml)")]
        onAccepted: window.finishSave(window.projectCtl.saveAs(selectedFile))
        onRejected: window.afterSave = null
    }
    ErrorDialog{ id: errors; title: qsTr("SenseTool") }
    MessageDialog{
        id: unsavedDialog
        property var proceed: null
        title: qsTr("Unsaved changes")
        text: qsTr("Save changes to %1?").arg(window.projectCtl.name !== "" ? window.projectCtl.name : qsTr("this project"))
        informativeText: qsTr("Your changes will be lost if you don't save them.")
        buttons: MessageDialog.Save | MessageDialog.Discard | MessageDialog.Cancel
        onButtonClicked: (button, role) => {
            let go = proceed
            proceed = null
            if(button === MessageDialog.Save) window.saveProject(false, go)
            else if(button === MessageDialog.Discard && go) go()
        }
    }

    Connections {
        target: window.updateChecker
        function onUpdateChecked(available, version, changelog, link) {
            if (available) updateWindow.show()
        }
    }
    Settings{
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }
    Connections {
        target: window.updateManager
        function onProgressChanged(value) {
            updateWindow.progressBar.visible = true
            updateWindow.progressBar.value = value
            updateWindow.progressText.visible = true
            updateWindow.progressText.text = value + qsTr("% completed")
            if (value === 100) updateWindow.restartDialog.open()
        }
    }
}
