from PySide6.QtCore import QObject, Signal, Slot, QThread
from typing import Optional
from pathlib import Path
from ..core.base import BaseQmlObject
import requests, os, sys

class DownloadThread(QThread):
    """Thread for downloading application updates."""
    
    progressChanged = Signal(int)
    downloadCompleted = Signal()
    downloadFailed = Signal(str)

    def __init__(self, url: str, parent: Optional[QObject] = None):
        """Initialize download thread.
        
        Args:
            url: Download URL
            parent: Parent QObject
        """
        super().__init__(parent)
        self.url = url
        self.progress = 0

    def run(self) -> None:
        """Run the download process."""
        try:
            response = requests.get(self.url, stream=True)
            response.raise_for_status()
            total_size = int(response.headers.get('content-length', 0))
            downloaded_size = 0
            tmp_dest = Path.cwd() / "sensetool_tmp.exe"
            
            with open(tmp_dest, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:  # Filter out keep-alive chunks
                        file.write(chunk)
                        downloaded_size += len(chunk)
                        if total_size > 0:
                            self.progress = int((downloaded_size / total_size) * 100)
                            self.progressChanged.emit(self.progress)
                            
            self.progress = 100
            self.progressChanged.emit(100)
            self.downloadCompleted.emit()
            
        except Exception as e:
            self.progress = 0
            self.progressChanged.emit(0)
            self.downloadFailed.emit(str(e))

class UpdateManager(BaseQmlObject):
    """Manager for application updates.
    
    Handles downloading updates and managing the update process.
    """
    
    restartApplication = Signal()
    progressChanged = Signal(int)
    downloadCompleted = Signal()
    downloadFailed = Signal(str)

    def __init__(self, parent: Optional[QObject] = None):
        """Initialize update manager.
        
        Args:
            parent: Parent QObject
        """
        super().__init__(parent)
        self.download_thread: Optional[DownloadThread] = None
        self.progress = 0

    @Slot(str)
    def downloadUpdate(self, url: str) -> None:
        """Start downloading an update.
        
        Args:
            url: Download URL for the update
        """
        try:
            if self.download_thread is None or not self.download_thread.isRunning():
                self.download_thread = DownloadThread(url)
                self.download_thread.progressChanged.connect(self.updateProgress)
                self.download_thread.downloadCompleted.connect(self._on_download_completed)
                self.download_thread.downloadFailed.connect(self._on_download_failed)
                self.download_thread.start()
                self._log_info(f"Started downloading update from: {url}")
            else:
                self._log_error("Download already in progress")
        except Exception as e:
            self._log_error(f"Failed to start download: {e}")

    def updateProgress(self, progress: int) -> None:
        """Update download progress.
        
        Args:
            progress: Progress percentage (0-100)
        """
        self.progress = progress
        self.progressChanged.emit(progress)

    @Slot(result=int)
    def getProgress(self) -> int:
        """Get current download progress.
        
        Returns:
            Progress percentage (0-100)
        """
        return self.progress
    
    def _on_download_completed(self) -> None:
        """Handle download completion."""
        self._log_info("Update download completed successfully")
        self.downloadCompleted.emit()
    
    def _on_download_failed(self, error: str) -> None:
        """Handle download failure.
        
        Args:
            error: Error message
        """
        self._log_error(f"Update download failed: {error}")
        self.downloadFailed.emit(error)

    @Slot()
    def rename_and_restart(self) -> None:
        """Rename downloaded file and restart application."""
        try:
            current_exe = Path.cwd() / "sensetool.exe"
            tmp_exe = Path.cwd() / "sensetool_tmp.exe"
            new_exe = Path.cwd() / "sensetool_new.exe"

            if current_exe.exists():
                current_exe.unlink()
                self._log_info("Removed old executable")

            if tmp_exe.exists():
                tmp_exe.rename(new_exe)
                self._log_info("Renamed new executable")
                self.restartApplication.emit()
            else:
                self._log_error("Temporary executable not found")
                
        except Exception as e:
            self._log_error(f"Error during renaming and restart: {e}")

    @Slot()
    def finalize_update(self) -> None:
        """Finalize the update process."""
        try:
            new_exe = Path.cwd() / "sensetool_new.exe"
            current_exe = Path.cwd() / "sensetool.exe"
            
            if new_exe.exists():
                new_exe.rename(current_exe)
                self._log_info("Update finalized successfully")
                os.execv(sys.executable, [sys.executable] + sys.argv)
            else:
                self._log_error("New executable not found for finalization")
        except Exception as e:
            self._log_error(f"Error during update finalization: {e}")