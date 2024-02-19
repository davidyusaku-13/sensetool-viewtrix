import threading
import logging
import logging.config
from logging.handlers import RotatingFileHandler


class CustomLogger:
    _instance = None
    _lock = threading.Lock()

    @staticmethod
    def get_instance():
        if CustomLogger._instance is None:
            with CustomLogger._lock:
                if CustomLogger._instance is None:
                    CustomLogger._instance = CustomLogger()
        return CustomLogger._instance

    def level(self, val):
        levels = {
            "DEBUG": logging.DEBUG,
            "INFO": logging.INFO,
            "WARNING": logging.WARNING,
            "ERROR": logging.ERROR,
            "CRITICAL": logging.CRITICAL,
        }
        return levels.get(val, logging.INFO)

    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def configure_logging(self, level=logging.INFO, format="[%(asctime)s] ___ %(levelname)s ___ %(message)s", output="output.log"):
        self.logger.setLevel(level)
        formatter = logging.Formatter(f"{format}", datefmt='%d-%m-%Y %H:%M:%S')
        handler = RotatingFileHandler(output, maxBytes=1e6, backupCount=5)
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)

    def log(self, message, log_level=logging.INFO, *args):
        if log_level in [logging.DEBUG, logging.INFO, logging.WARNING, logging.ERROR, logging.CRITICAL]:
            try:
                self.logger.log(log_level, message, *args)
            except Exception as e:
                self.logger.exception(f"Error occurred during logging: {e}")

    def log_exception(self, e):
        self.logger.exception(f"An exception occurred: {e}")
