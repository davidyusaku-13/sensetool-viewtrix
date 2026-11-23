// The Python-registered types (PrjSetModel, ...) are invisible to qmllint.
// qmllint disable unresolved-type
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore
import PrjSetModel
import AppSetModel
import ScanArrModel
import HistoryModel
import ProjectController
import UpdateChecker
import Coefficients
import "components"

// Composition root: creates the models and services once and hands them down.
// Project logic (open/save, unsaved changes, undo) is in ProjectController;
// this file only adds the dialogs around it.
ApplicationWindow {
    id: window
    // provided by main.py (QQmlApplicationEngine.setInitialProperties)
    required property var translator     // Translator
    required property var updateManager  // UpdateManager

    PrjSetModel { id: prjSet }
    AppSetModel { id: appSet }
    ScanArrModel { id: scanArr }
    HistoryModel { id: history }
    UpdateChecker { id: updateChecker }
    CoefficientGenerator { id: coefficientGen }
    ProjectController { id: projectCtl }

    property bool quitting: false

    function openProject(url){
        if(errors.show(projectCtl.open(url))) return
        history.addHistory(projectCtl.hasPath ? "Opened" : "Imported", url, "", "")
        let skipped = projectCtl.lastSkipped()
        if(skipped.length > 0)
            errors.show(qsTr("Imported. These ScanArrg rows had no name and were skipped:\n") + skipped.join("\n"))
    }
    function openProjectDialog(){
        if(projectCtl.dirty) askUnsaved(() => projectOpenDialog.open())
        else projectOpenDialog.open()
    }
    // then: run after a successful save (e.g. quit or open another project)
    property var afterSave: null
    function saveProject(asAs, then){
        afterSave = then || null
        if(asAs || !projectCtl.hasPath){ projectSaveDialog.open(); return }
        finishSave(projectCtl.save())
    }
    function finishSave(err){
        if(errors.show(err)){ afterSave = null; return }
        history.addHistory("Saved", projectCtl.path, "", "")
        if(afterSave){ let f = afterSave; afterSave = null; f() }
    }
    function askUnsaved(proceed){
        unsavedDialog.proceed = proceed
        unsavedDialog.open()
    }

    title: qsTr("SenseTool") + "-v" + updateChecker.version() + "  —  "
           + (projectCtl.name !== "" ? projectCtl.name : qsTr("Untitled project")) + (projectCtl.dirty ? " *" : "")
    visible: true
    width: 1280
    height: 720
    minimumWidth: 1000
    minimumHeight: 600

    Component.onCompleted: {
        for(let w of [prjSet, appSet, scanArr]) projectCtl.addWorkspace(w)
        // Reopen the last project, so work carries over between sessions.
        projectCtl.openLast()
        // In the background, so a slow or missing network never blocks startup.
        updateChecker.checkAsync()
    }

    SenseTool{
        id: sensetool
        anchors.fill: parent
        prjSetModel: prjSet
        appSetModel: appSet
        scanArrModel: scanArr
        historyModel: history
        project: projectCtl
        updates: updateChecker
        coefficients: coefficientGen
        translator: window.translator
        onOpenRequested: window.openProjectDialog()
        onSaveRequested: window.saveProject(false)
        onUpdateAvailable: updateWindow.show()
    }
    UpdateWindow{
        id: updateWindow
        updates: updateChecker
        downloader: window.updateManager
    }

    onClosing: (close) => {
        if(projectCtl.dirty && !quitting){
            close.accepted = false
            askUnsaved(() => { window.quitting = true; window.close() })
        }
    }

    Shortcut{ sequences: [StandardKey.Open]; onActivated: window.openProjectDialog() }
    Shortcut{ sequences: [StandardKey.Save]; onActivated: window.saveProject(false) }
    Shortcut{ sequences: [StandardKey.SaveAs, "Ctrl+Shift+S"]; onActivated: window.saveProject(true) }
    Shortcut{ sequences: [StandardKey.Undo]; onActivated: projectCtl.undo() }
    Shortcut{ sequences: [StandardKey.Redo, "Ctrl+Shift+Z"]; onActivated: projectCtl.redo() }

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
        onAccepted: window.finishSave(projectCtl.saveAs(selectedFile))
        onRejected: window.afterSave = null
    }
    ErrorDialog{ id: errors; title: qsTr("SenseTool") }
    MessageDialog{
        id: unsavedDialog
        property var proceed: null
        title: qsTr("Unsaved changes")
        text: qsTr("Save changes to %1?").arg(projectCtl.name !== "" ? projectCtl.name : qsTr("this project"))
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
        target: updateChecker
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
