import unittest
from src.models.historymodelitem import HistoryModelItem

class HistoryModelItemTestCase(unittest.TestCase):
    def setUp(self):
        self._model = HistoryModelItem("action", "name", "value", "desc", "time", "history")
      
    def test_history_model_item_create(self):
        self.assertEqual(self._model.action, "action", "Failed to add item")
        self.assertEqual(self._model.name, "name", "Failed to add item")
        self.assertEqual(self._model.value, "value", "Failed to add item")
        self.assertEqual(self._model.desc, "desc", "Failed to add item")
        self.assertIsNotNone(self._model.time)
        self.assertIsNotNone(self._model.history)
        
    def tearDown(self):
        del self._model
        
if __name__ == '__main__':
    unittest.main()