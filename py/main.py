import sys
import resource_rc
from pathlib import Path
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from logger import AppLogger
from model import PrjSetModel
from logic import AppLogic

logger = AppLogger.get_instance()
format = "[%(asctime)s] ___ %(levelname)s ___ %(message)s"
level = logger.level("INFO")
logger.configure_logging(level, format, "app.log")

if __name__ == "__main__":
    # DEFAULT QML LOAD
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "../qmls/main.qml"

    # LOG STARTAPP
    logger.log("App opened", level)
    engine.load(qml_file)
    app.exec()

    if not engine.rootObjects():
        sys.exit(-1)

    # LOG EXITAPP
    logger.log("App closed", level)
    sys.exit()
