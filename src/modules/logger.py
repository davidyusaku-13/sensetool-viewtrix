import logging
import os
from logging.handlers import RotatingFileHandler
from pathlib import Path

# CREATE ./logs FOLDER FOR LOGGING REQUIREMENTS
LOG_DIR = Path('./logs')
if not LOG_DIR.exists():
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    
class AppLogger:
    _instance = None

    _LEVEL_MAP = {
        "INFO": logging.INFO,
        "DEBUG": logging.DEBUG,
        "WARNING": logging.WARNING,
        "ERROR": logging.ERROR,
        "CRITICAL": logging.CRITICAL
    }

    @staticmethod
    def get_instance():
        if AppLogger._instance is None:
            AppLogger._instance = AppLogger()
        return AppLogger._instance

    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.configure_logging()

    def configure_logging(self, level="INFO", format="[%(asctime)s] ___ %(levelname)s ___ %(message)s", output=LOG_DIR / 'app.log'):
        if level not in self._LEVEL_MAP:
            raise ValueError(f"Invalid log level: {level}")

        self.logger.setLevel(self._LEVEL_MAP[level])
        formatter = logging.Formatter(f"{format}", datefmt='%d-%m-%Y %H:%M:%S')
        handler = RotatingFileHandler(output, maxBytes=1e6, backupCount=5)
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)

    def log(self, message, level="INFO", *args):
        if level not in self._LEVEL_MAP:
            raise ValueError(f"Invalid log level: {level}")
        try:
            self.logger.log(self._LEVEL_MAP[level], message, *args)
        except Exception as e:
            self.logger.exception(f"Error occurred during logging: {e}")