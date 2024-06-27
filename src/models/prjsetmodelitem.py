from PySide6.QtCore import Property, QObject
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "PrjSetModelItem"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class PrjSetModelItem(QObject):
    def __init__(self, name, value, desc, parent=None):
        super().__init__(parent)
        self._name = name
        self._value = value
        self._desc = desc

    @Property(str)
    def name(self):
        return self._name

    @Property(str)
    def value(self):
        return self._value

    @Property(str)
    def desc(self):
        return self._desc