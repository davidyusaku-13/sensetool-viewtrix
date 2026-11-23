from PySide6.QtCore import Qt, QAbstractListModel, Slot, Signal, Property, QModelIndex, QUrl
from PySide6.QtQml import QmlElement
from ..modules.logger import AppLogger
from ..modules import appset
import os
import yaml

QML_IMPORT_NAME = "AppSetModel"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()

ROLES = ["name", "addr", "addrHex", "size", "category", "desc", "fields",
         "layout", "defaultValue", "issue"]
ROLE_IDS = {name: Qt.UserRole + 1 + i for i, name in enumerate(ROLES)}

YAML_DESC = ("Application Setting includes the dynamic settings which can be changed during runtime. "
             "appset.h and appset.c are generated from this file.")


def _clean(reg):
    """Normalise a register coming from QML or a file: every value is text."""
    s = appset._s
    return {
        "addr": s(reg.get("addr")),
        "name": s(reg.get("name")),
        "size": s(reg.get("size")) or "1",
        "category": s(reg.get("category")),
        "desc": s(reg.get("desc")),
        "fields": [{"name": s(f.get("name")), "msb": s(f.get("msb")), "lsb": s(f.get("lsb")),
                    "default": s(f.get("default"))} for f in (reg.get("fields") or [])],
    }


@QmlElement
class AppSetModel(QAbstractListModel):
    issueCountChanged = Signal()
    bytesUsedChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._regs = []
        self._info = []
        self._issue_count = 0

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
        count = sum(1 for i in self._info if i["issue"])
        if count != self._issue_count:
            self._issue_count = count
            self.issueCountChanged.emit()

    @Property(int, notify=issueCountChanged)
    def issueCount(self):
        return self._issue_count

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

    # ---- files --------------------------------------------------------
    @Slot(QUrl, result=str)
    def importFile(self, file: QUrl):
        """Import a .yaml/.yml application setting or the AppSet sheet of prjcfg.xlsx.
        Replaces the current table. Returns an error message, or "" on success."""
        path = file.toLocalFile()
        try:
            if path.lower().endswith((".xlsx", ".xlsm")):
                regs = appset.read_appset_xlsx(path)
            else:
                with open(path, "r", encoding="utf-8") as f:
                    data = yaml.safe_load(f)
                if not isinstance(data, dict) or not isinstance(data.get("registers"), list):
                    raise ValueError("expected a mapping with a 'registers' list")
                regs = data["registers"]
                for n, r in enumerate(regs, 1):
                    if not isinstance(r, dict) or "name" not in r or "addr" not in r:
                        raise ValueError(f"register {n} needs 'name' and 'addr'")
                    if not isinstance(r.get("fields") or [], list):
                        raise ValueError(f"register {n}: 'fields' must be a list")
        except Exception as e:  # file, YAML and openpyxl errors
            logger.log(f"Failed to import {path}: {e}", "ERROR")
            return f"Could not import {path}:\n{e}"
        self._set(regs)
        logger.log(f"Imported application setting: {path}", "INFO")
        return ""

    @Slot(QUrl, result=str)
    def exportYAML(self, file: QUrl):
        path = file.toLocalFile()

        def num(v):
            n = appset.to_int(v)
            return n if n is not None and str(n) == v else (v or None)

        data = {"title": "Application Settings", "desc": YAML_DESC, "size": appset.APPSET_SIZE,
                "registers": []}
        for r in self._regs:
            data["registers"].append({
                "addr": num(r["addr"]), "name": r["name"], "size": num(r["size"]),
                "category": r["category"] or None, "desc": r["desc"] or None,
                # defaults stay text so hex stays hex
                "fields": [{"name": f["name"], "msb": num(f["msb"]), "lsb": num(f["lsb"]),
                            "default": f["default"] or None} for f in r["fields"]],
            })
        try:
            with open(path, "w", encoding="utf-8") as f:
                yaml.dump(data, f, sort_keys=False, allow_unicode=True)
        except OSError as e:
            logger.log(f"Failed to export {path}: {e}", "ERROR")
            return f"Could not write {path}:\n{e}"
        logger.log(f"Exported application setting: {path}", "INFO")
        return ""

    @Slot(QUrl, result=str)
    def generate(self, folder: QUrl):
        """Write appset.h and appset.c into `folder`. Returns an error or ""."""
        if self._issue_count:
            return (f"{self._issue_count} register(s) have problems (shown in red). "
                    "Fix them before generating.")
        if not self._regs:
            return "There are no registers to generate."
        out_dir = folder.toLocalFile()
        try:
            for name, text in (("appset.h", appset.generate_header(self._regs)),
                               ("appset.c", appset.generate_source(self._regs))):
                with open(os.path.join(out_dir, name), "w", encoding="utf-8", newline="\n") as f:
                    f.write(text)
        except OSError as e:
            logger.log(f"Failed to generate appset in {out_dir}: {e}", "ERROR")
            return f"Could not write to {out_dir}:\n{e}"
        logger.log(f"Generated appset.c/.h in {out_dir}", "INFO")
        return ""
