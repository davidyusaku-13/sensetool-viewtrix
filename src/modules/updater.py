import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Optional

from PySide6.QtCore import QObject, QCoreApplication, Signal, Slot

from ..core.base import BaseQmlObject
from ..services.update_service import DownloadWorker, UpdateService


class UpdateManager(BaseQmlObject):
    """Manager for downloading and installing application updates."""

    progressChanged = Signal(int)
    downloadCompleted = Signal()
    downloadFailed = Signal(str)

    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._update_service = UpdateService()
        self._update_service.initialize()
        self._download_worker: Optional[DownloadWorker] = None
        self._downloaded_file: Optional[Path] = None
        self.progress = 0

    @Slot(result=bool)
    def canInstallUpdate(self) -> bool:
        """Return True only for packaged Windows builds."""
        executable_path = Path(sys.executable)
        return (
            sys.platform == "win32"
            and getattr(sys, "frozen", False)
            and executable_path.suffix.lower() == ".exe"
        )

    @Slot(str)
    def downloadUpdate(self, url: str) -> None:
        """Download update payload for later installation."""
        try:
            if not self.canInstallUpdate():
                self.downloadFailed.emit(
                    "Self-update is supported only in the packaged Windows build."
                )
                return

            if not url:
                self.downloadFailed.emit("No download URL available for this platform.")
                return

            if self._download_worker and self._download_worker.isRunning():
                self.downloadFailed.emit("Download already in progress.")
                return

            destination = self._get_download_destination()
            if destination.exists():
                destination.unlink()

            self._download_worker = self._update_service.start_download(url, str(destination))
            self._downloaded_file = destination
            self._download_worker.progressChanged.connect(self.updateProgress)
            self._download_worker.downloadCompleted.connect(self._on_download_finished)
            self._download_worker.start()
            self._log_info(f"Started downloading update from: {url}")
        except Exception as e:
            self._log_error(f"Failed to start download: {e}")
            self.downloadFailed.emit(str(e))

    def updateProgress(self, progress: int) -> None:
        """Update progress property and emit change signal."""
        self.progress = progress
        self.progressChanged.emit(progress)

    @Slot(result=int)
    def getProgress(self) -> int:
        """Get current download progress percentage."""
        return self.progress

    def _on_download_finished(self, success: bool, message: str) -> None:
        """Handle download completion from UpdateService worker."""
        if success:
            self._log_info(message)
            self.progress = 100
            self.downloadCompleted.emit()
            return

        if self._downloaded_file and self._downloaded_file.exists():
            self._downloaded_file.unlink(missing_ok=True)

        self.progress = 0
        self.progressChanged.emit(0)
        self._log_error(f"Update download failed: {message}")
        self.downloadFailed.emit(message)

    @Slot()
    def installUpdate(self) -> None:
        """Install downloaded update and quit current app."""
        try:
            if not self.canInstallUpdate():
                self.downloadFailed.emit(
                    "Self-update is supported only in the packaged Windows build."
                )
                return

            if not self._downloaded_file or not self._downloaded_file.exists():
                self.downloadFailed.emit("Downloaded update file not found.")
                return

            target = Path(sys.executable).resolve()
            backup = target.with_suffix(target.suffix + ".bak")
            script_path = self._write_installer_script(target, self._downloaded_file, backup)

            creation_flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
            subprocess.Popen(
                ["cmd", "/c", str(script_path)],
                creationflags=creation_flags,
                close_fds=True,
            )
            self._log_info("Launched update installer helper")
            QCoreApplication.quit()
        except Exception as e:
            self._log_error(f"Failed to install update: {e}")
            self.downloadFailed.emit(str(e))

    @Slot()
    def rename_and_restart(self) -> None:
        """Backward-compatible alias for install flow."""
        self.installUpdate()

    @Slot()
    def finalize_update(self) -> None:
        """Backward-compatible alias for install flow."""
        self.installUpdate()

    def _get_download_destination(self) -> Path:
        """Place downloaded payload next to current executable."""
        target = Path(sys.executable).resolve()
        return target.with_suffix(target.suffix + ".download")

    def _write_installer_script(self, target: Path, download: Path, backup: Path) -> Path:
        """Create helper batch file that swaps binaries after process exit."""
        temp_dir = Path(tempfile.gettempdir())
        script_path = temp_dir / f"{target.stem}_update.cmd"
        script_path.write_text(
            self._build_windows_installer_script(target, download, backup),
            encoding="utf-8",
        )
        return script_path

    def _build_windows_installer_script(self, target: Path, download: Path, backup: Path) -> str:
        """Build batch script for safe binary replacement on Windows."""
        pid = os.getpid()
        target_str = str(target)
        download_str = str(download)
        backup_str = str(backup)

        return rf"""@echo off
setlocal enableextensions
set "TARGET={target_str}"
set "DOWNLOAD={download_str}"
set "BACKUP={backup_str}"

:wait_for_exit
tasklist /FI "PID eq {pid}" | find "{pid}" >nul
if not errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto wait_for_exit
)

if exist "%BACKUP%" del /f /q "%BACKUP%"
if exist "%TARGET%" move /Y "%TARGET%" "%BACKUP%" >nul
move /Y "%DOWNLOAD%" "%TARGET%" >nul
if errorlevel 1 goto rollback

start "" "%TARGET%"
if exist "%BACKUP%" del /f /q "%BACKUP%"
del /f /q "%~f0"
exit /b 0

:rollback
if exist "%BACKUP%" move /Y "%BACKUP%" "%TARGET%" >nul
del /f /q "%~f0"
exit /b 1
"""
