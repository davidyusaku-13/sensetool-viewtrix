import sys, os, subprocess, resource_rc
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

QML_FILE = Path(__file__).resolve().parent / "./qml/main.qml"

# Init LOGGER
logger = AppLogger.get_instance()

def restart_application():
    """Launch updater batch script and exit current process.
    The batch waits for this process to finish, replaces the .exe,
    and starts the new version."""
    logger.log("App restarting for update", "INFO")
    bat_path = os.path.join(os.getcwd(), "restart_update.bat")
    with open(bat_path, "w") as f:
        f.write('@echo off\r\n')
        f.write('ping 127.0.0.1 -n 4 > nul\r\n')
        f.write('if exist "sensetool_update.exe" (\r\n')
        f.write('    move /Y "sensetool_update.exe" "sensetool.exe" > nul\r\n')
        f.write(')\r\n')
        f.write('start "" "sensetool.exe"\r\n')
        f.write('del "%~f0"\r\n')
    subprocess.Popen(['cmd.exe', '/c', bat_path],
                     creationflags=subprocess.CREATE_NO_WINDOW)
    sys.exit(0)

if __name__ == "__main__":
    app = QApplication(sys.argv)

    app.setOrganizationName("Viewtrix")
    app.setOrganizationDomain("Viewtrix")

    # Finalize any pending update before loading UI
    pending_update = UpdateManager()
    pending_update.finalize_update()
    del pending_update

    engine = QQmlApplicationEngine()
    QQuickStyle.setStyle("Material")

    translator = Translator(app, engine)
    engine.rootContext().setContextProperty("translator", translator)

    updateManager = UpdateManager()
    updateManager.restartApplication.connect(restart_application)
    engine.rootContext().setContextProperty("updateManager", updateManager)

    logger.log("App opened", "INFO")
    engine.load(QML_FILE)

    if not engine.rootObjects():
        sys.exit(-1)

    app.exec()

    # LOG EXITAPP
    logger.log("App closed", "INFO")
    sys.exit()
