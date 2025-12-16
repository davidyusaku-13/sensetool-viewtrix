from PySide6.QtCore import Qt, QAbstractListModel, Signal, Slot, QModelIndex
from PySide6.QtQml import QmlElement
from typing import List, Optional
from .historymodelitem import HistoryModelItem
from ..core.mixins import LoggingMixin
import datetime

QML_IMPORT_NAME = "HistoryModel"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class HistoryModel(QAbstractListModel, LoggingMixin):
    dataChanged = Signal(QModelIndex, QModelIndex)
    errorOccurred = Signal(str, arguments=['message'])
    operationCompleted = Signal(str, arguments=['operation'])

    def __init__(self, parent=None):
        QAbstractListModel.__init__(self, parent)
        LoggingMixin.__init__(self)
        self._items: List[HistoryModelItem] = []

    def _log_error(self, message: str) -> None:
        """Log error message and emit error signal."""
        self._logger.log(f"{self.__class__.__name__}: {message}", "ERROR")
        self.errorOccurred.emit(message)

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        """Return the number of history items."""
        return len(self._items)

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        """Return data for the given index and role."""
        if not (0 <= index.row() < len(self._items)):
            return None
        
        item = self._items[index.row()]
        if role == Qt.DisplayRole:
            return item.action
        elif role == Qt.UserRole + 1:
            return item.name
        elif role == Qt.UserRole + 2:
            return item.value
        elif role == Qt.UserRole + 3:
            return item.desc
        elif role == Qt.UserRole + 4:
            return item.time
        elif role == Qt.UserRole + 5:
            return item.history
        return None

    def roleNames(self) -> dict:
        """Return role names for QML access."""
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
    def addHistory(self, action: str, name: str, value: str, desc: str) -> None:
        """Add a new history entry."""
        try:
            action = action if action is not None else ""
            name = name if name is not None else ""
            value = value if value is not None else ""
            desc = desc if desc is not None else ""
            
            current_time = datetime.datetime.now().strftime("%A, %d-%m-%Y %H:%M:%S")
            tmp = f"{action}: {name} - {value} - {desc} on {current_time}"
            
            self.beginInsertRows(QModelIndex(), len(self._items), len(self._items))
            item = HistoryModelItem(action, name, value, desc, current_time, tmp, self)
            self._items.append(item)
            self.endInsertRows()
            
            self._log_info(f"Added history entry: {action}")
        except Exception as e:
            self._log_error(f"Failed to add history entry: {e}")

    @Slot()
    def clear(self) -> None:
        """Clear all history entries."""
        try:
            self.beginResetModel()
            self._items = []
            self.endResetModel()
            self._log_info("Cleared all history entries")
        except Exception as e:
            self._log_error(f"Failed to clear history entries: {e}")
            self.endResetModel()
