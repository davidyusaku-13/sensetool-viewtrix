from PySide6.QtCore import Qt, Slot, Signal, Property, QModelIndex, QUrl
from PySide6.QtQml import QmlElement
from ..modules.logger import AppLogger
from ..modules import appset, prjcfg
from ..modules.fileio import UserError, local_path, message, write_text
from .workspace import WorkspaceListModel, logged
import os

QML_IMPORT_NAME = "AppSetModel"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()

ROLES = ["name", "addr", "addrHex", "size", "category", "desc", "fields",
         "layout", "defaultValue", "issue"]
ROLE_IDS = {name: Qt.UserRole + 1 + i for i, name in enumerate(ROLES)}

_clean = prjcfg.appset_clean


@QmlElement
class AppSetModel(WorkspaceListModel):
    """App Setting workspace: the AppSet sheet, generates appset.c/.h."""
    SECTION = "appset"
    bytesUsedChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._regs = []
        self._info = []

    def rowCount(self, parent=QModelIndex()):
        return len(self._regs)

    def roleNames(self):
        return {rid: name.encode() for name, rid in ROLE_IDS.items()}

    def data(self, index, role=Qt.DisplayRole):
        if not (0 <= index.row() < len(self._regs)):
            return None
        reg = self._regs[index.row()]
        info = self._info[index.row()] if index.row() < len(self._info) else {}
        name = ROLES[role - Qt.UserRole - 1] if Qt.UserRole < role <= Qt.UserRole + len(ROLES) else None
        if role == Qt.DisplayRole or name == "name":
            return reg["name"]
        if name == "addrHex":
            a = appset.to_int(reg["addr"])
            return f"0x{a:03X}" if a is not None else reg["addr"]
        if name == "layout":
            return info.get("layout", "")
        if name == "defaultValue":
            return info.get("default", "")
        if name == "issue":
            return info.get("issue", "")
        if name in reg:
            return reg[name]
        return None

    # ---- internals ----------------------------------------------------
    def _set(self, regs):
        """Replace everything, keeping the table sorted by address like a memory map."""
        def key(r):
            a = appset.to_int(r["addr"])
            return (a is None, a if a is not None else 0)
        self.beginResetModel()
        self._regs = sorted((_clean(r) for r in regs), key=key)
        self._info = appset.analyze(self._regs)
        self.endResetModel()
        self.bytesUsedChanged.emit()
        self._set_issue_count(sum(1 for i in self._info if i["issue"]))

    # ---- editing ------------------------------------------------------
    @Slot(int, result="QVariantMap")
    def get(self, index):
        if 0 <= index < len(self._regs):
            return dict(self._regs[index])
        return {}

    @Slot("QVariantMap", result=int)
    def addRegister(self, reg):
        """Returns the row the new register ended up at (rows are sorted by address)."""
        reg = _clean(reg)
        self._set(self._regs + [reg])
        logger.log(f"Added AppSet register {reg['name']} at {reg['addr']}", "INFO")
        return self._regs.index(reg) if reg in self._regs else -1

    @Slot(int, "QVariantMap", result=int)
    def editRegister(self, index, reg):
        if not 0 <= index < len(self._regs):
            logger.log(f"Attempt to edit AppSet register at invalid index {index}", "ERROR")
            return -1
        reg = _clean(reg)
        regs = list(self._regs)
        regs[index] = reg
        self._set(regs)
        logger.log(f"Edited AppSet register {reg['name']}", "INFO")
        return self._regs.index(reg) if reg in self._regs else -1

    @Slot(int)
    def removeItem(self, index):
        if 0 <= index < len(self._regs):
            logger.log(f"Deleted AppSet register {self._regs[index]['name']}", "INFO")
            self._set(self._regs[:index] + self._regs[index + 1:])

    @Slot(list)
    def removeItems(self, indexes):
        drop = {int(i) for i in indexes}
        self._set([r for i, r in enumerate(self._regs) if i not in drop])

    @Slot()
    def clear(self):
        self._set([])

    @Slot(str, int, result=int)
    def indexOfName(self, name, exclude=-1):
        for i, r in enumerate(self._regs):
            if i != exclude and r["name"].upper() == name.upper():
                return i
        return -1

    @Slot(result=list)
    def categories(self):
        seen = []
        for r in self._regs:
            if r["category"] and r["category"] not in seen:
                seen.append(r["category"])
        return seen

    @Slot(result=str)
    def nextFreeAddress(self):
        """First address after the last register, as text."""
        end = 0
        for r in self._regs:
            a, s = appset.to_int(r["addr"]), appset.to_int(r["size"])
            if a is not None and s is not None:
                end = max(end, a + s)
        return str(min(end, appset.APPSET_SIZE - 1))

    @Property(int, notify=bytesUsedChanged)
    def bytesUsed(self):
        return sum(appset.to_int(r["size"]) or 0 for r in self._regs)

    @Slot(result=int)
    def tableSize(self):
        return appset.APPSET_SIZE

    # ---- files (import/export come from WorkspaceListModel) -------------
    def readSpreadsheet(self, path):
        return {"registers": appset.read_appset_xlsx(path)}

    def loadData(self, data):
        """Replace the table from parsed YAML. Returns an error, or "" on success."""
        data = prjcfg.section(data, "appset")
        if not isinstance(data, dict) or not isinstance(data.get("registers"), list):
            return "expected a mapping with a 'registers' list"
        for n, r in enumerate(data["registers"], 1):
            if not isinstance(r, dict) or "name" not in r or "addr" not in r:
                return f"register {n} needs 'name' and 'addr'"
            if not isinstance(r.get("fields") or [], list):
                return f"register {n}: 'fields' must be a list"
        self._set(data["registers"])
        return ""

    def document(self):
        return prjcfg.appset_doc(self._regs)

    @Slot(int, "QVariantMap", result=str)
    def checkRegister(self, index, reg):
        """Problems `reg` would have if saved at row `index` (-1 = new), for live
        feedback in the edit window."""
        regs = [dict(r) for r in self._regs]
        reg = _clean(reg)
        if 0 <= index < len(regs):
            regs[index] = reg
        else:
            regs.append(reg)
            index = len(regs) - 1
        return appset.analyze(regs)[index]["issue"]

    @Slot(QUrl, result=str)
    def generate(self, folder: QUrl):
        """Write appset.h and appset.c into `folder`. Returns an error or ""."""
        def run():
            if self._issue_count:
                raise UserError(f"{self._issue_count} register(s) have problems (shown in red). "
                                "Fix them before generating.")
            if not self._regs:
                raise UserError("There are no registers to generate.")
            out_dir = local_path(folder)
            write_text(os.path.join(out_dir, "appset.h"), appset.generate_header(self._regs))
            write_text(os.path.join(out_dir, "appset.c"), appset.generate_source(self._regs))
            logger.log(f"Generated appset.c/.h in {out_dir}", "INFO")
        return logged(message(run))
