"""A small list model of plain dicts, for tables whose rows are simple records
(scan items, arrangements, steps). Changes are reported row by row, so views
keep their selection and scroll position."""
from PySide6.QtCore import QAbstractListModel, QModelIndex, Qt, Slot


class DictListModel(QAbstractListModel):
    def __init__(self, roles, parent=None):
        super().__init__(parent)
        self._roles = list(roles)
        self._rows = []

    def rowCount(self, parent=QModelIndex()):
        return 0 if parent.isValid() else len(self._rows)

    def roleNames(self):
        return {Qt.UserRole + 1 + i: r.encode() for i, r in enumerate(self._roles)}

    def data(self, index, role=Qt.DisplayRole):
        if not (0 <= index.row() < len(self._rows)):
            return None
        row = self._rows[index.row()]
        if role == Qt.DisplayRole:
            return row.get(self._roles[0])
        i = role - Qt.UserRole - 1
        return row.get(self._roles[i]) if 0 <= i < len(self._roles) else None

    @Slot(int, result="QVariantMap")
    def get(self, i):
        return dict(self._rows[i]) if 0 <= i < len(self._rows) else {}

    def rows(self):
        return [dict(r) for r in self._rows]

    def reset(self, rows):
        self.beginResetModel()
        self._rows = [dict(r) for r in rows]
        self.endResetModel()

    def sync(self, rows):
        """Update to `rows` when only values changed (same length); otherwise reset."""
        rows = [dict(r) for r in rows]
        if len(rows) != len(self._rows):
            self.reset(rows)
            return
        for i, (old, new) in enumerate(zip(self._rows, rows)):
            if old != new:
                self._rows[i] = new
                self.dataChanged.emit(self.index(i), self.index(i))

    def insert(self, i, row):
        self.beginInsertRows(QModelIndex(), i, i)
        self._rows.insert(i, dict(row))
        self.endInsertRows()

    def remove(self, i):
        self.beginRemoveRows(QModelIndex(), i, i)
        del self._rows[i]
        self.endRemoveRows()

    def move(self, i, j):
        """Move row i so it ends up at index j."""
        if i == j:
            return
        dest = j + 1 if j > i else j  # Qt counts the destination before removal
        self.beginMoveRows(QModelIndex(), i, i, QModelIndex(), dest)
        self._rows.insert(j, self._rows.pop(i))
        self.endMoveRows()
