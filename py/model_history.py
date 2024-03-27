from PySide6.QtCore import Qt, QAbstractListModel, Signal, Property, Slot, QModelIndex, QObject
from PySide6.QtQml import QmlElement
from logger import AppLogger
import yaml
import datetime

QML_IMPORT_NAME = "HistoryModel"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()
format = "[%(asctime)s] ___ %(levelname)s ___ %(message)s"
level = logger.level("INFO")

current_time = datetime.datetime.now().strftime("%A, %d-%m-%Y %H:%M:%S")


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


@QmlElement
class HistoryModel(QAbstractListModel):
    dataChanged = Signal(QModelIndex, QModelIndex)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []

    def rowCount(self, parent=QModelIndex()):
        return len(self._items)

    def data(self, index, role=Qt.DisplayRole):
        if not (0 <= index.row() < len(self._items)):
            return
        if role == Qt.DisplayRole:
            return self._items[index.row()].action
        elif role == Qt.UserRole + 1:
            return self._items[index.row()].name
        elif role == Qt.UserRole + 2:
            return self._items[index.row()].value
        elif role == Qt.UserRole + 3:
            return self._items[index.row()].desc
        elif role == Qt.UserRole + 4:
            return self._items[index.row()].time
        elif role == Qt.UserRole + 5:
            return self._items[index.row()].history

    def roleNames(self):
        roles = super().roleNames()
        roles.update({
            Qt.DisplayRole: b"action",
            Qt.UserRole + 1: b"name",
            Qt.UserRole + 2: b"value",
            Qt.UserRole + 3: b"desc",
            Qt.UserRole + 4: b"time",
            Qt.UserRole + 5: b"history"
        })
        return roles

    @Slot(str, str, str, str)
    def addHistory(self, action, name, value, desc):
        action = action if action != None else ""
        name = name if name != None else ""
        value = value if value != None else ""
        desc = desc if desc != None else ""
        tmp = f"{action}: {name} - {value} - {desc} on {current_time}"
        logger.log(f"Added history: {action}: {
                   name} - {value} - {desc} on {current_time}", level)
        self.beginInsertRows(QModelIndex(), len(self._items), len(self._items))
        item = HistoryModelItem(action, name, value,
                                desc, current_time, tmp, self)
        self._items.append(item)
        self.endInsertRows()

    @Slot()
    def clear(self):
        self.beginResetModel()
        self._items = []
        self.endResetModel()
