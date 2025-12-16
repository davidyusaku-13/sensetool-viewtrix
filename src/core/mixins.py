"""Mixin classes for SenseTool application."""

from ..modules.logger import AppLogger


class LoggingMixin:
    """Mixin class for logging functionality.

    Provides common logging methods that can be used across different classes.
    """

    def __init__(self):
        """Initialize logging mixin."""
        if not hasattr(self, '_logger'):
            self._logger = AppLogger.get_instance()

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
