"""What every workspace (Project Setting, App Setting, Scan Arrangement) has in
common, so the project file, import/export and change tracking are written once.

A workspace provides:
    SECTION          its key in prjcfg.yaml
    loadData(data)   replace its contents from parsed YAML; "" or an error
    document()       its contents as a YAML-ready dict
    changed          signal emitted on every edit (drives undo / unsaved tracking)
and optionally readSpreadsheet(path) -> data, for importing prjcfg.xlsx.
"""
from PySide6.QtCore import QAbstractListModel, Property, QUrl, Signal, Slot
from ..modules import prjcfg
from ..modules.fileio import UserError, local_path, message, read_yaml, write_yaml
from ..modules.logger import AppLogger

logger = AppLogger.get_instance()

SPREADSHEET = (".xlsx", ".xlsm")


def import_file(workspace, url):
    """Replace a workspace from a YAML file (its own or a combined prjcfg.yaml) or
    the spreadsheet. Raises UserError; nothing changes on failure."""
    path = local_path(url)
    if path.lower().endswith(SPREADSHEET):
        try:
            data = workspace.readSpreadsheet(path)
        except UserError:
            raise
        except Exception as e:  # openpyxl raises many exception types
            raise UserError(f"Could not import {path}:\n{e}") from e
    else:
        data = read_yaml(path)
    err = workspace.loadData(prjcfg.section(data, workspace.SECTION))
    if err:
        raise UserError(f"Could not import {path}:\n{err}")
    logger.log(f"Imported {workspace.SECTION} from {path}", "INFO")


def export_file(workspace, url):
    write_yaml(local_path(url), workspace.document())
    logger.log(f"Exported {workspace.SECTION} to {local_path(url)}", "INFO")


def logged(text):
    if text:
        logger.log(text, "ERROR")
    return text


class WorkspaceListModel(QAbstractListModel):
    """Base for workspaces that are a single table (Project Setting, App Setting)."""
    SECTION = ""
    issueCountChanged = Signal()
    changed = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._issue_count = 0
        for sig in (self.modelReset, self.rowsInserted, self.rowsRemoved, self.rowsMoved, self.dataChanged):
            sig.connect(self._announce)

    def _announce(self, *args):
        self.changed.emit()

    def _set_issue_count(self, count):
        if count != self._issue_count:
            self._issue_count = count
            self.issueCountChanged.emit()

    @Property(int, notify=issueCountChanged)
    def issueCount(self):
        return self._issue_count

    @Slot(QUrl, result=str)
    def importFile(self, url):
        """Replace the table from a .yaml/.yml file or prjcfg.xlsx. "" or an error."""
        return logged(message(import_file, self, url))

    @Slot(QUrl, result=str)
    def exportYAML(self, url):
        return logged(message(export_file, self, url))

    # subclasses implement these
    def loadData(self, data):
        raise NotImplementedError

    def document(self):
        raise NotImplementedError

    def readSpreadsheet(self, path):
        raise UserError(f"{path}: this workspace can't be imported from a spreadsheet")
