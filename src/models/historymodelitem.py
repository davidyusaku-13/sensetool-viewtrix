from PySide6.QtCore import Property, Slot, QModelIndex, QObject
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "HistoryModelItem"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class HistoryModelItem(QObject):
    def __init__(self, action, name, value, desc, time, history, parent=None):
        super().__init__(parent)
        self._action = action
        self._name = name
        self._value = value
        self._desc = desc
        self._time = time
        self._history = history

    @Property(str)
    def action(self):
        return self._action

    @Property(str)
    def name(self):
        return self._name

    @Property(str)
    def value(self):
        return self._value

    @Property(str)
    def desc(self):
        return self._desc

    @Property(str)
    def time(self):
        return self._time

    @Property(str)
    def history(self):
        return self._history