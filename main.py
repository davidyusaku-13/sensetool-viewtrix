import gc
import sys
import os
import resource_rc  # noqa: F401  (registers the qrc:/images resources)
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtCore import QTimer, qInstallMessageHandler, qFormatLogMessage
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from src.modules.logger import AppLogger
from src.app import create_services
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

def main(argv, organization="Viewtrix", close_after_ms=None):
    """Run the app; returns its exit code. close_after_ms closes the window by
    itself (used by the shutdown test)."""
    qInstallMessageHandler(qt_message_handler)
    app = QApplication(argv)
    app.setOrganizationName(organization)
    app.setOrganizationDomain(organization)

    engine = QQmlApplicationEngine()
    QQuickStyle.setStyle("Material")

    # Everything main.qml works with is created here and passed in as properties.
    translator = Translator(app, engine)
    updateManager = UpdateManager()
    updateManager.restartApplication.connect(restart_application)
    services = create_services()
    engine.setInitialProperties(dict(services, translator=translator, updateManager=updateManager))

    logger.log("App opened", "INFO")
    engine.load(QML_FILE)
    if not engine.rootObjects():
        return -1
    if close_after_ms is not None:
        QTimer.singleShot(close_after_ms, engine.rootObjects()[0].close)

    try:
        return app.exec()
    finally:
        # Destroy the QML first, while the models it binds to still exist. The
        # translator holds the engine too, so it has to go for the engine to go.
        del translator, engine
        gc.collect()
        logger.log("App closed", "INFO")
        del services, updateManager


if __name__ == "__main__":
    sys.exit(main(sys.argv))
