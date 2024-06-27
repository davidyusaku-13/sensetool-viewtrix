import unittest
from PySide6.QtCore import Qt
from src.models.historymodel import HistoryModel

class HistoryModelTestCase(unittest.TestCase):
    def setUp(self):
        self._model = HistoryModel()
        self._model.clear()
        self._model.addHistory("action", "name", "value", "desc")
      
    def test_history_model_create(self):
        self._model.addHistory("action2", "name2", "value2", "desc2")
        self.assertEqual(self._model.rowCount(), 2, "Failed to add item")
        
    def test_history_model_read(self):
        index = self._model.index(0, 0)
        self.assertEqual(self._model.data(index, Qt.DisplayRole), 'action')
        self.assertEqual(self._model.data(index, Qt.UserRole + 1), 'name')
        self.assertEqual(self._model.data(index, Qt.UserRole + 2), 'value')
        self.assertEqual(self._model.data(index, Qt.UserRole + 3), 'desc')
        self.assertIsNotNone(self._model.data(index, Qt.UserRole + 4))
        self.assertIsNotNone(self._model.data(index, Qt.UserRole + 5))
    
    def test_history_model_delete(self):
        self._model.clear()
        self.assertEqual(self._model.rowCount(), 0, "Failed to clear history")
        
    def tearDown(self):
        del self._model
        
if __name__ == '__main__':
    unittest.main()