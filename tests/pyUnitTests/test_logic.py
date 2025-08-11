import unittest
from src.modules.logic import AppLogic
from PySide6.QtCore import QUrl
import pathlib as pl
from PySide6.QtWidgets import QApplication
import sys

class AppLogicTestCase(unittest.TestCase):
  
  def assertIsFile(self, path):
    if not pl.Path(path).resolve().is_file():
      raise AssertionError("File does not exist: %s" % str(path))
  
  def setUp(self):
    # Ensure QApplication exists for QML objects
    if not QApplication.instance():
      self.app = QApplication(sys.argv)
    self._model = AppLogic()
      
  def test_logic_win_coef_gen(self):
    win_sample_number, win_a0, win_length = 50, 0.54, "Full"
    tmp = self._model.win_coef_gen(win_sample_number, win_a0, win_length)
    self.assertIsInstance(tmp, list, "Win Coef Generation failed")
  
  def test_logic_export_win_coef(self):
    fname = "test_logic_export_win_coef.yaml"
    win_sample_number, win_a0, win_length = 50, 0.54, "Full"
    y = self._model.win_coef_gen(win_sample_number, win_a0, win_length)
    self._model.exportWinCoef(QUrl.fromLocalFile(fname), y, win_sample_number, win_a0, win_length)
    self.assertIsFile(fname)
    
  def test_logic_import_win_coef(self):
    # COMPARATOR
    win_sample_number, win_a0, win_length = 50, 0.54, "Full"
    # TASK
    fname = "test_logic_export_win_coef.yaml"
    result = self._model.importWinCoef(QUrl.fromLocalFile(fname))
    self.assertIsInstance(result, dict)
    self.assertIn('coefficients', result)
    self.assertIn('sample_number', result)
    self.assertIn('a0', result)
    self.assertIn('coef_length', result)
    self.assertIsInstance(result['coefficients'], list)
    self.assertEqual(win_sample_number, result['sample_number'])
    self.assertEqual(win_a0, result['a0'])
    self.assertEqual(win_length, result['coef_length'])
    
  def test_logic_demo_coef_gen(self):
    demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq = 40, 40, 4, 400
    tmp = self._model.demo_coef_gen(demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq)
    self.assertIsInstance(tmp, list, "Demo Coef Generation failed")
    
  def test_logic_export_demo_coef(self):
    fname = "test_logic_export_demo_coef.yaml"
    demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq = 40, 40, 4, 400
    y = self._model.demo_coef_gen(demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq)
    self._model.exportDemoCoef(QUrl.fromLocalFile(fname), y, demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq)
    self.assertIsFile(fname)
    
  def test_logic_import_demo_coef(self):
    # COMPARATOR
    demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq = 40, 40, 4, 400
    # TASK
    fname = "test_logic_export_demo_coef.yaml"
    result = self._model.importDemoCoef(QUrl.fromLocalFile(fname))
    self.assertIsInstance(result, dict)
    self.assertIn('i_coefficients', result)
    self.assertIn('q_coefficients', result)
    self.assertIn('step', result)
    self.assertIn('sample', result)
    self.assertIn('cycle', result)
    self.assertIn('adc_freq', result)
    self.assertIsInstance(result['i_coefficients'], list)
    self.assertIsInstance(result['q_coefficients'], list)
    self.assertEqual(demo_num_step, result['step'])
    self.assertEqual(demo_sample_number, result['sample'])
    self.assertEqual(demo_cycle, result['cycle'])
    self.assertEqual(demo_adc_sampling_freq, result['adc_freq'])
        
  def tearDown(self):
    del self._model
        
if __name__ == '__main__':
  unittest.main()