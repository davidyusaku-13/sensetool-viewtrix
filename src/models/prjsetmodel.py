from PySide6.QtCore import Qt, Slot, Signal, Property, QModelIndex, QObject, QUrl
from PySide6.QtQml import QmlElement
from ..modules.logger import AppLogger
from ..modules import prjset, prjcfg
from ..modules.fileio import UserError, local_path, message, write_text
from .prjsetmodelitem import PrjSetModelItem
from .workspace import WorkspaceListModel, logged

QML_IMPORT_NAME = "PrjSetModel"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()

NAME_ROLE = Qt.DisplayRole
VALUE_ROLE = Qt.UserRole + 1
DESC_ROLE = Qt.UserRole + 2
GROUP_ROLE = Qt.UserRole + 3
COMMENT_ROLE = Qt.UserRole + 4
RESOLVED_ROLE = Qt.UserRole + 5
ISSUE_ROLE = Qt.UserRole + 6
DEPENDENT_ROLE = Qt.UserRole + 7

@QmlElement
class PrjSetModel(WorkspaceListModel):
    """Project Setting workspace: the PrjSet sheet, generates prjset.h."""
    SECTION = "prjset"
    # its own signal: a Property notifying through a base-class signal crashes QML registration
    rootIssueCountChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []
        self._analysis = []
        self._root_issue_count = 0

    # ---- model basics -------------------------------------------------
    def rowCount(self, parent=QModelIndex()):
        return len(self._items)

    def data(self, index, role=Qt.DisplayRole):
        if not (0 <= index.row() < len(self._items)):
            return None
        row = self._items[index.row()]
        if role == NAME_ROLE:
            return row.name
        if role == VALUE_ROLE:
            return row.value
        if role == DESC_ROLE:
            return row.desc
        if role == GROUP_ROLE:
            return row.group
        if role == COMMENT_ROLE:
            return row.comment
        if role in (RESOLVED_ROLE, ISSUE_ROLE):
            info = self._analysis[index.row()] if index.row() < len(self._analysis) else {}
            return info.get("resolved" if role == RESOLVED_ROLE else "issue", "")
        if role == DEPENDENT_ROLE:
            info = self._analysis[index.row()] if index.row() < len(self._analysis) else {}
            return bool(info.get("dependent"))
        return None

    def roleNames(self):
        roles = super().roleNames()
        roles.update({
            NAME_ROLE: b"name",
            VALUE_ROLE: b"value",
            DESC_ROLE: b"desc",
            GROUP_ROLE: b"group",
            COMMENT_ROLE: b"comment",
            RESOLVED_ROLE: b"resolved",
            ISSUE_ROLE: b"issue",
            DEPENDENT_ROLE: b"dependent",
        })
        return roles

    def flags(self, index):
        flag = super().flags(index)
        if index.isValid():
            flag |= Qt.ItemIsDragEnabled
        return flag | Qt.ItemIsDropEnabled

    def _refresh(self):
        """Re-run validation/evaluation; every item can depend on any other."""
        self._analysis = prjset.analyze([(i.name, i.value) for i in self._items])
        if self._items:
            self.dataChanged.emit(self.index(0, 0), self.index(len(self._items) - 1, 0),
                                  [RESOLVED_ROLE, ISSUE_ROLE, DEPENDENT_ROLE])
        count = sum(1 for a in self._analysis if a["issue"])
        roots = sum(1 for a in self._analysis if a["issue"] and not a["dependent"])
        self._set_issue_count(count)
        if roots != self._root_issue_count:
            self._root_issue_count = roots
            self.rootIssueCountChanged.emit()

    @Property(int, notify=rootIssueCountChanged)
    def rootIssueCount(self):
        """Items whose own value is wrong (the rest only depend on one of these)."""
        return self._root_issue_count

    # ---- moving -------------------------------------------------------
    @Slot(int, int, result=bool)
    def move(self, source: int, target: int):
        """Move the row at `source` so that it ends up at `target`. The moved
        row joins the section (group) of the row it was dropped on."""
        n = len(self._items)
        if source == target or not (0 <= source < n and 0 <= target < n):
            return False
        target_group = self._items[target].group
        dest = target + 1 if target > source else target
        if not self.moveRows(QModelIndex(), source, 1, QModelIndex(), dest):
            return False
        item = self._items[target]
        if item._group != target_group:
            item._group = target_group
            self.dataChanged.emit(self.index(target, 0), self.index(target, 0), [GROUP_ROLE])
        return True

    def moveRows(self, sourceParent, sourceRow, count, destinationParent, destinationChild):
        """Qt semantics: move `count` rows starting at `sourceRow` so they are
        inserted before the row that is currently at `destinationChild`."""
        n = len(self._items)
        if count < 1 or sourceRow < 0 or sourceRow + count > n:
            return False
        if destinationChild < 0 or destinationChild > n:
            return False
        if sourceRow <= destinationChild <= sourceRow + count:
            return False  # would not change anything
        if not self.beginMoveRows(QModelIndex(), sourceRow, sourceRow + count - 1,
                                  QModelIndex(), destinationChild):
            return False
        block = self._items[sourceRow:sourceRow + count]
        del self._items[sourceRow:sourceRow + count]
        insert_at = destinationChild if destinationChild < sourceRow else destinationChild - count
        self._items[insert_at:insert_at] = block
        self.endMoveRows()
        self._refresh()
        return True

    # ---- CRUD ---------------------------------------------------------
    @Slot(int, result=QObject)
    def get(self, index):
        if 0 <= index < len(self._items):
            return self._items[index]
        logger.log(f"Attempt to access item at invalid index {index}", "WARNING")
        return None

    @Slot(str, result=int)
    def indexOfName(self, name):
        for i, item in enumerate(self._items):
            if item.name == name:
                return i
        return -1

    @Slot(result=list)
    def groups(self):
        seen = []
        for item in self._items:
            if item.group and item.group not in seen:
                seen.append(item.group)
        return seen

    @Slot(str, str, str, str, str)
    def addItem(self, name, value, desc, group="", comment=""):
        logger.log(f"Added item: {name} - {value} - {desc}", "INFO")
        # Keep sections contiguous: insert after the last item of the same group.
        row = len(self._items)
        if group:
            for i in range(len(self._items) - 1, -1, -1):
                if self._items[i].group == group:
                    row = i + 1
                    break
        self.beginInsertRows(QModelIndex(), row, row)
        self._items.insert(row, PrjSetModelItem(name, value, desc, self, group, comment))
        self.endInsertRows()
        self._refresh()

    @Slot(int, str, str, str, str, str)
    def edit(self, index, name, value, desc, group=None, comment=None):
        logger.log(f"Edited item at index {index}: {name} - {value} - {desc}", "INFO")
        if not (0 <= index < len(self._items)):
            logger.log(f"Attempt to edit item at invalid index {index}", "ERROR")
            return
        item = self._items[index]
        item._name, item._value, item._desc = name, value, desc
        if group is not None:
            item._group = group
        if comment is not None:
            item._comment = comment
        self.dataChanged.emit(self.index(index, 0), self.index(index, 0))
        self._refresh()

    @Slot(int)
    def removeItem(self, index):
        if 0 <= index < len(self._items):
            self.beginRemoveRows(QModelIndex(), index, index)
            logger.log(f"Deleted item at index {index}", "INFO")
            del self._items[index]
            self.endRemoveRows()
            self._refresh()

    @Slot()
    def clear(self):
        self._set_items([])

    def _set_items(self, dicts):
        self.beginResetModel()
        self._items = [PrjSetModelItem(d.get("name"), d.get("value"), d.get("desc"), self,
                                       d.get("group"), d.get("comment")) for d in dicts]
        self._analysis = []
        self.endResetModel()
        self._refresh()

    # ---- files (import/export come from WorkspaceListModel) -------------
    def loadData(self, data):
        """Replace the list from parsed YAML (a project-setting file or a combined
        prjcfg.yaml). Returns an error message, or "" on success."""
        data = prjcfg.section(data, "prjset")
        if not isinstance(data, dict) or not isinstance(data.get("data"), list):
            return "expected a mapping with a 'data' list"
        for n, entry in enumerate(data["data"], 1):
            if not isinstance(entry, dict) or "name" not in entry or "value" not in entry:
                return f"entry {n} needs 'name' and 'value'"
        self._set_items(data["data"])
        return ""

    def document(self):
        return prjcfg.prjset_doc([i.to_dict() for i in self._items])

    def readSpreadsheet(self, path):
        return {"data": prjset.read_prjcfg_xlsx(path)}

    @Slot(QUrl, result=str)
    def exportHeader(self, file: QUrl):
        """Write prjset.h. Refuses while there are validation issues, since
        the header would not compile (or would silently be wrong)."""
        def run():
            if self._issue_count:
                raise UserError(f"{self._issue_count} item(s) have problems (shown in red). "
                                "Fix them before generating the header.")
            try:
                text = prjset.generate_header([i.to_dict() for i in self._items])
            except prjset.ExprError as e:
                raise UserError(f"Could not generate prjset.h:\n{e}") from e
            write_text(local_path(file), text)
            logger.log(f"Exported header: {local_path(file)}", "INFO")
        return logged(message(run))
