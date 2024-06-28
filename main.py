import sys, os, resource_rc
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from src.modules.logger import AppLogger
from src.models.prjsetmodel import PrjSetModel
from src.models.historymodel import HistoryModel
from src.modules.logic import AppLogic
from src.modules.translator import Translator
from src.modules.updater import UpdateManager

# Init LOGGER
logger = AppLogger.get_instance()

def restart_application():
    logger.log("App restarted", "INFO")
    python = sys.executable
    os.execl(python, python, *sys.argv)
    
if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    app.setOrganizationName("Viewtrix")
    app.setOrganizationDomain("Viewtrix")

    engine = QQmlApplicationEngine()
    QQuickStyle.setStyle("Material")
    qml_file = Path(__file__).resolve().parent / "./qml/main.qml"
    
    translator = Translator(app, engine)
    engine.rootContext().setContextProperty("translator", translator)
    
    updateManager = UpdateManager()
    updateManager.restartApplication.connect(restart_application)
    engine.rootContext().setContextProperty("updateManager", updateManager)
    
    logger.log("App opened", "INFO")
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)
        
    app.exec()
    
    # LOG EXITAPP
    logger.log("App closed", "INFO")
    sys.exit()