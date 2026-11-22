from PySide6.QtCore import Property, QObject
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "PrjSetModelItem"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class PrjSetModelItem(QObject):
    def __init__(self, name, value, desc, parent=None, group="", comment=""):
        super().__init__(parent)
        self._name = _str(name)
        self._value = _str(value)
        self._desc = _str(desc)
        self._group = _str(group)
        self._comment = _str(comment)

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
    def group(self):
        return self._group

    @Property(str)
    def comment(self):
        return self._comment

    def to_dict(self):
        return {"name": self._name, "value": self._value, "desc": self._desc,
                "group": self._group, "comment": self._comment}


def _str(v):
    """Values are always stored as text so exports are consistent."""
    return "" if v is None else str(v).strip() if not isinstance(v, str) else v
