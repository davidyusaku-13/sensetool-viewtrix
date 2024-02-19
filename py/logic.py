from PySide6.QtCore import Slot, QObject
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "AppLogic"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class AppLogic(QObject):
    def __init__(self):
        super().__init__()
