"""File service for SenseTool application.

This module provides services for file I/O operations including
YAML import/export, validation, and error handling.
"""

import yaml
from pathlib import Path
from typing import Dict, Any, List, Optional, Union
from PySide6.QtCore import QUrl
from ..core.base import BaseService, ValidationMixin
from .coefficient_service import WindowCoefficients, DemoCoefficients, WindowLength


class FileService(BaseService, ValidationMixin):
    """Service for file operations.
    
    Handles reading and writing YAML files with proper validation
    and error handling.
    """
    
    def __init__(self):
        """Initialize file service."""
        super().__init__()
        self._supported_extensions = {'.yaml', '.yml'}
    
    def initialize(self) -> bool:
        """Initialize the file service.
        
        Returns:
            True if initialization was successful
        """
        try:
            self._log_info("Initializing file service")
            return True
        except Exception as e:
            self._log_error(f"Failed to initialize file service: {e}")
            return False
    
    def _validate_file_path(self, file_path: Union[str, Path, QUrl]) -> Path:
        """Validate and convert file path to Path object.
        
        Args:
            file_path: File path to validate
            
        Returns:
            Validated Path object
            
        Raises:
            ValueError: If file path is invalid
        """
        if isinstance(file_path, QUrl):
            path = Path(file_path.toLocalFile())
        elif isinstance(file_path, str):
            path = Path(file_path)
        elif isinstance(file_path, Path):
            path = file_path
        else:
            raise ValueError(f"Invalid file path type: {type(file_path)}")
        
        if not path.suffix.lower() in self._supported_extensions:
            raise ValueError(
                f"Unsupported file extension: {path.suffix}. "
                f"Supported: {', '.join(self._supported_extensions)}"
            )
        
        return path
    
    def export_window_coefficients(
        self,
        file_path: Union[str, Path, QUrl],
        coefficients: WindowCoefficients
    ) -> bool:
        """Export window coefficients to YAML file.
        
        Args:
            file_path: Path to output file
            coefficients: WindowCoefficients object to export
            
        Returns:
            True if export was successful
        """
        try:
            path = self._validate_file_path(file_path)
            data = coefficients.to_dict()
            
            self._log_debug(f"Exporting window coefficients to {path}")
            
            # Ensure parent directory exists
            path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(path, 'w', encoding='utf-8') as file:
                yaml.dump(data, file, sort_keys=False, default_flow_style=False)
            
            self._log_info(f"Successfully exported window coefficients to {path}")
            return True
            
        except Exception as e:
            self._log_error(f"Failed to export window coefficients: {e}")
            return False
    
    def import_window_coefficients(
        self,
        file_path: Union[str, Path, QUrl]
    ) -> Optional[WindowCoefficients]:
        """Import window coefficients from YAML file.
        
        Args:
            file_path: Path to input file
            
        Returns:
            WindowCoefficients object if successful, None otherwise
        """
        try:
            path = self._validate_file_path(file_path)
            
            if not path.exists():
                raise FileNotFoundError(f"File not found: {path}")
            
            self._log_debug(f"Importing window coefficients from {path}")
            
            with open(path, 'r', encoding='utf-8') as file:
                data = yaml.safe_load(file)
            
            # Validate required fields
            required_fields = ['sample_number', 'a0', 'coef_length', 'data']
            for field in required_fields:
                if field not in data:
                    raise ValueError(f"Missing required field: {field}")
            
            # Extract coefficients
            coefficients = []
            for item in data['data']:
                if 'y' not in item:
                    raise ValueError("Invalid data format: missing 'y' field")
                coefficients.append(int(item['y']))
            
            # Create WindowCoefficients object
            length = WindowLength.FULL if data['coef_length'] == 'Full' else WindowLength.HALF
            
            result = WindowCoefficients(
                sample_number=int(data['sample_number']),
                a0=float(data['a0']),
                length=length,
                coefficients=coefficients
            )
            
            self._log_info(
                f"Successfully imported {len(coefficients)} window coefficients from {path}"
            )
            
            return result
            
        except Exception as e:
            self._log_error(f"Failed to import window coefficients: {e}")
            return None
    
    def export_demo_coefficients(
        self,
        file_path: Union[str, Path, QUrl],
        coefficients: DemoCoefficients
    ) -> bool:
        """Export demo coefficients to YAML file.
        
        Args:
            file_path: Path to output file
            coefficients: DemoCoefficients object to export
            
        Returns:
            True if export was successful
        """
        try:
            path = self._validate_file_path(file_path)
            data = coefficients.to_dict()
            
            self._log_debug(f"Exporting demo coefficients to {path}")
            
            # Ensure parent directory exists
            path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(path, 'w', encoding='utf-8') as file:
                yaml.dump(data, file, sort_keys=False, default_flow_style=False)
            
            self._log_info(f"Successfully exported demo coefficients to {path}")
            return True
            
        except Exception as e:
            self._log_error(f"Failed to export demo coefficients: {e}")
            return False
    
    def import_demo_coefficients(
        self,
        file_path: Union[str, Path, QUrl]
    ) -> Optional[DemoCoefficients]:
        """Import demo coefficients from YAML file.
        
        Args:
            file_path: Path to input file
            
        Returns:
            DemoCoefficients object if successful, None otherwise
        """
        try:
            path = self._validate_file_path(file_path)
            
            if not path.exists():
                raise FileNotFoundError(f"File not found: {path}")
            
            self._log_debug(f"Importing demo coefficients from {path}")
            
            with open(path, 'r', encoding='utf-8') as file:
                data = yaml.safe_load(file)

            if not isinstance(data, dict):
                raise ValueError("Invalid demo coefficients file format")

            if all(field in data for field in ['demo_step', 'demo_sample', 'demo_cycle', 'demo_adc', 'data']):
                num_step = int(data['demo_step'])
                sample_number = int(data['demo_sample'])
                cycle = int(data['demo_cycle'])
                adc_sampling_freq = int(data['demo_adc'])
                coefficients = self._extract_coefficients(data['data'], ('y',))
            elif all(field in data for field in ['step', 'sample', 'cycle', 'adc_freq']):
                num_step = int(data['step'])
                sample_number = int(data['sample'])
                cycle = int(data['cycle'])
                adc_sampling_freq = int(data['adc_freq'])
                legacy_coefficients = data.get('i_coef') or data.get('q_coef') or data.get('data')
                if legacy_coefficients is None:
                    raise ValueError("Missing coefficient data in legacy demo file")
                coefficients = self._extract_coefficients(legacy_coefficients, ('y_sin', 'y_cos', 'y'))
            else:
                raise ValueError("Missing required demo coefficient fields")

            result = DemoCoefficients(
                num_step=num_step,
                sample_number=sample_number,
                cycle=cycle,
                adc_sampling_freq=adc_sampling_freq,
                coefficients=coefficients
            )
            
            self._log_info(
                f"Successfully imported {len(coefficients)} demo coefficients from {path}"
            )
            
            return result
            
        except Exception as e:
            self._log_error(f"Failed to import demo coefficients: {e}")
            return None

    def _extract_coefficients(
        self,
        items: Any,
        accepted_keys: tuple[str, ...]
    ) -> List[int]:
        """Extract integer coefficient values from YAML list items."""
        if not isinstance(items, list):
            raise ValueError("Coefficient data must be a list")

        coefficients = []
        for item in items:
            if not isinstance(item, dict):
                raise ValueError("Coefficient entries must be dictionaries")

            value = None
            for key in accepted_keys:
                if key in item:
                    value = item[key]
                    break

            if value is None and len(item) == 1:
                value = next(iter(item.values()))

            if value is None:
                raise ValueError(
                    f"Invalid coefficient entry, expected one of: {', '.join(accepted_keys)}"
                )

            coefficients.append(int(value))

        return coefficients
    
    def export_project_settings(
        self,
        file_path: Union[str, Path, QUrl],
        settings_data: List[Dict[str, Any]]
    ) -> bool:
        """Export project settings to YAML file.
        
        Args:
            file_path: Path to output file
            settings_data: List of setting dictionaries
            
        Returns:
            True if export was successful
        """
        try:
            path = self._validate_file_path(file_path)
            
            data = {
                'title': 'Project Settings',
                'desc': 'Project settings exported from SenseTool',
                'data': settings_data
            }
            
            self._log_debug(f"Exporting project settings to {path}")
            
            # Ensure parent directory exists
            path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(path, 'w', encoding='utf-8') as file:
                yaml.dump(data, file, sort_keys=False, default_flow_style=False)
            
            self._log_info(f"Successfully exported project settings to {path}")
            return True
            
        except Exception as e:
            self._log_error(f"Failed to export project settings: {e}")
            return False
    
    def import_project_settings(
        self,
        file_path: Union[str, Path, QUrl]
    ) -> Optional[List[Dict[str, Any]]]:
        """Import project settings from YAML file.
        
        Args:
            file_path: Path to input file
            
        Returns:
            List of setting dictionaries if successful, None otherwise
        """
        try:
            path = self._validate_file_path(file_path)
            
            if not path.exists():
                raise FileNotFoundError(f"File not found: {path}")
            
            self._log_debug(f"Importing project settings from {path}")
            
            with open(path, 'r', encoding='utf-8') as file:
                data = yaml.safe_load(file)
            
            # Validate structure
            if not isinstance(data, dict) or 'data' not in data:
                raise ValueError("Invalid project settings file format")
            
            raw_settings = data['data']
            if not isinstance(raw_settings, list):
                raise ValueError("Project settings data must be a list")

            settings_data = []
            for i, setting in enumerate(raw_settings):
                if isinstance(setting, dict):
                    required_fields = ['name', 'value']
                    for field in required_fields:
                        if field not in setting:
                            raise ValueError(f"Setting {i} missing required field: {field}")
                    settings_data.append({
                        'name': '' if setting['name'] is None else str(setting['name']),
                        'value': '' if setting['value'] is None else str(setting['value']),
                        'desc': '' if setting.get('desc') is None else str(setting.get('desc')),
                    })
                elif isinstance(setting, (list, tuple)) and len(setting) == 3:
                    settings_data.append({
                        'name': '' if setting[0] is None else str(setting[0]),
                        'value': '' if setting[1] is None else str(setting[1]),
                        'desc': '' if setting[2] is None else str(setting[2])
                    })
                else:
                    raise ValueError(
                        f"Setting {i} must be a dictionary or 3-item sequence"
                    )
            
            self._log_info(
                f"Successfully imported {len(settings_data)} project settings from {path}"
            )
            
            return settings_data
            
        except Exception as e:
            self._log_error(f"Failed to import project settings: {e}")
            return None
