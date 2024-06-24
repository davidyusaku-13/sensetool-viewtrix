import sys
import resource_rc
import time
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from src.modules.logger import AppLogger
from src.models.prjsetmodel import PrjSetModel
from src.models.historymodel import HistoryModel
from src.modules.logic import AppLogic
from src.modules.translator import Translator

# CREATE ./logs FOLDER FOR LOGGING REQUIREMENTS
logs_dir = Path('./logs')
if not logs_dir.exists():
    logs_dir.mkdir(parents=True, exist_ok=True)

# Init LOGGER
logger = AppLogger.get_instance()
format = "[%(asctime)s] ___ %(levelname)s ___ %(message)s"
level = logger.level("INFO")
logger.configure_logging(level, format, "./logs/app.log")

if __name__ == "__main__":
    # DEFAULT QML LOAD``
    app = QApplication(sys.argv)
    
    # NEEDED BY QSETTINGS
    app.setOrganizationName("Viewtrix")
    app.setOrganizationDomain("Viewtrix")
    
    # LOG STARTAPP
    logger.log("App opened", level)

    # RUN main.qml
    engine = QQmlApplicationEngine()
    QQuickStyle.setStyle("Material")
    qml_file = Path(__file__).resolve().parent / "./qml/main.qml"

    translator = Translator(app, engine)
    engine.rootContext().setContextProperty("translator", translator)
    
    engine.load(qml_file)
    app.exec()

    if not engine.rootObjects():
        sys.exit(-1)

    # LOG EXITAPP
    logger.log("App closed", level)
    sys.exit()
