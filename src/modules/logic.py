from PySide6.QtCore import Signal, Slot, QObject, QUrl, Property, QThread
from PySide6.QtQml import QmlElement
import yaml, math, requests, os, re
from src.modules.logger import AppLogger
from src.modules import scanarr

# Init LOGGER
logger = AppLogger.get_instance()

QML_IMPORT_NAME = "AppLogic"
QML_IMPORT_MAJOR_VERSION = 1

RELEASE_URL = "https://api.github.com/repos/davidyusaku-13/sensetool-viewtrix/releases/latest"


def parse_version(text):
    """'v1.2.10-beta.3+4' -> (1, 2, 10). Pre-release/build metadata is ignored."""
    core = re.split(r"[-+]", (text or "").strip().lstrip("vV"), maxsplit=1)[0]
    parts = re.findall(r"\d+", core)
    return tuple(int(p) for p in parts)


def is_newer(latest, current):
    lv, cv = parse_version(latest), parse_version(current)
    if not lv or not cv:
        return False  # unknown version (e.g. a dev build): don't nag
    width = max(len(lv), len(cv))
    return lv + (0,) * (width - len(lv)) > cv + (0,) * (width - len(cv))


def fetch_update_info(current_version, timeout=5):
    result = {"status": False, "version": "", "changelog": "", "link": ""}
    try:
        response = requests.get(RELEASE_URL, timeout=timeout)
        response.raise_for_status()
        release = response.json()
        latest = release.get("tag_name", "")
        result["version"] = latest
        if is_newer(latest, current_version):
            assets = release.get("assets") or []
            result.update(status=True,
                          changelog=release.get("body") or "",
                          link=assets[0]["browser_download_url"] if assets else release.get("zipball_url", ""))
    except (requests.RequestException, ValueError, KeyError, IndexError, TypeError) as e:
        logger.log(f"Failed to fetch the latest release information: {e}", "ERROR")
    return result


class _UpdateCheckThread(QThread):
    done = Signal(dict)

    def __init__(self, current_version, parent=None):
        super().__init__(parent)
        self._current = current_version

    def run(self):
        self.done.emit(fetch_update_info(self._current))


@QmlElement
class AppLogic(QObject):
    parentChanged = Signal(QObject)
    updateChecked = Signal(bool, str, str, str)  # available, version, changelog, link

    def __init__(self):
        super().__init__()
        self._last_error = ""
        self._update_link = ""
        self._update_thread = None

    @Property(QObject)
    def parent(self) -> QObject:
        return super().parent()

    @parent.setter
    def parent(self, parent: QObject):
        super().setParent(parent)
        self.parentChanged.emit(parent)

    @Slot(result=str)
    def lastError(self):
        """Message describing why the last import returned an empty result."""
        return self._last_error

    def _fail(self, msg, default):
        self._last_error = msg
        logger.log(msg, "ERROR")
        return default

    # ---- updates ------------------------------------------------------
    @Slot(result=dict)
    def checkUpdate(self):
        """Blocking check (kept for scripts/tests). The UI uses checkUpdateAsync."""
        info = fetch_update_info(self.getVersion())
        self._update_link = info["link"]
        return info

    @Slot()
    def checkUpdateAsync(self):
        if self._update_thread and self._update_thread.isRunning():
            return
        self._update_thread = _UpdateCheckThread(self.getVersion(), self)
        self._update_thread.done.connect(self._on_update_checked)
        self._update_thread.start()

    def _on_update_checked(self, info):
        self._update_link = info["link"]
        self.updateChecked.emit(info["status"], info["version"], info["changelog"], info["link"])

    @Slot(result=str)
    def updateLink(self):
        return self._update_link

    @Slot(result=str)
    def getVersion(self):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        versionpath = os.path.join(script_dir, '../../VERSION.txt')
        try:
            with open(versionpath, 'r') as f:
                return f.read().strip()
        except OSError:
            return ""

    @Slot(list, result=list)
    def divideArray(self, array):
        evenArray = [array[i] for i in range(len(array)) if i % 2 == 0]
        oddArray = [array[i] for i in range(len(array)) if i % 2 != 0]
        return [evenArray, oddArray]

    # ---- window coefficients -----------------------------------------
    @Slot(int, float, str, result=list)
    def win_coef_gen(self, win_sample_number, win_a0, win_length):
        Win_step = 1
        Sample_Number = win_sample_number
        if Sample_Number < 2:
            return []  # the formula divides by (Sample_Number - 1)
        Win_N = Sample_Number // Win_step
        a0 = win_a0
        a1 = 1 - a0
        Window_arr = []
        for i in range(1, Win_N + 1):
            val = a0 - a1 * math.cos(2 * math.pi * (i - 1) /
                                     (Sample_Number / Win_step - 1))
            Window_arr.append(round(val * 256))
        if (win_length == "Half"):
            return Window_arr[:len(Window_arr)//2]
        else:
            return Window_arr

    @Slot(QUrl, list, int, float, str, result=str)
    def exportWinCoef(self, fname, y, win_sample_number, win_a0, win_coef_length):
        file_name = fname.toLocalFile()
        yaml_data = {
            'sample_number': win_sample_number,
            'a0': win_a0,
            'coef_length': win_coef_length,
            'data': [{'y': v} for v in y]
        }
        return self._write_yaml(file_name, yaml_data, "win coef")

    @Slot(QUrl, result=list)
    def importWinCoef(self, fname):
        """Returns [data, sample_number, a0, coef_length], or [] on failure (see lastError)."""
        file_name = fname.toLocalFile()
        data = self._read_yaml(file_name)
        if data is None:
            return []
        try:
            arr = [item['y'] for item in data['data']]
            result = [arr, data['sample_number'], data['a0'], data['coef_length']]
        except (KeyError, TypeError):
            return self._fail(f"{file_name}: expected keys sample_number, a0, coef_length and a 'data' list of 'y' values", [])
        logger.log(f"Imported win coef {file_name}", "INFO")
        return result

    # ---- demodulator coefficients ------------------------------------
    @Slot(int, int, int, int, result=list)
    def demo_coef_gen(self, demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq):
        I_Coef = []
        Q_Coef = []
        N = demo_num_step * 4
        if N == 0:
            return [I_Coef, Q_Coef]
        Cycle = demo_cycle
        for i in range(1, demo_sample_number+1):
            I_Coef.append(round(math.sin(2*math.pi*Cycle*(i-1)/N)*0.5*256))
            Q_Coef.append(round(math.cos(2*math.pi*Cycle*(i-1)/N)*0.5*256))
        return [I_Coef, Q_Coef]

    @Slot(QUrl, list, int, int, int, int, result=str)
    def exportDemoCoef(self, fname, y, demo_step, demo_sample, demo_cycle, demo_adc):
        y_sin, y_cos = y
        file_name = fname.toLocalFile()
        yaml_data = {
            'step': demo_step,
            'sample': demo_sample,
            'cycle': demo_cycle,
            'adc_freq': demo_adc,
            'i_coef': [{'y_sin': v} for v in y_sin],
            'q_coef': [{'y_cos': v} for v in y_cos]
        }
        return self._write_yaml(file_name, yaml_data, "demo coef")

    @Slot(QUrl, result=list)
    def importDemoCoef(self, fname):
        """Returns [[sin, cos], step, sample, cycle, adc_freq], or [] on failure (see lastError)."""
        file_name = fname.toLocalFile()
        data = self._read_yaml(file_name)
        if data is None:
            return []
        try:
            sinArr = [item['y_sin'] for item in data['i_coef']]
            cosArr = [item['y_cos'] for item in data['q_coef']]
            result = [[sinArr, cosArr], data['step'], data['sample'], data['cycle'], data['adc_freq']]
        except (KeyError, TypeError):
            return self._fail(f"{file_name}: expected keys step, sample, cycle, adc_freq, i_coef and q_coef", [])
        logger.log(f"Imported demo coef {file_name}", "INFO")
        return result

    # ---- scan arrangement --------------------------------------------
    @staticmethod
    def _clean_scan_arr(scan_items, arrangements):
        items = [{'name': str(i.get('name') or '').strip(), 'desc': str(i.get('desc') or '')}
                 for i in scan_items]
        arrs = [{'id': str(a.get('id', '')).strip(), 'name': str(a.get('name') or '').strip(),
                 'desc': str(a.get('desc') or ''), 'scans': [str(x) for x in a.get('scans') or []]}
                for a in arrangements]
        return items, arrs

    @Slot(QUrl, list, list, result=str)
    def exportScanArr(self, fname, scan_items, arrangements):
        """scan_items: [{name, desc}] in enum order,
        arrangements: [{id, name, desc, scans: [name]}]."""
        file_name = fname.toLocalFile()
        items, arrs = self._clean_scan_arr(scan_items, arrangements)
        yaml_data = {
            'title': 'Scan Arrangement',
            'desc': "Scan items are the eAfeScanID_t enum in value order (the first is 0). "
                    "afeScanArrg.c and afeScanArrg.h are generated from this file.",
            'scan_items': [{'name': i['name'], 'desc': i['desc'] or None} for i in items],
            'arrangements': [{'id': scanarr.parse_id(a['id']) if scanarr.parse_id(a['id']) is not None else a['id'],
                              'name': a['name'], 'desc': a['desc'] or None, 'scans': a['scans']}
                             for a in arrs],
        }
        return self._write_yaml(file_name, yaml_data, "scan arrangement")

    @Slot(QUrl, result=dict)
    def importScanArr(self, fname):
        """Import a scan arrangement YAML, or the ScanArrg sheet of prjcfg.xlsx.
        Returns {scan_items, arrangements, skipped}, or {} on failure (see lastError)."""
        file_name = fname.toLocalFile()
        if file_name.lower().endswith(('.xlsx', '.xlsm')):
            try:
                data = scanarr.read_scanarrg_xlsx(file_name)
            except Exception as e:  # openpyxl raises a variety of exception types
                return self._fail(f"Could not import {file_name}:\n{e}", {})
        else:
            data = self._read_yaml(file_name)
            if data is None:
                return {}
            data = dict(data, skipped=[])
        try:
            raw_items = data.get('scan_items') or []
            raw_arrs = data.get('arrangements') or []
            if any('name' not in i for i in raw_items) or any('name' not in a for a in raw_arrs):
                raise KeyError('name')
            # Files written before arrangement IDs existed: number them in order.
            raw_arrs = [dict(a, id=a.get('id', n)) for n, a in enumerate(raw_arrs, 1)]
            items, arrs = self._clean_scan_arr(raw_items, raw_arrs)
        except (KeyError, TypeError, AttributeError):
            return self._fail(f"{file_name}: expected 'scan_items' and 'arrangements' lists with a 'name' on every entry", {})
        self._last_error = ""
        logger.log(f"Imported scan arrangement {file_name}", "INFO")
        return {'scan_items': items, 'arrangements': arrs, 'skipped': list(data.get('skipped') or [])}

    @Slot(list, list, result=list)
    def checkScanArr(self, scan_items, arrangements):
        """Problems that would make the generated C wrong; empty when it is safe."""
        return scanarr.analyze(*self._clean_scan_arr(scan_items, arrangements))

    @Slot(QUrl, list, list, result=str)
    def generateScanArr(self, folder, scan_items, arrangements):
        """Write afeScanArrg.h and afeScanArrg.c into `folder`. Returns an error or ""."""
        items, arrs = self._clean_scan_arr(scan_items, arrangements)
        issues = scanarr.analyze(items, arrs)
        if issues:
            return "Fix these problems first:\n\n" + "\n".join(issues)
        out_dir = folder.toLocalFile()
        try:
            for name, text in (("afeScanArrg.h", scanarr.generate_header(items, arrs)),
                               ("afeScanArrg.c", scanarr.generate_source(arrs))):
                with open(os.path.join(out_dir, name), 'w', encoding='utf-8', newline='\n') as f:
                    f.write(text)
        except OSError as e:
            return self._fail(f"Could not write to {out_dir}: {e}", f"Could not write to {out_dir}: {e}")
        logger.log(f"Generated afeScanArrg.c/.h in {out_dir}", "INFO")
        return ""

    # ---- helpers ------------------------------------------------------
    def _read_yaml(self, file_name):
        try:
            with open(file_name, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
        except OSError as e:
            return self._fail(f"Could not open {file_name}: {e}", None)
        except yaml.YAMLError as e:
            return self._fail(f"{file_name} is not valid YAML: {e}", None)
        if not isinstance(data, dict):
            return self._fail(f"{file_name}: expected a YAML mapping at the top level", None)
        self._last_error = ""
        return data

    def _write_yaml(self, file_name, data, what):
        try:
            with open(file_name, 'w', encoding='utf-8') as f:
                yaml.dump(data, f, sort_keys=False, allow_unicode=True)
        except OSError as e:
            return self._fail(f"Could not write {file_name}: {e}", f"Could not write {file_name}: {e}")
        logger.log(f"Exported {what} as {file_name}", "INFO")
        return ""
