"""Checking GitHub for a newer SenseTool release."""
import os
import re
import requests
from PySide6.QtCore import QObject, QThread, Signal, Slot
from PySide6.QtQml import QmlElement
from .logger import AppLogger

QML_IMPORT_NAME = "UpdateChecker"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()

RELEASE_URL = "https://api.github.com/repos/davidyusaku-13/sensetool-viewtrix/releases/latest"
VERSION_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "VERSION.txt")


def parse_version(text):
    """'v1.2.10-beta.3+4' -> (1, 2, 10). Pre-release/build metadata is ignored."""
    core = re.split(r"[-+]", (text or "").strip().lstrip("vV"), maxsplit=1)[0]
    return tuple(int(p) for p in re.findall(r"\d+", core))


def is_newer(latest, current):
    lv, cv = parse_version(latest), parse_version(current)
    if not lv or not cv:
        return False  # unknown version (e.g. a dev build): don't nag
    width = max(len(lv), len(cv))
    return lv + (0,) * (width - len(lv)) > cv + (0,) * (width - len(cv))


def read_version(path=VERSION_FILE):
    try:
        with open(path, "r") as f:
            return f.read().strip()
    except OSError:
        return ""


def fetch_update_info(current_version, timeout=5, get=requests.get):
    """{status, version, changelog, link}; status is True when a newer release exists.
    `get` is injectable for tests."""
    result = {"status": False, "version": "", "changelog": "", "link": ""}
    try:
        response = get(RELEASE_URL, timeout=timeout)
        response.raise_for_status()
        release = response.json()
        latest = release.get("tag_name", "")
        result["version"] = latest
        if is_newer(latest, current_version):
            assets = release.get("assets") or []
            result.update(status=True, changelog=release.get("body") or "",
                          link=assets[0]["browser_download_url"] if assets else release.get("zipball_url", ""))
    except (requests.RequestException, ValueError, KeyError, IndexError, TypeError) as e:
        logger.log(f"Failed to fetch the latest release information: {e}", "ERROR")
    return result


class _CheckThread(QThread):
    done = Signal(dict)

    def __init__(self, fetch, parent=None):
        super().__init__(parent)
        self._fetch = fetch

    def run(self):
        self.done.emit(self._fetch())


@QmlElement
class UpdateChecker(QObject):
    updateChecked = Signal(bool, str, str, str)  # available, version, changelog, link

    def __init__(self, parent=None, version=None, get=requests.get):
        super().__init__(parent)
        self._version = read_version() if version is None else version
        self._get = get
        self._link = ""
        self._thread = None

    def _fetch(self):
        return fetch_update_info(self._version, get=self._get)

    @Slot(result=str)
    def version(self):
        return self._version

    @Slot(result=dict)
    def checkNow(self):
        """Blocking check (used by "Check for updates")."""
        info = self._fetch()
        self._link = info["link"]
        return info

    @Slot()
    def checkAsync(self):
        """Background check at startup, so a slow or missing network never blocks."""
        if self._thread and self._thread.isRunning():
            return
        self._thread = _CheckThread(self._fetch, self)
        self._thread.done.connect(self._on_checked)
        self._thread.start()

    def _on_checked(self, info):
        self._link = info["link"]
        self.updateChecked.emit(info["status"], info["version"], info["changelog"], info["link"])

    @Slot(result=str)
    def updateLink(self):
        return self._link
