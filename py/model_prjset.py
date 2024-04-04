from PySide6.QtCore import Qt, QAbstractListModel, Signal, Property, Slot, QModelIndex, QObject, QUrl
from PySide6.QtQml import QmlElement
from logger import AppLogger
from model_history import HistoryModel
import yaml

QML_IMPORT_NAME = "PrjSetModel"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()
format = "[%(asctime)s] ___ %(levelname)s ___ %(message)s"
level = logger.level("INFO")


@QmlElement
class PrjSetModelItem(QObject):
    def __init__(self, name, value, desc, selectState, parent=None):
        super().__init__(parent)
        self._name = name
        self._value = value
        self._desc = desc
        self._selectState = selectState

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
    def selectState(self):
        return self._selectState


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
            return self._items[index.row()].name
        elif role == Qt.UserRole + 1:
            return self._items[index.row()].value
        elif role == Qt.UserRole + 2:
            return self._items[index.row()].desc
        elif role == Qt.UserRole + 3:
            return self._items[index.row()].selectState

    def roleNames(self):
        roles = super().roleNames()
        roles.update({
            Qt.DisplayRole: b"name",
            Qt.UserRole + 1: b"value",
            Qt.UserRole + 2: b"desc",
            Qt.UserRole + 3: b"selectState"
        })
        return roles

    @Slot(int, result=QObject)
    def get(self, index):
        if 0 <= index < len(self._items):
            return self._items[index]
        return None

    @Slot(int, int, result=bool)
    def move(self, source: int, target: int):
        """Slot to move a single row from source to target"""
        return self.moveRow(QModelIndex(), source, QModelIndex(), target)

    def moveRow(self, sourceParent, sourceRow, dstParent, dstChild):
        """Move a single row"""
        return self.moveRows(sourceParent, sourceRow, 0, dstParent, dstChild)

    def moveRows(self, sourceParent, sourceRow, count, dstParent, dstChild):
        """Move n rows (n=1+ count)  from sourceRow to dstChild"""

        if sourceRow == dstChild:
            return False

        elif sourceRow > dstChild:
            end = dstChild

        else:
            end = dstChild + 1

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

    def flags(self) -> Qt.ItemFlag:
        flag = super().flags()
        flag |= Qt.ItemIsDragEnabled | Qt.ItemIsDropEnabled
        return flag

    @Slot(str, str, str, str)
    def addItem(self, name, value, desc, selectState):
        logger.log(f"Added item: {name} - {value} - {desc}", level)
        self.beginInsertRows(QModelIndex(), len(self._items), len(self._items))
        item = PrjSetModelItem(name, value, desc, selectState, self)
        self._items.append(item)
        self.endInsertRows()

    @Slot(int, str, str, str)
    def edit(self, index, name, value, desc):
        if 0 <= index < len(self._items):
            item = self._items[index]
            item._name = name
            item._value = value
            item._desc = desc
            self.dataChanged.emit(self.index(index, 0), self.index(index, 0))
            logger.log(f"Edited item at index {index}: {
                       name} - {value} - {desc}", level)
        else:
            logger.log(f"Attempt to edit item at invalid index {index}", level)

    @Slot(int)
    def removeItem(self, index):
        if 0 <= index < len(self._items):
            self.beginRemoveRows(QModelIndex(), index, index)
            del self._items[index]
            self.endRemoveRows()

    @Slot(int, str)
    def editState(self, index, new_state):
        if 0 <= index < len(self._items):
            self._items[index]._selectState = new_state
            self.dataChanged.emit(self.index(index, 0), self.index(index, 0))

    @Slot()
    def deselectAll(self):
        for i, item in enumerate(self._items):
            item._selectState = "false"
            self.dataChanged.emit(self.index(i, 0), self.index(i, 0))

    @Slot()
    def selectAll(self):
        for i, item in enumerate(self._items):
            item._selectState = "true"
            self.dataChanged.emit(self.index(i, 0), self.index(i, 0))

    @Slot()
    def clear(self):
        self.beginResetModel()
        self._items = []
        self.endResetModel()

    @Slot(QUrl)
    def exportYAML(self, file: QUrl):
        file_name = file.toLocalFile()
        logger.log(f"Exported file: {file_name}", level)
        yaml_data = {
            'title': 'Project Settings',
            'desc': "Project Setting includes the static information which is not be changed during runtime. "
            "This parameter should be set during the project development phase and fixed after project deployment. "
            "A file prjset.h shall be generated by script.",
            'data': []
        }
        items_data = self.itemsData
        for item_data in items_data:
            pName, pVal, pDesc, pState = item_data
            yaml_item = {
                'name': pName,
                'value': pVal,
                'desc': pDesc if pDesc != "" else None
            }
            yaml_data['data'].append(yaml_item)
        with open(file_name, 'w') as file:
            yaml.dump(yaml_data, file, sort_keys=False)

    @Slot(QUrl)
    def importYAML(self, file: QUrl):
        file = file.toLocalFile()
        try:
            with open(file, 'r') as yaml_file:
                yaml_data = yaml.load(yaml_file, Loader=yaml.FullLoader)
                if isinstance(yaml_data['data'], list):
                    for item in yaml_data['data']:
                        pName = item['name']
                        pVal = item['value']
                        pDesc = item['desc'] if item['desc'] != None else ""
                        pState = "false"
                        self.addItem(pName, pVal, pDesc, pState)
                else:
                    print("Invalid YAML format. Expected a list.")
        except FileNotFoundError:
            print("File not found:", file)
        except yaml.YAMLError as e:
            print("Error loading YAML:", e)

    @Property(QObject, constant=True)
    def items(self):
        return self

    @Property(list, constant=True)
    def itemsData(self):
        return [(item.name, item.value, item.desc, item.selectState) for item in self._items]
