import sys, os, resource_rc
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtCore import qInstallMessageHandler, qFormatLogMessage
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from src.modules.logger import AppLogger
from src.models.prjsetmodel import PrjSetModel
from src.models.appsetmodel import AppSetModel
from src.models.historymodel import HistoryModel
from src.modules.logic import AppLogic
from src.modules.translator import Translator
from src.modules.updater import UpdateManager

QML_FILE = Path(__file__).resolve().parent / "./qml/main.qml"

# Init LOGGER
logger = AppLogger.get_instance()

# Qt's own non-native FileDialog (used on Linux without a native dialog) reports a
# harmless binding loop from its built-in overwrite-confirmation dialog, whose title
# (containing the file name) feeds its own width. Nothing in our QML can fix it, so
# drop exactly that message and print everything else as Qt normally would.
_QT_NOISE = ("Dialogs/quickimpl/qml/", 'Binding loop detected for property "implicitWidth"')

def qt_message_handler(mode, context, message):
    if all(part in message for part in _QT_NOISE):
        return
    print(qFormatLogMessage(mode, context, message), file=sys.stderr, flush=True)

def restart_application():
    logger.log("App restarted", "INFO")
    python = sys.executable
    os.execl(python, python, *sys.argv)

if __name__ == "__main__":
    qInstallMessageHandler(qt_message_handler)
    app = QApplication(sys.argv)

    app.setOrganizationName("Viewtrix")
    app.setOrganizationDomain("Viewtrix")

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
