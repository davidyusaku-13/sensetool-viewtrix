import sys
import resource_rc
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from src.modules.logger import AppLogger
from src.models.prjsetmodel import PrjSetModel
from src.models.historymodel import HistoryModel
from src.modules.logic import AppLogic
from PySide6.QtCore import QTranslator, QLocale

# CREATE ./logs FOLDER FOR LOGGING REQUIREMENTS
logs_dir = Path('./logs')
if not logs_dir.exists():
    logs_dir.mkdir(parents=True, exist_ok=True)

logger = AppLogger.get_instance()
format = "[%(asctime)s] ___ %(levelname)s ___ %(message)s"
level = logger.level("INFO")
logger.configure_logging(level, format, "./logs/app.log")

if __name__ == "__main__":
    # DEFAULT QML LOAD``
    app = QApplication(sys.argv)

    # Inisialisasi QTranslator
    translator = QTranslator()
    translation_file = Path(__file__).resolve().parent / "translations/app_id.qm"
    
    if translator.load("translations/app_id.qm"):
        app.installTranslator(translator)
    else:
        print("Translation file loading failed")

    # Fungsi untuk mengganti bahasa
    def change_language(language_code):
        translator = QTranslator()
        if language_code == "en":
            translation_file = "./translations/app_en.qm"
        elif language_code == "id":
            translation_file = "./translations/app_id.qm"
        else:
            print(f"Language {language_code} is not supported.")
            return

        if translator.load(translation_file):
            app = QApplication.instance()
            app.installTranslator(translator)
            app.setProperty("language", language_code)  # Opsional: set properti bahasa
        else:
            print(f"Failed to load translation file: {translation_file}")

    # Contoh penggunaan: mengganti bahasa ke bahasa Inggris ("en")
    change_language("id")
    
    # NEEDED BY QSETTINGS
    app.setOrganizationName("Viewtrix")
    app.setOrganizationDomain("Viewtrix")
    
    # RUN main.qml
    engine = QQmlApplicationEngine()
    QQuickStyle.setStyle("Material")
    qml_file = Path(__file__).resolve().parent / "./qml/main.qml"

    # LOG STARTAPP
    logger.log("App opened", level)
    engine.load(qml_file)
    # engine.addImportPath("qml")
    app.exec()

    if not engine.rootObjects():
        sys.exit(-1)

    # LOG EXITAPP
    logger.log("App closed", level)
    sys.exit()
