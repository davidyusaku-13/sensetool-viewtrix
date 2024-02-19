from PySide6.QtCore import Qt, QAbstractListModel, Signal, Property, Slot, QModelIndex, QObject
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "PrjSetModel"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class PrjSetModelItem(QObject):
    def __init__(self, setitem, val, desc, parent=None):
        super().__init__(parent)
        self._setitem = setitem
        self._val = val
        self._desc = desc

    @Property(str)
    def setitem(self):
        return self._setitem

    @Property(str)
    def val(self):
        return self._val

    @Property(str)
    def desc(self):
        return self._desc


@QmlElement
class PrjSetModel(QAbstractListModel):
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
            return self._items[index.row()].setitem
        elif role == Qt.UserRole + 1:
            return self._items[index.row()].val
        elif role == Qt.UserRole + 2:
            return self._items[index.row()].desc

    def roleNames(self):
        roles = super().roleNames()
        roles.update({
            Qt.DisplayRole: b"setitem",
            Qt.UserRole + 1: b"val",
            Qt.UserRole + 2: b"desc"
        })
        return roles

    @Slot(str, str, str)
    def addItem(self, setitem, val, desc):
        self.beginInsertRows(QModelIndex(), len(self._items), len(self._items))
        item = PrjSetModelItem(setitem, val, desc, self)
        self._items.append(item)
        self.endInsertRows()

    @Slot(int)
    def removeItem(self, index):
        if 0 <= index < len(self._items):
            self.beginRemoveRows(QModelIndex(), index, index)
            del self._items[index]
            self.endRemoveRows()

    @Slot()
    def clear(self):
        self.beginResetModel()
        self._items = []
        self.endResetModel()

    @Property(QObject, constant=True)
    def items(self):
        return self

    @Property(list, constant=True)
    def itemsData(self):
        return [(item.setitem, item.val, item.desc) for item in self._items]
