"""
Centralized logging configuration for SenseTool.

Initialized once via ``get_instance()`` — every subsequent call returns a
configured ``logging.Logger``, optionally named after the caller's module.

Configuration sources (first wins):
1. ``APP_LOG_LEVEL`` environment variable (e.g. ``DEBUG``, ``INFO``)
2. ``src/modules/config.ini`` (``fileConfig``-format, supports rotation + console)
3. Sensible hard-coded defaults (fallback)
"""

import logging
import logging.config
import logging.handlers
import os
import threading
from pathlib import Path

LOG_DIR = Path("./logs")
LOG_DIR.mkdir(parents=True, exist_ok=True)

CONFIG_PATH = Path(__file__).resolve().parent / "config.ini"

_initialized = False
_init_lock = threading.Lock()


def _configure() -> None:
    """Configure the root logger once."""
    log_file = str(LOG_DIR / "app.log").replace("\\", "/")

    if CONFIG_PATH.exists():
        logging.config.fileConfig(
            str(CONFIG_PATH),
            defaults={"logfilename": log_file},
            disable_existing_loggers=False,
        )
    else:
        handler = logging.handlers.RotatingFileHandler(
            log_file, maxBytes=1_000_000, backupCount=5
        )
        handler.setFormatter(
            logging.Formatter(
                "[%(asctime)s] ___ %(levelname)s [%(name)s] %(message)s",
                datefmt="%d-%m-%Y %H:%M:%S",
            )
        )
        root = logging.getLogger()
        root.setLevel(logging.INFO)
        root.addHandler(handler)

    # Environment variable overrides the configured level
    env_level = os.environ.get("APP_LOG_LEVEL", "").upper()
    if env_level in ("DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"):
        logging.getLogger().setLevel(getattr(logging, env_level))


def get_instance(name: str | None = None) -> logging.Logger:
    """Return a fully configured logger.

    Parameters
    ----------
    name : str, optional
        Logger name (typically ``__name__`` of the calling module).
        When *None* the root logger is returned.

    Returns
    -------
    logging.Logger
        Ready-to-use logger — call ``.info()``, ``.error()``, etc. directly.
    """
    global _initialized
    if not _initialized:
        with _init_lock:
            if not _initialized:
                _configure()
                _initialized = True
    return logging.getLogger(name)
