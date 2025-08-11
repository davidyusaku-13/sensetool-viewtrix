"""Update service for SenseTool application.

This module provides services for checking application updates,
downloading new versions, and managing the update process.
"""

import requests
from typing import Dict, Any, Optional
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
        try:
            current_version = self._config.get_version()
            releases_url = self._config.get_github_releases_url()
            
            self._log_debug(f"Checking for updates. Current version: {current_version}")
            
            response = requests.get(releases_url, timeout=self._request_timeout)
            response.raise_for_status()
            
            release_data = response.json()
            latest_version = release_data.get('tag_name', '')
            
            # Simple version comparison (assumes semantic versioning)
            is_update_available = self._is_newer_version(latest_version, current_version)
            
            release_notes = release_data.get('body', '')
            download_url = ''
            
            if release_data.get('assets'):
                download_url = release_data['assets'][0].get('browser_download_url', '')
            else:
                download_url = release_data.get('zipball_url', '')
            
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
        try:
            # Remove 'v' prefix if present
            latest = latest.lstrip('v')
            current = current.lstrip('v')
            
            # Split version parts and convert to integers
            latest_parts = [int(x) for x in latest.split('.') if x.isdigit()]
            current_parts = [int(x) for x in current.split('.') if x.isdigit()]
            
            # Pad shorter version with zeros
            max_length = max(len(latest_parts), len(current_parts))
            latest_parts.extend([0] * (max_length - len(latest_parts)))
            current_parts.extend([0] * (max_length - len(current_parts)))
            
            return latest_parts > current_parts
            
        except (ValueError, AttributeError):
            # Fallback to string comparison
            return latest > current
    
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