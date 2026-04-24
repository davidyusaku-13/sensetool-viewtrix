"""Update service for SenseTool application.

This module provides services for checking application updates,
downloading new versions, and managing the update process.
"""

import platform
import re
import requests
from typing import Dict, Any, Optional, List, Tuple
from dataclasses import dataclass
from PySide6.QtCore import QObject, Signal, QThread
from ..core.base import BaseService


@dataclass
class UpdateInfo:
    """Data class for update information."""
    is_available: bool
    current_version: str
    latest_version: str
    release_notes: str
    download_url: str
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for QML consumption.
        
        Returns:
            Dictionary representation
        """
        return {
            'status': self.is_available,
            'current_version': self.current_version,
            'version': self.latest_version,
            'changelog': self.release_notes,
            'link': self.download_url
        }


class DownloadWorker(QThread):
    """Worker thread for downloading updates."""
    
    progressChanged = Signal(int)
    downloadCompleted = Signal(bool, str)  # success, message
    
    def __init__(self, url: str, destination: str, parent: Optional[QObject] = None):
        """Initialize download worker.
        
        Args:
            url: Download URL
            destination: Destination file path
            parent: Parent QObject
        """
        super().__init__(parent)
        self.url = url
        self.destination = destination
        self._cancelled = False
    
    def cancel(self) -> None:
        """Cancel the download."""
        self._cancelled = True
    
    def run(self) -> None:
        """Run the download process."""
        try:
            response = requests.get(self.url, stream=True, timeout=30)
            response.raise_for_status()
            
            total_size = int(response.headers.get('content-length', 0))
            downloaded_size = 0
            
            with open(self.destination, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    if self._cancelled:
                        self.downloadCompleted.emit(False, "Download cancelled")
                        return
                    
                    if chunk:
                        file.write(chunk)
                        downloaded_size += len(chunk)
                        
                        if total_size > 0:
                            progress = int((downloaded_size / total_size) * 100)
                            self.progressChanged.emit(progress)
            
            self.progressChanged.emit(100)
            self.downloadCompleted.emit(True, "Download completed successfully")
            
        except requests.RequestException as e:
            self.downloadCompleted.emit(False, f"Network error: {e}")
        except IOError as e:
            self.downloadCompleted.emit(False, f"File error: {e}")
        except Exception as e:
            self.downloadCompleted.emit(False, f"Unexpected error: {e}")


class UpdateService(BaseService):
    """Service for handling application updates.
    
    Provides functionality for checking updates, downloading new versions,
    and managing the update process.
    """
    
    def __init__(self):
        """Initialize update service."""
        super().__init__()
        self._download_worker: Optional[DownloadWorker] = None
        self._request_timeout = 10  # seconds
    
    def initialize(self) -> bool:
        """Initialize the update service.
        
        Returns:
            True if initialization was successful
        """
        try:
            self._log_info("Initializing update service")
            return True
        except Exception as e:
            self._log_error(f"Failed to initialize update service: {e}")
            return False
    
    def check_for_updates(self) -> UpdateInfo:
        """Check for available updates.
        
        Returns:
            UpdateInfo object with update details
        """
        current_version = self._config.get_version()

        try:
            releases_url = self._config.get_github_releases_url()
            
            self._log_debug(f"Checking for updates. Current version: {current_version}")
            
            response = requests.get(releases_url, timeout=self._request_timeout)
            response.raise_for_status()
            
            release_data = response.json()
            latest_version = release_data.get('tag_name', '')
            
            # Simple version comparison (assumes semantic versioning)
            is_update_available = self._is_newer_version(latest_version, current_version)
            
            release_notes = release_data.get('body', '')
            download_url = self._select_download_url(release_data)
            
            update_info = UpdateInfo(
                is_available=is_update_available,
                current_version=current_version,
                latest_version=latest_version,
                release_notes=release_notes,
                download_url=download_url
            )
            
            if is_update_available:
                self._log_info(
                    f"Update available: {current_version} -> {latest_version}"
                )
            else:
                self._log_info("No updates available")
            
            return update_info
            
        except requests.RequestException as e:
            self._log_error(f"Network error while checking for updates: {e}")
            return self._create_error_update_info(current_version, str(e))
        except Exception as e:
            self._log_error(f"Error while checking for updates: {e}")
            return self._create_error_update_info(current_version, str(e))
    
    def _is_newer_version(self, latest: str, current: str) -> bool:
        """Compare version strings to determine if latest is newer.
        
        Args:
            latest: Latest version string
            current: Current version string
            
        Returns:
            True if latest version is newer
        """
        latest_version = self._parse_semver(latest)
        current_version = self._parse_semver(current)

        if latest_version and current_version:
            return latest_version > current_version

        return str(latest) > str(current)

    def _parse_semver(self, version: str) -> Optional[Tuple[int, int, int, int, Tuple[Tuple[int, object], ...]]]:
        """Parse a semantic version string with optional prerelease."""
        if not isinstance(version, str):
            return None

        match = re.fullmatch(
            r"v?(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)"
            r"(?:-(?P<prerelease>[0-9A-Za-z.-]+))?",
            version.strip()
        )
        if not match:
            return None

        prerelease = match.group("prerelease")
        prerelease_key: Tuple[Tuple[int, object], ...]
        if prerelease is None:
            prerelease_rank = 1
            prerelease_key = ()
        else:
            prerelease_rank = 0
            prerelease_key = tuple(self._parse_prerelease_identifier(part) for part in prerelease.split("."))

        return (
            int(match.group("major")),
            int(match.group("minor")),
            int(match.group("patch")),
            prerelease_rank,
            prerelease_key,
        )

    @staticmethod
    def _parse_prerelease_identifier(part: str) -> Tuple[int, object]:
        """Parse semver prerelease identifier for tuple comparison."""
        if part.isdigit():
            return (0, int(part))
        return (1, part.lower())

    def _select_download_url(self, release_data: Dict[str, Any]) -> str:
        """Choose platform-appropriate release asset URL."""
        assets = release_data.get("assets") or []
        selected_asset = self._select_download_asset(assets)
        if selected_asset:
            return selected_asset.get("browser_download_url", "")
        return ""

    def _select_download_asset(
        self,
        assets: List[Dict[str, Any]],
        system_name: Optional[str] = None,
        machine_name: Optional[str] = None,
    ) -> Optional[Dict[str, Any]]:
        """Choose best matching asset for current platform."""
        if not assets:
            return None

        system_name = (system_name or platform.system()).lower()
        machine_name = (machine_name or platform.machine()).lower()

        system_keywords = {
            "windows": ["windows", "win", ".exe", ".msi"],
            "linux": ["linux", "appimage", ".deb", ".rpm", ".tar.gz"],
            "darwin": ["macos", "mac", "darwin", "osx", ".dmg", ".app", ".pkg"],
        }
        arch_keywords = {
            "x86_64": ["x86_64", "amd64", "x64", "64"],
            "amd64": ["x86_64", "amd64", "x64", "64"],
            "arm64": ["arm64", "aarch64"],
            "aarch64": ["arm64", "aarch64"],
        }

        platform_terms = system_keywords.get(system_name, [system_name])
        machine_terms = arch_keywords.get(machine_name, [machine_name])
        scored_assets = []

        for asset in assets:
            name = str(asset.get("name", "")).lower()
            if not name:
                continue

            score = 0
            if any(term in name for term in platform_terms):
                score += 10
            elif len(assets) > 1:
                continue

            if any(term in name for term in machine_terms):
                score += 5

            if name.endswith((".exe", ".msi", ".dmg", ".pkg", ".appimage", ".tar.gz", ".zip")):
                score += 1

            scored_assets.append((score, asset))

        if not scored_assets:
            return None

        scored_assets.sort(key=lambda item: item[0], reverse=True)
        return scored_assets[0][1]
    
    def _create_error_update_info(self, current_version: str, error_message: str) -> UpdateInfo:
        """Create UpdateInfo object for error cases.
        
        Args:
            current_version: Current application version
            error_message: Error message
            
        Returns:
            UpdateInfo object indicating no update available
        """
        return UpdateInfo(
            is_available=False,
            current_version=current_version,
            latest_version=current_version,
            release_notes=f"Error checking for updates: {error_message}",
            download_url=''
        )
    
    def start_download(self, url: str, destination: str) -> DownloadWorker:
        """Start downloading an update.
        
        Args:
            url: Download URL
            destination: Destination file path
            
        Returns:
            DownloadWorker instance
        """
        if self._download_worker and self._download_worker.isRunning():
            self._download_worker.cancel()
            self._download_worker.wait()
        
        self._download_worker = DownloadWorker(url, destination)
        self._log_info(f"Starting download from {url} to {destination}")
        
        return self._download_worker
    
    def cancel_download(self) -> None:
        """Cancel current download if running."""
        if self._download_worker and self._download_worker.isRunning():
            self._log_info("Cancelling download")
            self._download_worker.cancel()
    
    def is_download_running(self) -> bool:
        """Check if download is currently running.
        
        Returns:
            True if download is running
        """
        return (
            self._download_worker is not None and 
            self._download_worker.isRunning()
        )
