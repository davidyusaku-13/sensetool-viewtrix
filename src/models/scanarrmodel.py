"""Scan Arrangement workspace: the ScanArrg sheet, generates afeScanArrg.c/.h.

State lives here (not in QML) so every rule is testable:
    items         scan items = the eAfeScanID_t enum, in value order
    arrangements  named scan sequences (eAfeScanArrgID_t)
    steps         the steps of the `current` arrangement (what the Scan List shows)
"""
import os
from PySide6.QtCore import Property, QObject, QUrl, Signal, Slot
from PySide6.QtQml import QmlElement
from ..modules import prjcfg, scanarr
from ..modules.cgen import is_identifier
from ..modules.fileio import UserError, local_path, message, write_text
from ..modules.logger import AppLogger
from .listmodel import DictListModel
from .workspace import export_file, import_file, logged

QML_IMPORT_NAME = "ScanArrModel"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()


def _clean(scan_items, arrangements):
    items = [{"name": str(i.get("name") or "").strip(), "desc": str(i.get("desc") or "")} for i in scan_items]
    arrs = [{"id": str(a.get("id", "")).strip(), "name": str(a.get("name") or "").strip(),
             "desc": str(a.get("desc") or ""), "scans": [str(x) for x in a.get("scans") or []]}
            for a in arrangements]
    return items, arrs


def _parse(data):
    """(items, arrangements, skipped) from parsed YAML / the sheet. Raises UserError."""
    if not isinstance(data, dict):
        raise UserError("expected a mapping with 'scan_items' and 'arrangements' lists")
    raw_items, raw_arrs = data.get("scan_items") or [], data.get("arrangements") or []
    if not isinstance(raw_items, list) or not isinstance(raw_arrs, list):
        raise UserError("'scan_items' and 'arrangements' must be lists")
    for kind, rows in (("scan item", raw_items), ("arrangement", raw_arrs)):
        for n, row in enumerate(rows, 1):
            if not isinstance(row, dict) or "name" not in row:
                raise UserError(f"{kind} {n} needs a 'name'")
    # Files written before arrangement IDs existed: number them in order.
    raw_arrs = [dict(a, id=a.get("id", n)) for n, a in enumerate(raw_arrs, 1)]
    items, arrs = _clean(raw_items, raw_arrs)
    return items, arrs, list(data.get("skipped") or [])


@QmlElement
class ScanArrModel(QObject):
    SECTION = "scanarr"
    changed = Signal()
    currentChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []        # [{name, desc}]
        self._arrs = []         # [{id, name, desc, scans: [name]}]
        self._skipped = []
        self._current = -1
        self._item_model = DictListModel(["name", "desc", "value"], self)
        self._arr_model = DictListModel(["arrId", "name", "desc", "stepCount"], self)
        self._step_model = DictListModel(["step", "name"], self)

    # ---- views ---------------------------------------------------------------
    def _item_rows(self):
        return [dict(i, value=n) for n, i in enumerate(self._items)]

    def _arr_rows(self):
        return [{"arrId": a["id"], "name": a["name"], "desc": a["desc"], "stepCount": len(a["scans"])}
                for a in self._arrs]

    def _step_rows(self):
        if not 0 <= self._current < len(self._arrs):
            return []
        return [{"step": n + 1, "name": s} for n, s in enumerate(self._arrs[self._current]["scans"])]

    def _refresh(self, steps_reset=False):
        """Push state to the three list models (row-level updates when sizes match)."""
        self._item_model.sync(self._item_rows())
        self._arr_model.sync(self._arr_rows())
        if steps_reset:
            self._step_model.reset(self._step_rows())
        else:
            self._step_model.sync(self._step_rows())
        self.changed.emit()

    @Property(QObject, constant=True)
    def items(self):
        return self._item_model

    @Property(QObject, constant=True)
    def arrangements(self):
        return self._arr_model

    @Property(QObject, constant=True)
    def steps(self):
        return self._step_model

    @Property(int, constant=True)
    def stepLimit(self):
        return scanarr.STEP_MAX

    @Property(int, notify=currentChanged)
    def current(self):
        return self._current

    @Property(str, notify=currentChanged)
    def currentName(self):
        return self._arrs[self._current]["name"] if 0 <= self._current < len(self._arrs) else ""

    @Slot(int)
    def setCurrent(self, i):
        i = i if 0 <= i < len(self._arrs) else -1
        if i != self._current:
            self._current = i
            self._step_model.reset(self._step_rows())
            self.currentChanged.emit()

    # ---- scan items ----------------------------------------------------------
    def _check_item_name(self, name, exclude=-1):
        if not is_identifier(name):
            raise UserError("A scan item name must be a C identifier, e.g. AFE_MS_ACTIVE.")
        if any(i["name"] == name for n, i in enumerate(self._items) if n != exclude):
            raise UserError(f"A scan item named {name} already exists.")

    @Slot(str, str, result=str)
    def addItem(self, name, desc):
        def run():
            self._check_item_name(name)
            self._items.append({"name": name, "desc": desc})
            self._item_model.insert(len(self._items) - 1, self._item_rows()[-1])
            self.changed.emit()
        return message(run)

    @Slot(int, str, str, result=str)
    def editItem(self, i, name, desc):
        """Edit a scan item; renaming it renames its steps in every arrangement."""
        def run():
            if not 0 <= i < len(self._items):
                raise UserError("No such scan item.")
            self._check_item_name(name, exclude=i)
            old = self._items[i]["name"]
            self._items[i] = {"name": name, "desc": desc}
            if old != name:
                for a in self._arrs:
                    a["scans"] = [name if s == old else s for s in a["scans"]]
            self._refresh()
        return message(run)

    @Slot(list)
    def removeItems(self, rows):
        for i in sorted({int(r) for r in rows}, reverse=True):
            if 0 <= i < len(self._items):
                del self._items[i]
                self._item_model.remove(i)
        self._refresh()

    @Slot(int, int, result=int)
    def moveItem(self, i, delta):
        """Move a scan item up/down (changes its enum value). Returns its new row."""
        j = i + delta
        if not (0 <= i < len(self._items) and 0 <= j < len(self._items)):
            return i
        self._items.insert(j, self._items.pop(i))
        self._item_model.move(i, j)
        self._refresh()  # values of the rows in between change
        return j

    # ---- arrangements --------------------------------------------------------
    def _check_arrangement(self, id_text, name, exclude=-1):
        if scanarr.parse_id(id_text) is None:
            raise UserError("The ID must be a positive whole number.")
        if not is_identifier(name):
            raise UserError("An arrangement name must be a C identifier, e.g. AFE_SCAN_ACTIVE.")
        for n, a in enumerate(self._arrs):
            if n != exclude and a["name"] == name:
                raise UserError(f"An arrangement named {name} already exists.")
            if n != exclude and scanarr.parse_id(a["id"]) == scanarr.parse_id(id_text):
                raise UserError(f"ID {id_text} is already used by {a['name']}.")

    @Slot(result=str)
    def nextArrangementId(self):
        ids = [scanarr.parse_id(a["id"]) or 0 for a in self._arrs]
        return str(max(ids + [0]) + 1)

    @Slot(str, str, str, result=str)
    def addArrangement(self, id_text, name, desc):
        """New arrangements start as just the terminator and become current."""
        def run():
            self._check_arrangement(id_text, name)
            self._arrs.append({"id": str(id_text).strip(), "name": name, "desc": desc, "scans": [scanarr.END]})
            self._arr_model.insert(len(self._arrs) - 1, self._arr_rows()[-1])
            self.changed.emit()
            self.setCurrent(len(self._arrs) - 1)
        return message(run)

    @Slot(int, str, str, str, result=str)
    def editArrangement(self, i, id_text, name, desc):
        """Change ID, name and description; the steps stay."""
        def run():
            if not 0 <= i < len(self._arrs):
                raise UserError("No such arrangement.")
            self._check_arrangement(id_text, name, exclude=i)
            self._arrs[i].update(id=str(id_text).strip(), name=name, desc=desc)
            self._refresh()
            if i == self._current:
                self.currentChanged.emit()
        return message(run)

    @Slot(list)
    def removeArrangements(self, rows):
        rows = sorted({int(r) for r in rows if 0 <= int(r) < len(self._arrs)}, reverse=True)
        if not rows:
            return
        current = self._arrs[self._current] if 0 <= self._current < len(self._arrs) else None
        for i in rows:
            del self._arrs[i]
            self._arr_model.remove(i)
        self._current = self._arrs.index(current) if current in self._arrs else -1
        self._refresh(steps_reset=True)
        self.currentChanged.emit()

    # ---- steps of the current arrangement ------------------------------------
    def _scans(self):
        return self._arrs[self._current]["scans"] if 0 <= self._current < len(self._arrs) else None

    @Slot(list, int, result=int)
    def insertSteps(self, names, after):
        """Insert after step `after`; with -1, just before the terminating AFE_END
        (or at the end if there is none). Returns how many were inserted."""
        scans = self._scans()
        if scans is None or not names:
            return 0
        if 0 <= after < len(scans):
            at = after + 1
        else:
            at = len(scans) - 1 if scans and scans[-1] == scanarr.END else len(scans)
        for k, name in enumerate(names):
            scans.insert(at + k, str(name))
            self._step_model.insert(at + k, {"step": at + k + 1, "name": str(name)})
        self._refresh()  # renumber the steps after them
        return len(names)

    @Slot(list)
    def removeSteps(self, rows):
        scans = self._scans()
        if scans is None:
            return
        for i in sorted({int(r) for r in rows}, reverse=True):
            if 0 <= i < len(scans):
                del scans[i]
                self._step_model.remove(i)
        self._refresh()

    @Slot(int, int, result=int)
    def moveStep(self, i, delta):
        scans = self._scans()
        j = i + delta
        if scans is None or not (0 <= i < len(scans) and 0 <= j < len(scans)):
            return -1 if scans is None else i
        scans.insert(j, scans.pop(i))
        self._step_model.move(i, j)
        self._refresh()
        return j

    # ---- checking, generating ------------------------------------------------
    @Slot(result=list)
    def check(self):
        """Problems that would make the generated C wrong; empty when it is safe."""
        return scanarr.analyze(self._items, self._arrs)

    @Slot(QUrl, result=str)
    def generate(self, folder):
        """Write afeScanArrg.h and afeScanArrg.c into `folder`."""
        def run():
            issues = self.check()
            if issues:
                raise UserError("Fix these problems first:\n\n" + "\n".join(issues))
            out_dir = local_path(folder)
            write_text(os.path.join(out_dir, "afeScanArrg.h"), scanarr.generate_header(self._items, self._arrs))
            write_text(os.path.join(out_dir, "afeScanArrg.c"), scanarr.generate_source(self._arrs))
            logger.log(f"Generated afeScanArrg.c/.h in {out_dir}", "INFO")
        return logged(message(run))

    # ---- workspace interface (files, project) --------------------------------
    def readSpreadsheet(self, path):
        return scanarr.read_scanarrg_xlsx(path)

    def loadData(self, data):
        """Replace everything from parsed data. "" or an error; nothing changes on error."""
        try:
            items, arrs, skipped = _parse(data)
        except UserError as e:
            return str(e)
        self._items, self._arrs, self._skipped = items, arrs, skipped
        self._current = -1
        self._item_model.reset(self._item_rows())
        self._arr_model.reset(self._arr_rows())
        self._step_model.reset([])
        self.currentChanged.emit()
        self.changed.emit()
        return ""

    def document(self):
        return prjcfg.scanarr_doc(self._items, self._arrs)

    @Slot(QUrl, result=str)
    def importFile(self, url):
        """Replace everything from a .yaml/.yml file or the ScanArrg sheet."""
        return logged(message(import_file, self, url))

    @Slot(result=list)
    def skippedRows(self):
        """Sheet rows the last import skipped (no name and no steps yet)."""
        return list(self._skipped)

    @Slot(QUrl, result=str)
    def exportYAML(self, url):
        return logged(message(export_file, self, url))
