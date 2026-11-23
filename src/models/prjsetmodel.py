from PySide6.QtCore import Qt, QAbstractListModel, Slot, Signal, Property, QModelIndex, QObject, QUrl
from PySide6.QtQml import QmlElement
from ..modules.logger import AppLogger
from ..modules import prjset, prjcfg
from .prjsetmodelitem import PrjSetModelItem
import yaml

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

@QmlElement
class PrjSetModel(QAbstractListModel):
    issueCountChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []
        self._analysis = []
        self._issue_count = 0

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
        })
        return roles

    def flags(self, index):
        flag = super().flags(index)
        if index.isValid():
            flag |= Qt.ItemIsDragEnabled
        return flag | Qt.ItemIsDropEnabled

    @property
    def itemsData(self):
        return [(item.name, item.value, item.desc) for item in self._items]

    def _refresh(self):
        """Re-run validation/evaluation; every item can depend on any other."""
        self._analysis = prjset.analyze([(i.name, i.value) for i in self._items])
        if self._items:
            self.dataChanged.emit(self.index(0, 0), self.index(len(self._items) - 1, 0),
                                  [RESOLVED_ROLE, ISSUE_ROLE])
        count = sum(1 for a in self._analysis if a["issue"])
        if count != self._issue_count:
            self._issue_count = count
            self.issueCountChanged.emit()

    @Property(int, notify=issueCountChanged)
    def issueCount(self):
        return self._issue_count

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

    # ---- files --------------------------------------------------------
    @Slot(QUrl, result=str)
    def importFile(self, file: QUrl):
        """Import a .yaml/.yml project setting or the legacy prjcfg .xlsx.
        Replaces the current list. Returns an error message, or "" on success."""
        path = file.toLocalFile()
        if path.lower().endswith((".xlsx", ".xlsm")):
            return self.importXLSX(file)
        return self.importYAML(file)

    @Slot(QUrl, result=str)
    def importYAML(self, file: QUrl):
        path = file.toLocalFile()
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = prjcfg.section(yaml.safe_load(f), "prjset")
            if not isinstance(data, dict) or not isinstance(data.get("data"), list):
                raise ValueError("expected a mapping with a 'data' list")
            items = []
            for n, entry in enumerate(data["data"], 1):
                if not isinstance(entry, dict) or "name" not in entry or "value" not in entry:
                    raise ValueError(f"entry {n} needs 'name' and 'value'")
                items.append(entry)
        except (OSError, yaml.YAMLError, ValueError) as e:
            logger.log(f"Failed to import {path}: {e}", "ERROR")
            return f"Could not import {path}:\n{e}"
        self._set_items(items)
        logger.log(f"Imported file: {path}", "INFO")
        return ""

    @Slot(QUrl, result=str)
    def importXLSX(self, file: QUrl):
        path = file.toLocalFile()
        try:
            items = prjset.read_prjcfg_xlsx(path)
        except Exception as e:  # openpyxl raises a variety of exception types
            logger.log(f"Failed to import {path}: {e}", "ERROR")
            return f"Could not import {path}:\n{e}"
        self._set_items(items)
        logger.log(f"Imported spreadsheet: {path}", "INFO")
        return ""

    @Slot(QUrl, result=str)
    def exportYAML(self, file: QUrl):
        path = file.toLocalFile()
        yaml_data = prjcfg.prjset_doc([i.to_dict() for i in self._items])
        try:
            with open(path, "w", encoding="utf-8") as f:
                prjcfg.dump(yaml_data, f)
        except OSError as e:
            logger.log(f"Failed to export {path}: {e}", "ERROR")
            return f"Could not write {path}:\n{e}"
        logger.log(f"Exported file: {path}", "INFO")
        return ""

    @Slot(QUrl, result=str)
    def exportHeader(self, file: QUrl):
        """Write prjset.h. Refuses while there are validation issues, since
        the header would not compile (or would silently be wrong)."""
        path = file.toLocalFile()
        if self._issue_count:
            return (f"{self._issue_count} item(s) have problems (shown in red). "
                    "Fix them before generating the header.")
        try:
            text = prjset.generate_header([i.to_dict() for i in self._items])
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                f.write(text)
        except (OSError, prjset.ExprError) as e:
            logger.log(f"Failed to export {path}: {e}", "ERROR")
            return f"Could not write {path}:\n{e}"
        logger.log(f"Exported header: {path}", "INFO")
        return ""
