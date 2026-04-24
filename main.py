import sys, os, resource_rc
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from src.core.config import get_config_manager
from src.modules.logger import AppLogger
from src.models.prjsetmodel import PrjSetModel
from src.models.historymodel import HistoryModel
from src.modules.logic import AppLogic
from src.modules.translator import Translator
from src.modules.updater import UpdateManager

QML_FILE = Path(__file__).resolve().parent / "./qml/main.qml"

# Initialize configuration and logger
config = get_config_manager()
logger = AppLogger.get_instance()

def restart_application():
    """Restart the application."""
    logger.log("App restarted", "INFO")
    python = sys.executable
    os.execl(python, python, *sys.argv)

if __name__ == "__main__":
    try:
        app = QApplication(sys.argv)

        # Configure application metadata
        app.setOrganizationName(config.config.organization_name)
        app.setOrganizationDomain(config.config.organization_domain)
        app.setApplicationName(config.config.app_name)

        # Initialize QML engine and styling
        engine = QQmlApplicationEngine()
        QQuickStyle.setStyle(config.config.theme_style)

        # Initialize and register components
        translator = Translator(app, engine)
        engine.rootContext().setContextProperty("translator", translator)

        updateManager = UpdateManager()
        engine.rootContext().setContextProperty("updateManager", updateManager)

        logger.log("App opened", "INFO")
        engine.load(QML_FILE)

        if not engine.rootObjects():
            logger.log("Failed to load QML file", "ERROR")
            sys.exit(-1)

        # Run application
        exit_code = app.exec()
        
        logger.log("App closed", "INFO")
        sys.exit(exit_code)
        
    except Exception as e:
        logger.log(f"Critical error during application startup: {e}", "ERROR")
        sys.exit(-1)
