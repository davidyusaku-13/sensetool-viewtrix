import unittest
from src.models.prjsetmodelitem import PrjSetModelItem

class PrjSetModelItemTestCase(unittest.TestCase):
    def setUp(self):
        self._model = PrjSetModelItem("name", "value", "desc")
      
    def test_prjset_model_item_create(self):
        self.assertEqual(self._model.name, "name", "Failed to add item")
        self.assertEqual(self._model.value, "value", "Failed to add item")
        self.assertEqual(self._model.desc, "desc", "Failed to add item")
        
    def tearDown(self):
        del self._model
        
if __name__ == '__main__':
    unittest.main()