"""Configuration management for SenseTool application.

This module provides centralized configuration management,
including application settings, constants, and environment variables.
"""

import os
import configparser
from pathlib import Path
from typing import Dict, Any, Optional
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
    
    def __init__(self, config_path: Optional[Path] = None):
        """Initialize configuration manager.
        
        Args:
            config_path: Optional path to configuration file
        """
        self._config = AppConfig()
        self._config_path = config_path or self._get_default_config_path()
        self._load_config()
    
    def _get_default_config_path(self) -> Path:
        """Get default configuration file path."""
        return Path(__file__).parent.parent / "modules" / "config.ini"
    
    def _load_config(self) -> None:
        """Load configuration from file if it exists."""
        if not self._config_path.exists():
            return
            
        parser = configparser.ConfigParser()
        parser.read(self._config_path)
        
        # Load application settings if they exist
        if parser.has_section('app'):
            app_section = parser['app']
            self._config.app_name = app_section.get('name', self._config.app_name)
            self._config.window_width = app_section.getint('window_width', self._config.window_width)
            self._config.window_height = app_section.getint('window_height', self._config.window_height)
    
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