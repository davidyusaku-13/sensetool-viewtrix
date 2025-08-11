"""Base classes for SenseTool application.

This module provides base classes that implement common functionality
for QML-exposed Python objects and models.
"""

from abc import ABC, abstractmethod
from typing import Any, Dict, Optional
from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtQml import QmlElement
from .config import get_config_manager
from ..modules.logger import AppLogger


class BaseQmlObject(QObject):
    """Base class for QML-exposed objects.
    
    Provides common functionality like logging, configuration access,
    and error handling for all QML-exposed Python objects.
    """
    
    # Common signals
    errorOccurred = Signal(str, arguments=['message'])
    operationCompleted = Signal(str, arguments=['operation'])
    
    def __init__(self, parent: Optional[QObject] = None):
        """Initialize base QML object.
        
        Args:
            parent: Parent QObject
        """
        super().__init__(parent)
        self._logger = AppLogger.get_instance()
        self._config = get_config_manager()
        self._initialized = False
    
    @Property(bool, notify=operationCompleted)
    def initialized(self) -> bool:
        """Check if object is initialized.
        
        Returns:
            True if object is initialized
        """
        return self._initialized
    
    def _log_info(self, message: str) -> None:
        """Log info message.
        
        Args:
            message: Message to log
        """
        self._logger.log(f"{self.__class__.__name__}: {message}", "INFO")
    
    def _log_error(self, message: str) -> None:
        """Log error message and emit error signal.
        
        Args:
            message: Error message to log
        """
        self._logger.log(f"{self.__class__.__name__}: {message}", "ERROR")
        self.errorOccurred.emit(message)
    
    def _log_debug(self, message: str) -> None:
        """Log debug message.
        
        Args:
            message: Debug message to log
        """
        self._logger.log(f"{self.__class__.__name__}: {message}", "DEBUG")
    
    @Slot()
    def initialize(self) -> None:
        """Initialize the object.
        
        Override this method in subclasses to provide custom initialization.
        """
        if not self._initialized:
            self._perform_initialization()
            self._initialized = True
            self.operationCompleted.emit("initialization")
            self._log_info("Object initialized successfully")
    
    def _perform_initialization(self) -> None:
        """Perform actual initialization.
        
        Override this method in subclasses for custom initialization logic.
        """
        pass
    
    @Slot(result=str)
    def getClassName(self) -> str:
        """Get class name for debugging.
        
        Returns:
            Class name
        """
        return self.__class__.__name__


class BaseService(ABC):
    """Base class for application services.
    
    Provides common functionality for service classes that handle
    business logic and data operations.
    """
    
    def __init__(self):
        """Initialize base service."""
        self._logger = AppLogger.get_instance()
        self._config = get_config_manager()
    
    @abstractmethod
    def initialize(self) -> bool:
        """Initialize the service.
        
        Returns:
            True if initialization was successful
        """
        pass
    
    def _log_info(self, message: str) -> None:
        """Log info message.
        
        Args:
            message: Message to log
        """
        self._logger.log(f"{self.__class__.__name__}: {message}", "INFO")
    
    def _log_error(self, message: str) -> None:
        """Log error message.
        
        Args:
            message: Error message to log
        """
        self._logger.log(f"{self.__class__.__name__}: {message}", "ERROR")
    
    def _log_debug(self, message: str) -> None:
        """Log debug message.
        
        Args:
            message: Debug message to log
        """
        self._logger.log(f"{self.__class__.__name__}: {message}", "DEBUG")


class ValidationMixin:
    """Mixin class for input validation.
    
    Provides common validation methods that can be used
    across different classes.
    """
    
    @staticmethod
    def validate_positive_number(value: Any, name: str = "value") -> float:
        """Validate that a value is a positive number.
        
        Args:
            value: Value to validate
            name: Name of the value for error messages
            
        Returns:
            Validated float value
            
        Raises:
            ValueError: If value is not a positive number
        """
        try:
            num_value = float(value)
            if num_value <= 0:
                raise ValueError(f"{name} must be positive, got {num_value}")
            return num_value
        except (TypeError, ValueError) as e:
            raise ValueError(f"Invalid {name}: {e}")
    
    @staticmethod
    def validate_integer_range(value: Any, min_val: int, max_val: int, name: str = "value") -> int:
        """Validate that a value is an integer within a specific range.
        
        Args:
            value: Value to validate
            min_val: Minimum allowed value
            max_val: Maximum allowed value
            name: Name of the value for error messages
            
        Returns:
            Validated integer value
            
        Raises:
            ValueError: If value is not within the specified range
        """
        try:
            int_value = int(value)
            if not (min_val <= int_value <= max_val):
                raise ValueError(f"{name} must be between {min_val} and {max_val}, got {int_value}")
            return int_value
        except (TypeError, ValueError) as e:
            raise ValueError(f"Invalid {name}: {e}")
    
    @staticmethod
    def validate_string_not_empty(value: Any, name: str = "value") -> str:
        """Validate that a value is a non-empty string.
        
        Args:
            value: Value to validate
            name: Name of the value for error messages
            
        Returns:
            Validated string value
            
        Raises:
            ValueError: If value is not a non-empty string
        """
        if not isinstance(value, str) or not value.strip():
            raise ValueError(f"{name} must be a non-empty string")
        return value.strip()