import sys, os, subprocess, resource_rc, logging
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtCore import qInstallMessageHandler, QtMsgType
from src.modules.logger import get_instance
from src.models.prjsetmodel import PrjSetModel
from src.models.historymodel import HistoryModel
from src.modules.logic import AppLogic
from src.modules.translator import Translator
from src.modules.updater import UpdateManager

QML_FILE = Path(__file__).resolve().parent / "./qml/main.qml"

# Init LOGGER
logger = get_instance(__name__)


def qt_message_handler(msg_type, context, message):
    """Route Qt/QML diagnostic messages into Python's logging system."""
    qml_logger = logging.getLogger("qt")
    msg = str(message)
    if msg_type == QtMsgType.QtDebugMsg:
        qml_logger.debug(msg)
    elif msg_type == QtMsgType.QtWarningMsg:
        qml_logger.warning(msg)
    elif msg_type == QtMsgType.QtCriticalMsg:
        qml_logger.critical(msg)
    elif msg_type == QtMsgType.QtFatalMsg:
        qml_logger.fatal(msg)
    else:
        qml_logger.info(msg)


def restart_application():
    """Launch updater batch script and exit current process.
    The batch waits for this process to finish, replaces the .exe,
    and starts the new version."""
    logger.info("App restarting for update")
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

    # Route Qt/QML messages into Python logging
    qInstallMessageHandler(qt_message_handler)

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

    logger.info("App opened")
    engine.load(QML_FILE)

    if not engine.rootObjects():
        sys.exit(-1)

    app.exec()

    # LOG EXITAPP
    logger.info("App closed")
    sys.exit()
