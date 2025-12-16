"""Configuration management for SenseTool application.

This module provides centralized configuration management,
including application settings, constants, and environment variables.
"""

import os
from pathlib import Path
from typing import Dict, Any
from dataclasses import dataclass


@dataclass
class AppConfig:
    """Application configuration data class."""
    app_name: str = "SenseTool"
    organization_name: str = "Viewtrix"
    organization_domain: str = "Viewtrix"
    window_width: int = 1280
    window_height: int = 720
    theme_style: str = "Material"
    
    # API Configuration
    github_api_base: str = "https://api.github.com"
    github_repo: str = "davidyusaku-13/sensetool-viewtrix"
    
    # File paths
    version_file: str = "VERSION.txt"
    log_file: str = "sensetool.log"
    
    # Logging configuration
    log_level: str = "DEBUG"
    log_max_bytes: int = 1000000  # 1MB
    log_backup_count: int = 3


class ConfigManager:
    """Centralized configuration manager.
    
    Handles loading and managing application configuration
    from various sources including files and environment variables.
    """
    
    def __init__(self):
        """Initialize configuration manager."""
        self._config = AppConfig()

    @property
    def config(self) -> AppConfig:
        """Get application configuration."""
        return self._config
    
    def get_version(self) -> str:
        """Get application version from version file.
        
        Returns:
            Application version string
        """
        version_path = Path(__file__).parent.parent.parent / self._config.version_file
        try:
            with open(version_path, 'r', encoding='utf-8') as f:
                return f.read().strip()
        except FileNotFoundError:
            return "0.0.0"
    
    def get_github_releases_url(self) -> str:
        """Get GitHub releases API URL.
        
        Returns:
            GitHub releases API URL
        """
        return f"{self._config.github_api_base}/repos/{self._config.github_repo}/releases/latest"
    
    def get_log_config(self) -> Dict[str, Any]:
        """Get logging configuration.
        
        Returns:
            Dictionary containing logging configuration
        """
        return {
            'level': self._config.log_level,
            'filename': self._config.log_file,
            'maxBytes': self._config.log_max_bytes,
            'backupCount': self._config.log_backup_count
        }


# Global configuration instance
_config_manager = None


def get_config_manager() -> ConfigManager:
    """Get global configuration manager instance.
    
    Returns:
        ConfigManager instance
    """
    global _config_manager
    if _config_manager is None:
        _config_manager = ConfigManager()
    return _config_manager