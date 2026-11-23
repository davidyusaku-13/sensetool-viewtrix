import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import PrjSetModel
import AppSetModel
import HistoryModel
import AppLogic
import QtCore

ApplicationWindow {
    id: window

    property PrjSetModel prjSetModel: PrjSetModel {}
    property AppSetModel appSetModel: AppSetModel {}
    property HistoryModel historyModel: HistoryModel{}
    property AppLogic logic: AppLogic{
        parent: window
    }

    // ---- project (one prjcfg.yaml holding all three workspaces) ---------
    property url projectUrl: ""
    readonly property string projectPath: projectUrl.toString() === "" ? "" : decodeURIComponent(projectUrl.toString().replace(/^file:\/\//, ""))
    readonly property string projectName: projectPath === "" ? "" : projectPath.split(/[\\/]/).pop()
    // Text of the project as last saved/opened, and as it is now. Unsaved = they differ.
    property string savedText: ""
    property string currentText: ""
    readonly property bool dirty: currentText !== savedText
    // Undo: snapshots of the whole project; restoring one reloads every workspace.
    property var undoStack: []
    property var redoStack: []
    readonly property bool canUndo: undoStack.length > 0
    readonly property bool canRedo: redoStack.length > 0
    property bool quitting: false
    property var afterSave: null
    readonly property int undoLimit: 100

    function snapshot(){
        let scan = sensetool.scanArrPage.collect()
        return logic.projectText(prjSetModel, appSetModel, scan[0], scan[1])
    }
    // Called often (timer): records a change as one undo step.
    function track(){
        let t = snapshot()
        if(t === currentText) return
        let u = undoStack.slice()
        u.push(currentText)
        if(u.length > undoLimit) u.shift()
        undoStack = u
        redoStack = []
        currentText = t
    }
    function restore(text){
        let r = logic.restoreProject(text, prjSetModel, appSetModel)
        if(r.error){ showMessage(r.error); return false }
        sensetool.scanArrPage.load(r)
        currentText = text
        return true
    }
    function undo(){
        track()
        if(undoStack.length === 0) return
        let u = undoStack.slice(), t = u.pop()
        let current = currentText
        if(restore(t)){
            undoStack = u
            redoStack = redoStack.concat([current])
        }
    }
    function redo(){
        track()
        if(redoStack.length === 0) return
        let r = redoStack.slice(), t = r.pop()
        let current = currentText
        if(restore(t)){
            redoStack = r
            undoStack = undoStack.concat([current])
        }
    }
    function resetHistory(saved){
        currentText = snapshot()
        savedText = saved ? currentText : ""
        undoStack = []
        redoStack = []
    }
    function showMessage(text){
        messageDialog.text = text
        messageDialog.open()
    }
    function openProject(url, quiet){
        let r = logic.openProject(url, prjSetModel, appSetModel)
        if(r.error){
            if(!quiet) showMessage(r.error)
            return false
        }
        sensetool.scanArrPage.load(r)
        let isSheet = /\.xlsx?$|\.xlsm$/i.test(url.toString())
        // A spreadsheet is imported, not edited in place: saving asks for a .yaml.
        projectUrl = isSheet ? "" : url
        resetHistory(!isSheet)
        if(!isSheet) appSettings.lastProject = url.toString()
        historyModel.addHistory(isSheet ? "Imported" : "Opened", url, "", "")
        if(r.skipped && r.skipped.length > 0 && !quiet)
            showMessage(qsTr("Imported. These ScanArrg rows had no name and were skipped:\n") + r.skipped.join("\n"))
        return true
    }
    function openProjectDialog(){
        if(dirty) askUnsaved(() => projectOpenDialog.open())
        else projectOpenDialog.open()
    }
    // asAs: always ask for a file name
    function saveProject(asAs, then){
        track()
        afterSave = then || null
        if(asAs || projectUrl.toString() === ""){
            projectSaveDialog.open()
            return
        }
        writeProject(projectUrl)
    }
    function writeProject(url){
        let scan = sensetool.scanArrPage.collect()
        let err = logic.saveProject(url, prjSetModel, appSetModel, scan[0], scan[1])
        if(err !== ""){ showMessage(err); afterSave = null; return }
        projectUrl = url
        appSettings.lastProject = url.toString()
        currentText = snapshot()
        savedText = currentText
        historyModel.addHistory("Saved", url, "", "")
        if(afterSave){ let f = afterSave; afterSave = null; f() }
    }
    // Save / Discard / Cancel before something that would lose changes.
    function askUnsaved(proceed){
        unsavedDialog.proceed = proceed
        unsavedDialog.open()
    }

    title: qsTr("SenseTool") + "-v" + logic.getVersion() + "  —  "
           + (projectName !== "" ? projectName : qsTr("Untitled project")) + (dirty ? " *" : "")
    visible: true
    width: 1280
    height: 720
    minimumWidth: 1000
    minimumHeight: 600

    SenseTool{
        id: sensetool
        anchors.fill: parent
        UpdateWindow{
            id: update_window
            Material.theme: sensetool.theme
            Material.accent: sensetool.accent
        }
        Component.onCompleted: {
            // Runs in a background thread so a slow or missing network never blocks startup.
            logic.checkUpdateAsync()
            // Reopen the last project, so work carries over between sessions.
            let last = appSettings.lastProject
            if(last !== "" && logic.fileExists(last)) window.openProject(last, true)
            else window.resetHistory(true)
            trackTimer.start()
        }
    }

    Timer{
        id: trackTimer
        interval: 600
        repeat: true
        onTriggered: window.track()
    }

    onClosing: (close) => {
        if(dirty && !quitting){
            close.accepted = false
            askUnsaved(() => { window.quitting = true; window.close() })
        }
    }

    Shortcut{ sequences: [StandardKey.Open]; onActivated: window.openProjectDialog() }
    Shortcut{ sequences: [StandardKey.Save]; onActivated: window.saveProject(false) }
    Shortcut{ sequences: [StandardKey.SaveAs, "Ctrl+Shift+S"]; onActivated: window.saveProject(true) }
    Shortcut{ sequences: [StandardKey.Undo]; onActivated: window.undo() }
    Shortcut{ sequences: [StandardKey.Redo, "Ctrl+Shift+Z"]; onActivated: window.redo() }

    FileDialog{
        id: projectOpenDialog
        title: qsTr("Open project")
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Project (*.yaml *.yml *.xlsx)"), qsTr("Project YAML (*.yaml *.yml)"), qsTr("prjcfg spreadsheet (*.xlsx)")]
        onAccepted: window.openProject(selectedFile, false)
    }
    FileDialog{
        id: projectSaveDialog
        title: qsTr("Save project")
        fileMode: FileDialog.SaveFile
        defaultSuffix: "yaml"
        nameFilters: [qsTr("Project YAML (*.yaml *.yml)")]
        onAccepted: window.writeProject(selectedFile)
        onRejected: window.afterSave = null
    }
    MessageDialog{
        id: messageDialog
        title: qsTr("SenseTool")
        buttons: MessageDialog.Ok
    }
    MessageDialog{
        id: unsavedDialog
        property var proceed: null
        title: qsTr("Unsaved changes")
        text: qsTr("Save changes to %1?").arg(window.projectName !== "" ? window.projectName : qsTr("this project"))
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
        target: logic
        function onUpdateChecked(available, version, changelog, link) {
            if (available) {
                update_window.show()
            }
        }
    }

    Settings{
        id: appSettings
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
        property string lastProject: ""
    }

    Connections {
        target: updateManager
        function onProgressChanged(value) {
            update_window.progressBar.visible = true
            update_window.progressBar.value = value
            update_window.progressText.visible = true
            update_window.progressText.text = value + qsTr("% completed")
            if (value === 100) {
                update_window.restartDialog.open()
            }
        }
    }
}
