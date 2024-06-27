from PySide6.QtCore import QObject, Signal, Slot, QThread
import requests, os, sys

class DownloadThread(QThread):
    progressChanged = Signal(int)

    def __init__(self, url, parent=None):
        super().__init__(parent)
        self.url = url
        self.progress = 0

    def run(self):
        dest = os.path.join(os.getcwd(), "sensetool.exe")
        try:
            response = requests.get(self.url, stream=True)
            response.raise_for_status()
            total_size = int(response.headers.get('content-length', 0))
            downloaded_size = 0
            with open(dest, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    file.write(chunk)
                    downloaded_size += len(chunk)
                    self.progress = int((downloaded_size / total_size) * 100)
                    self.progressChanged.emit(self.progress)
            self.progress = 100
            self.progressChanged.emit(100)
        except Exception as e:
            self.progress = 0
            self.progressChanged.emit(0)

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
            return  # Do not start a new download if one is already running

        self.thread = DownloadThread(url)
        self.thread.progressChanged.connect(self.updateProgress)
        self.thread.start()

    def updateProgress(self, progress):
        self.progress = progress
        self.progressChanged.emit(progress)

    @Slot(result=int)
    def getProgress(self):
        return self.progress