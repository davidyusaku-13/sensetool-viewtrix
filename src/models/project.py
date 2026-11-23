"""The project: one prjcfg.yaml holding every workspace.

ProjectController owns opening/saving, unsaved-change tracking and undo/redo
across all workspaces. Workspaces register with addWorkspace() and only need
the small interface described in workspace.py, so adding one is a one-liner.
"""
import os
import yaml
from PySide6.QtCore import Property, QObject, QSettings, QTimer, QUrl, Signal, Slot
from PySide6.QtQml import QmlElement
from ..modules import prjcfg
from ..modules.fileio import UserError, dump_yaml, local_path, read_yaml, write_text
from ..modules.logger import AppLogger
from .workspace import SPREADSHEET

QML_IMPORT_NAME = "ProjectController"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()

LAST_PROJECT_KEY = "lastProject"
UNDO_LIMIT = 100
TRACK_DELAY_MS = 300   # edits within this time become one undo step


@QmlElement
class ProjectController(QObject):
    stateChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._workspaces = []
        self._url = QUrl()
        self._meta = {}          # title / desc / revisions of the opened file
        self._saved = ""         # project text as last opened/saved
        self._current = ""       # project text now (as of the last track())
        self._undo, self._redo = [], []
        self._skipped = []
        self._restoring = False
        self._timer = QTimer(self)
        self._timer.setSingleShot(True)
        self._timer.setInterval(TRACK_DELAY_MS)
        self._timer.timeout.connect(self.track)

    # ---- setup ---------------------------------------------------------------
    @Slot(QObject)
    def addWorkspace(self, workspace):
        self._workspaces.append(workspace)
        workspace.changed.connect(self._schedule)
        self._current = self._saved = self._text()

    def _schedule(self):
        if not self._restoring:
            self._timer.start()

    # ---- state ---------------------------------------------------------------
    @Property(str, notify=stateChanged)
    def path(self):
        return local_path(self._url) if not self._url.isEmpty() else ""

    @Property(str, notify=stateChanged)
    def name(self):
        return self._url.fileName() if not self._url.isEmpty() else ""

    @Property(bool, notify=stateChanged)
    def hasPath(self):
        return not self._url.isEmpty()

    @Property(bool, notify=stateChanged)
    def dirty(self):
        return self._current != self._saved

    @Property(bool, notify=stateChanged)
    def canUndo(self):
        return bool(self._undo)

    @Property(bool, notify=stateChanged)
    def canRedo(self):
        return bool(self._redo)

    @Slot(result=list)
    def lastSkipped(self):
        """Spreadsheet rows the last open skipped (Scan Arrangement rows without a name)."""
        return list(self._skipped)

    # ---- the project as text (for unsaved checks and undo) ------------------
    def _document(self):
        doc = {"title": "Project Configuration", "desc": prjcfg.DESC}
        doc.update(self._meta)
        for w in self._workspaces:
            doc[w.SECTION] = w.document()
        return doc

    def _text(self):
        return dump_yaml(self._document())

    def _load(self, doc):
        """Load every section; on any error put everything back and raise."""
        before = self._text()
        self._restoring = True
        try:
            for w in self._workspaces:
                err = w.loadData(doc[w.SECTION])
                if err:
                    self._load_unchecked(yaml.safe_load(before))
                    raise UserError(f"{w.SECTION}: {err}")
        finally:
            self._restoring = False
            self._timer.stop()

    def _load_unchecked(self, doc):
        for w in self._workspaces:
            w.loadData(doc[w.SECTION])

    # ---- tracking ------------------------------------------------------------
    @Slot()
    def track(self):
        """Record changes since the last call as one undo step."""
        text = self._text()
        if text == self._current:
            return
        self._undo = (self._undo + [self._current])[-UNDO_LIMIT:]
        self._redo = []
        self._current = text
        self.stateChanged.emit()

    @Slot()
    def flush(self):
        """Record pending edits now (before undo/save, and in tests)."""
        self._timer.stop()
        self.track()

    def _restore(self, text):
        self._load(yaml.safe_load(text))
        self._current = text

    @Slot()
    def undo(self):
        self.flush()
        if not self._undo:
            return
        text = self._undo.pop()
        self._redo.append(self._current)
        self._restore(text)
        self.stateChanged.emit()

    @Slot()
    def redo(self):
        self.flush()
        if not self._redo:
            return
        text = self._redo.pop()
        self._undo.append(self._current)
        self._restore(text)
        self.stateChanged.emit()

    # ---- files ---------------------------------------------------------------
    @Slot(QUrl, result=str)
    def open(self, url):
        """Open a prjcfg.yaml, or import prjcfg.xlsx (which then needs Save As).
        Returns "" or an error; on error nothing changes."""
        path = local_path(url)
        is_sheet = path.lower().endswith(SPREADSHEET)
        try:
            if is_sheet:
                try:
                    doc, skipped = prjcfg.from_xlsx(path)
                except Exception as e:  # openpyxl raises many exception types
                    raise UserError(f"Could not open {path}:\n{e}") from e
            else:
                doc, skipped = read_yaml(path), []
            missing = [w.SECTION for w in self._workspaces if not isinstance(doc.get(w.SECTION), dict)]
            if missing:
                raise UserError(f"{path} is not a project file (missing {', '.join(missing)}).\n"
                                "Use Import on a workspace page to load a single-workspace file.")
            self._load(doc)
        except UserError as e:
            msg = str(e) if str(e).startswith("Could not open") else f"Could not open {path}:\n{e}"
            logger.log(msg, "ERROR")
            return msg
        self._meta = {k: doc[k] for k in ("title", "desc", "revisions") if k in doc}
        self._skipped = skipped
        self._url = QUrl() if is_sheet else QUrl(url)
        self._current = self._text()
        self._saved = "" if is_sheet else self._current  # an imported sheet is unsaved
        self._undo, self._redo = [], []
        if not is_sheet:
            QSettings().setValue(LAST_PROJECT_KEY, self._url.toString())
        logger.log(f"Opened project {path}", "INFO")
        self.stateChanged.emit()
        return ""

    @Slot(result=bool)
    def openLast(self):
        """Reopen the project used last time. False if there is none (or it is gone)."""
        last = QSettings().value(LAST_PROJECT_KEY, "")
        if not last:
            return False
        url = QUrl(str(last))
        if not os.path.isfile(local_path(url)):
            return False
        return self.open(url) == ""

    @Slot(result=str)
    def save(self):
        if self._url.isEmpty():
            return "This project has no file yet; use Save As."
        return self.saveAs(self._url)

    @Slot(QUrl, result=str)
    def saveAs(self, url):
        self.flush()
        try:
            write_text(local_path(url), self._current)
        except UserError as e:
            logger.log(str(e), "ERROR")
            return str(e)
        self._url = QUrl(url)
        self._saved = self._current
        QSettings().setValue(LAST_PROJECT_KEY, self._url.toString())
        logger.log(f"Saved project {local_path(url)}", "INFO")
        self.stateChanged.emit()
        return ""
