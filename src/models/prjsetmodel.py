from PySide6.QtCore import Qt, QAbstractListModel, Slot, QModelIndex, QObject, QUrl, Signal
from PySide6.QtQml import QmlElement
from typing import List, Tuple, Optional
from ..services.file_service import FileService
from ..modules.logger import AppLogger
from .prjsetmodelitem import PrjSetModelItem
from .historymodel import HistoryModel

QML_IMPORT_NAME = "PrjSetModel"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class PrjSetModel(QAbstractListModel):
    errorOccurred = Signal(str, arguments=['message'])
    operationCompleted = Signal(str, arguments=['operation'])

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items: List[PrjSetModelItem] = []
        self._file_service = FileService()
        self._logger = AppLogger.get_instance()
    
    def _log_info(self, message: str) -> None:
        """Log info message."""
        self._logger.log(f"{self.__class__.__name__}: {message}", "INFO")
    
    def _log_error(self, message: str) -> None:
        """Log error message and emit error signal."""
        self._logger.log(f"{self.__class__.__name__}: {message}", "ERROR")
        self.errorOccurred.emit(message)
    
    def _log_debug(self, message: str) -> None:
        """Log debug message."""
        self._logger.log(f"{self.__class__.__name__}: {message}", "DEBUG")

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        """Return the number of items in the model."""
        return len(self._items)

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        """Return data for the given index and role."""
        if not (0 <= index.row() < len(self._items)):
            return None
        
        item = self._items[index.row()]
        if role == Qt.DisplayRole:
            return item.name
        elif role == Qt.UserRole + 1:
            return item.value
        elif role == Qt.UserRole + 2:
            return item.desc
        return None

    def roleNames(self) -> dict:
        """Return role names for QML access."""
        roles = super().roleNames()
        roles.update({
            Qt.DisplayRole: b"name",
            Qt.UserRole + 1: b"value",
            Qt.UserRole + 2: b"desc"
        })
        return roles
    
    @property
    def itemsData(self) -> List[Tuple[str, str, str]]:
        """Return all items data as tuples."""
        return [(item.name, item.value, item.desc) for item in self._items]

    @Slot(int, int, result=bool)
    def move(self, source: int, target: int) -> bool:
        """Move a single row from source to target.
        
        Args:
            source: Source row index
            target: Target row index
            
        Returns:
            True if move was successful, False otherwise
        """
        return self.moveRow(QModelIndex(), source, QModelIndex(), target)

    def moveRow(self, sourceParent: QModelIndex, sourceRow: int, 
               dstParent: QModelIndex, dstChild: int) -> bool:
        """Move a single row."""
        return self.moveRows(sourceParent, sourceRow, 0, dstParent, dstChild)

    def moveRows(self, sourceParent: QModelIndex, sourceRow: int, count: int, 
                dstParent: QModelIndex, dstChild: int) -> bool:
        """Move n rows from sourceRow to dstChild.
        
        Args:
            sourceParent: Source parent index
            sourceRow: Source row index
            count: Number of rows to move
            dstParent: Destination parent index
            dstChild: Destination row index
            
        Returns:
            True if move was successful, False otherwise
        """
        if sourceRow == dstChild or not (0 <= sourceRow < len(self._items)):
            return False

        end = dstChild if sourceRow > dstChild else dstChild + 1

        self.beginMoveRows(QModelIndex(), sourceRow,
                           sourceRow + count, QModelIndex(), end)

        pops = self._items[sourceRow: sourceRow + count + 1]
        if sourceRow > dstChild:
            self._items = (
                self._items[:dstChild]
                + pops
                + self._items[dstChild:sourceRow]
                + self._items[sourceRow + count + 1:]
            )
        else:
            start = self._items[:sourceRow]
            middle = self._items[dstChild: dstChild + 1]
            endlist = self._items[dstChild + count + 1:]
            self._items = start + middle + pops + endlist

        self.endMoveRows()
        return True

    @Slot(int, result=QObject)
    def get(self, index: int) -> Optional[QObject]:
        """Get item at the specified index.
        
        Args:
            index: Item index
            
        Returns:
            Item at index or None if invalid index
        """
        if 0 <= index < len(self._items):
            return self._items[index]
        else:
            self._log_warning(f"Attempt to access item at invalid index {index}")
            return None

    def flags(self, index: QModelIndex = QModelIndex()) -> Qt.ItemFlag:
        """Return item flags for drag and drop support."""
        flag = super().flags(index)
        flag |= Qt.ItemIsDragEnabled | Qt.ItemIsDropEnabled
        return flag

    @Slot(str, str, str)
    def addItem(self, name: str, value: str, desc: str) -> None:
        """Add a new item to the model.
        
        Args:
            name: Item name
            value: Item value
            desc: Item description
        """
        try:
            self._log_info(f"Adding item: {name} - {value} - {desc}")
            self.beginInsertRows(QModelIndex(), len(self._items), len(self._items))
            item = PrjSetModelItem(name, value, desc, self)
            self._items.append(item)
            self.endInsertRows()
        except Exception as e:
            self._log_error(f"Failed to add item: {e}")

    @Slot(int, str, str, str)
    def edit(self, index: int, name: str, value: str, desc: str) -> None:
        """Edit an existing item.
        
        Args:
            index: Item index
            name: New item name
            value: New item value
            desc: New item description
        """
        try:
            if 0 <= index < len(self._items):
                self._log_info(f"Editing item at index {index}: {name} - {value} - {desc}")
                item = self._items[index]
                item._name = name
                item._value = value
                item._desc = desc
                self.dataChanged.emit(self.index(index, 0), self.index(index, 0))
            else:
                self._log_error(f"Attempt to edit item at invalid index {index}")
        except Exception as e:
            self._log_error(f"Failed to edit item: {e}")

    @Slot(int)
    def removeItem(self, index: int) -> None:
        """Remove an item from the model.
        
        Args:
            index: Item index to remove
        """
        try:
            if 0 <= index < len(self._items):
                self.beginRemoveRows(QModelIndex(), index, index)
                self._log_info(f"Removing item at index {index}")
                del self._items[index]
                self.endRemoveRows()
            else:
                self._log_error(f"Attempt to remove item at invalid index {index}")
        except Exception as e:
            self._log_error(f"Failed to remove item: {e}")

    @Slot()
    def clear(self) -> None:
        """Clear all items from the model."""
        try:
            self._log_info("Clearing all items")
            self.beginResetModel()
            self._items = []
            self.endResetModel()
        except Exception as e:
            self._log_error(f"Failed to clear items: {e}")

    @Slot(QUrl)
    def exportYAML(self, file: QUrl) -> None:
        """Export project settings to YAML file.
        
        Args:
            file: File URL to export to
        """
        try:
            items_data = self.itemsData
            success = self._file_service.export_project_settings(file, items_data)
            if success:
                self._log_info(f"Exported project settings to {file.toLocalFile()}")
            else:
                self._log_error("Failed to export project settings")
        except Exception as e:
            self._log_error(f"Failed to export project settings: {e}")

    @Slot(QUrl)
    def importYAML(self, file: QUrl) -> None:
        """Import project settings from YAML file.
        
        Args:
            file: File URL to import from
        """
        try:
            items_data = self._file_service.import_project_settings(file)
            if items_data:
                self._log_info(f"Imported project settings from {file.toLocalFile()}")
                for name, value, desc in items_data:
                    self.addItem(name, value, desc)
            else:
                self._log_error("Failed to import project settings")
        except Exception as e:
             self._log_error(f"Failed to import project settings: {e}")
