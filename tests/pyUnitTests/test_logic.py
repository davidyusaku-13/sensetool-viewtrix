import unittest
from src.modules.logic import AppLogic, parse_version, is_newer
import os, tempfile
from PySide6.QtCore import QUrl
import pathlib as pl

class AppLogicTestCase(unittest.TestCase):
  
  def assertIsFile(self, path):
    if not pl.Path(path).resolve().is_file():
      raise AssertionError("File does not exist: %s" % str(path))
  
  def setUp(self):
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
    arr = self._model.importWinCoef(QUrl.fromLocalFile(fname))
    import_y, import_sample_number, import_a0, import_length = arr
    self.assertIsInstance(import_y, list)
    self.assertEqual(win_sample_number, import_sample_number)
    self.assertEqual(win_a0, import_a0)
    self.assertEqual(win_length, import_length)
    
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
    arr = self._model.importDemoCoef(QUrl.fromLocalFile(fname))
    y, import_num_step, import_sample_number, import_cycle, import_adc_sampling_freq = arr
    self.assertIsInstance(y, list)
    self.assertEqual(demo_num_step, import_num_step)
    self.assertEqual(demo_sample_number, import_sample_number)
    self.assertEqual(demo_cycle, import_cycle)
    self.assertEqual(demo_adc_sampling_freq, import_adc_sampling_freq)
        
  def test_version_compare(self):
    self.assertEqual(parse_version("v1.10.2-beta.1+3"), (1, 10, 2))
    self.assertTrue(is_newer("1.10.0", "1.9.0"))
    self.assertFalse(is_newer("1.9.0", "1.10.0"))
    self.assertFalse(is_newer("1.2", "1.2.0"))
    self.assertFalse(is_newer("1.0.0", ""), "unknown current version must not prompt")

  def test_logic_import_errors(self):
    missing = QUrl.fromLocalFile("does_not_exist.yaml")
    self.assertEqual(self._model.importWinCoef(missing), [])
    self.assertNotEqual(self._model.lastError(), "")
    self.assertEqual(self._model.importDemoCoef(missing), [])
    with tempfile.TemporaryDirectory() as d:
      bad = os.path.join(d, "bad.yaml")
      with open(bad, "w") as f:
        f.write("data: []\n")
      self.assertEqual(self._model.importWinCoef(QUrl.fromLocalFile(bad)), [])
      self.assertIn("sample_number", self._model.lastError())

  def test_logic_win_coef_small_sample(self):
    self.assertEqual(self._model.win_coef_gen(1, 0.5, "Full"), [])

  def test_logic_scan_arr_round_trip(self):
    items = [{"name": "MS", "desc": "mutual"}, {"name": "SS", "desc": ""}]
    arrs = [{"id": "3", "name": "Normal", "desc": "d", "scans": ["MS", "SS", "MS"]}]
    with tempfile.TemporaryDirectory() as d:
      url = QUrl.fromLocalFile(os.path.join(d, "scan.yaml"))
      self.assertEqual(self._model.exportScanArr(url, items, arrs), "")
      data = self._model.importScanArr(url)
      # files without arrangement IDs get them numbered in order
      old = os.path.join(d, "old.yaml")
      with open(old, "w") as f:
        f.write("scan_items: []\narrangements:\n- name: A\n- name: B\n")
      ids = [a["id"] for a in self._model.importScanArr(QUrl.fromLocalFile(old))["arrangements"]]
    self.assertEqual(data["scan_items"], items)
    self.assertEqual(data["arrangements"], arrs)
    self.assertEqual(ids, ["1", "2"])

  def test_logic_generate_scan_arr(self):
    items = [{"name": "AFE_END", "desc": ""}, {"name": "AFE_ON", "desc": "on"}]
    arrs = [{"id": "1", "name": "AFE_SCAN_ACTIVE", "desc": "", "scans": ["AFE_ON", "AFE_END"]}]
    with tempfile.TemporaryDirectory() as d:
      self.assertEqual(self._model.generateScanArr(QUrl.fromLocalFile(d), items, arrs), "")
      self.assertTrue(os.path.isfile(os.path.join(d, "afeScanArrg.h")))
      self.assertTrue(os.path.isfile(os.path.join(d, "afeScanArrg.c")))
      bad = [dict(arrs[0], scans=["AFE_ON"])]
      self.assertIn("must end with AFE_END", self._model.generateScanArr(QUrl.fromLocalFile(d), items, bad))

  def tearDown(self):
    del self._model
        
  def test_window_coefficients_match_the_generalized_hamming_formula(self):
    # w[n] = a0 - (1 - a0) * cos(2*pi*n / (N - 1)), scaled to 256 (a0 0.5 = Hann, 0.54 = Hamming)
    import math
    for n_samples, a0 in [(50, 0.54), (51, 0.5), (8, 0.0)]:
      ref = [round((a0 - (1 - a0) * math.cos(2 * math.pi * n / (n_samples - 1))) * 256) for n in range(n_samples)]
      self.assertEqual(self._model.win_coef_gen(n_samples, a0, "Full"), ref)
      self.assertEqual(self._model.win_coef_gen(n_samples, a0, "Half"), ref[:n_samples // 2])
    self.assertEqual(max(self._model.win_coef_gen(50, 0.54, "Full")), 256)

  def test_demodulator_coefficients_are_quadrature_sine_and_cosine(self):
    import math
    i_coef, q_coef = self._model.demo_coef_gen(40, 40, 4, 400)
    self.assertEqual(len(i_coef), 40)
    # step 40 -> N = 160, cycle 4 -> one period every 40 samples, amplitude 128
    self.assertEqual((i_coef[0], i_coef[10], i_coef[20], i_coef[30]), (0, 128, 0, -128))
    self.assertEqual((q_coef[0], q_coef[10], q_coef[20]), (128, 0, -128))
    for a, b in zip(i_coef, q_coef):
      self.assertLessEqual(abs(math.hypot(a, b) - 128), 1.5)

if __name__ == '__main__':
  unittest.main()