from PySide6.QtCore import QObject, Signal, Slot, QThread
from src.modules.logger import AppLogger
import requests, os, sys

# Init LOGGER
logger = AppLogger.get_instance()

class DownloadThread(QThread):
    progressChanged = Signal(int)
    downloadCompleted = Signal()

    def __init__(self, url, parent=None):
        super().__init__(parent)
        self.url = url
        self.progress = 0

    def run(self):
        try:
            response = requests.get(self.url, stream=True)
            response.raise_for_status()
            total_size = int(response.headers.get('content-length', 0))
            downloaded_size = 0
            tmp_dest = os.path.join(os.getcwd(), "sensetool_tmp.exe")
            with open(tmp_dest, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    file.write(chunk)
                    downloaded_size += len(chunk)
                    self.progress = int((downloaded_size / total_size) * 100)
                    self.progressChanged.emit(self.progress)
            self.progress = 100
            self.progressChanged.emit(100)
            self.downloadCompleted.emit()
            logger.log(f"Successfully downloaded newest version", "INFO")
        except Exception as e:
            self.progress = 0
            self.progressChanged.emit(0)
            logger.log(f"Failed to download the newest version", "ERROR")

class UpdateManager(QObject):
    progressChanged = Signal(int)
    restartApplication = Signal()

    def __init__(self):
        super().__init__()
        self.thread = None
        self.progress = 0

    @Slot(str)
    def download_update(self, url):
        if self.thread and self.thread.isRunning():
            return

        self.thread = DownloadThread(url)
        self.thread.progressChanged.connect(self.updateProgress)
        self.thread.downloadCompleted.connect(self.rename_and_restart)
        self.thread.start()

    def updateProgress(self, progress):
        self.progress = progress
        self.progressChanged.emit(progress)

    @Slot(result=int)
    def getProgress(self):
        return self.progress

    @Slot()
    def rename_and_restart(self):
        try:
            current_exe = os.path.join(os.getcwd(), "sensetool.exe")
            tmp_exe = os.path.join(os.getcwd(), "sensetool_tmp.exe")
            new_exe = os.path.join(os.getcwd(), "sensetool_new.exe")

            if os.path.exists(current_exe):
                os.remove(current_exe)

            os.rename(tmp_exe, new_exe)

            self.restartApplication.emit()
        except Exception as e:
            logger.log(f"Error during renaming: {e}", "ERROR")

    @Slot()
    def finalize_update(self):
        try:
            new_exe = os.path.join(os.getcwd(), "sensetool_new.exe")
            if os.path.exists(new_exe):
                os.rename(new_exe, os.path.join(os.getcwd(), "sensetool.exe"))
                os.execv(sys.executable, [sys.executable] + sys.argv)
        except Exception as e:
            logger.log(f"Error during finalizing update: {e}", "ERROR")