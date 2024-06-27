import unittest
from src.models.prjsetmodel import PrjSetModel

class PrjSetModelTestCase(unittest.TestCase):
    def setUp(self):
        self._model = PrjSetModel()
        self._model.clear()
        self._model.addItem("name", "value", "desc")
      
    def test_prjset_model_create(self):
        self._model.addItem("name2", "value2", "desc2")
        self.assertEqual(self._model.rowCount(), 2, "Failed to add item")
        
    def test_prjset_model_read(self):
        self.assertEqual(self._model.get(0).name, "name", "Failed to fetch item at index 0")
        self.assertEqual(self._model.get(0).value, "value", "Failed to fetch item at index 0")
        self.assertEqual(self._model.get(0).desc, "desc", "Failed to fetch item at index 0")
    
    def test_prjset_model_update(self):
        self._model.edit(0, "editName", "editVal", "editDesc")
        self.assertEqual(self._model.get(0).name, "editName", "Failed to edit item at index 0")
        self.assertEqual(self._model.get(0).value, "editVal", "Failed to edit item at index 0")
        self.assertEqual(self._model.get(0).desc, "editDesc", "Failed to edit item at index 0")

    def test_prjset_model_delete(self):
        self._model.removeItem(0)
        self.assertEqual(self._model.rowCount(), 0, "Failed to delete item")
        
    def tearDown(self):
        self._model.clear()
        self.assertEqual(self._model.rowCount(), 0, "Failed to cleanup")
        del self._model
        
if __name__ == '__main__':
    unittest.main()