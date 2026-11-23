import math
import os
import tempfile
import unittest
from PySide6.QtCore import QUrl
from src.modules import coefficients as coef
from src.modules.coefficients import CoefficientGenerator


class CoefficientMathTestCase(unittest.TestCase):
    def test_window_matches_the_generalized_hamming_formula(self):
        # w[n] = a0 - (1 - a0) * cos(2*pi*n / (N - 1)), scaled to 256 (a0 0.5 = Hann, 0.54 = Hamming)
        for n, a0 in [(50, 0.54), (51, 0.5), (8, 0.0)]:
            ref = [round((a0 - (1 - a0) * math.cos(2 * math.pi * k / (n - 1))) * 256) for k in range(n)]
            self.assertEqual(coef.window(n, a0, "Full"), ref)
            self.assertEqual(coef.window(n, a0, "Half"), ref[:n // 2])
        self.assertEqual(max(coef.window(50, 0.54, "Full")), 256)
        self.assertEqual(coef.window(1, 0.5, "Full"), [])

    def test_demodulator_is_quadrature_sine_and_cosine(self):
        i_coef, q_coef = coef.demodulator(40, 40, 4)
        self.assertEqual(len(i_coef), 40)
        # step 40 -> N = 160, cycle 4 -> one period every 40 samples, amplitude 128
        self.assertEqual((i_coef[0], i_coef[10], i_coef[20], i_coef[30]), (0, 128, 0, -128))
        self.assertEqual((q_coef[0], q_coef[10], q_coef[20]), (128, 0, -128))
        for a, b in zip(i_coef, q_coef):
            self.assertLessEqual(abs(math.hypot(a, b) - 128), 1.5)
        self.assertEqual(coef.demodulator(0, 10, 1), ([], []))

    def test_input_checks(self):
        self.assertEqual(coef.check_window("50", "0.54"), "")
        for n, a0 in [("", "0.5"), ("1", "0.5"), ("50.7", "0.5"), ("x", "0.5")]:
            self.assertIn("Sample Number", coef.check_window(n, a0))
        for a0 in ["", "1.5", "-0.1", "abc"]:
            self.assertIn("a0", coef.check_window("50", a0))
        self.assertEqual(coef.check_demodulator("40", "40", "4", "400"), "")
        self.assertIn("Step", coef.check_demodulator("", "40", "4", "400"))
        self.assertIn("Cycle", coef.check_demodulator("40", "40", "0", "400"))
        self.assertIn("ADC Freq", coef.check_demodulator("40", "40", "4", "4.5"))


class CoefficientGeneratorTestCase(unittest.TestCase):
    """The QML-facing object: takes the text of the input fields."""

    def setUp(self):
        self.gen = CoefficientGenerator()
        self.tmp = tempfile.TemporaryDirectory()

    def tearDown(self):
        self.tmp.cleanup()

    def url(self, name):
        return QUrl.fromLocalFile(os.path.join(self.tmp.name, name))

    def test_window_from_field_text(self):
        self.assertEqual(self.gen.windowCoefficients("50", "0.54", "Full"), coef.window(50, 0.54, "Full"))
        self.assertEqual(self.gen.windowCoefficients("1", "0.54", "Full"), [])
        self.assertIn("Sample Number", self.gen.checkWindow("", ""))

    def test_demodulator_from_field_text(self):
        d = self.gen.demodulatorCoefficients("40", "40", "4")
        self.assertEqual((d["i"], d["q"]), coef.demodulator(40, 40, 4))

    def test_window_file_round_trip(self):
        self.assertEqual(self.gen.exportWindow(self.url("w.yaml"), "50", "0.54", "Half"), "")
        r = self.gen.importWindow(self.url("w.yaml"))
        self.assertEqual(r["error"], "")
        self.assertEqual((r["sampleNumber"], r["a0"], r["length"]), ("50", "0.54", "Half"))
        self.assertEqual(r["values"], coef.window(50, 0.54, "Half"))
        self.assertIn("Sample Number", self.gen.exportWindow(self.url("bad.yaml"), "", "0.5", "Full"))
        self.assertFalse(os.path.exists(os.path.join(self.tmp.name, "bad.yaml")))

    def test_demodulator_file_round_trip(self):
        self.assertEqual(self.gen.exportDemodulator(self.url("d.yaml"), "40", "40", "4", "400"), "")
        r = self.gen.importDemodulator(self.url("d.yaml"))
        self.assertEqual(r["error"], "")
        self.assertEqual((r["step"], r["sample"], r["cycle"], r["adcFreq"]), ("40", "40", "4", "400"))
        self.assertEqual((r["i"], r["q"]), coef.demodulator(40, 40, 4))

    def test_import_errors(self):
        self.assertIn("Could not open", self.gen.importWindow(self.url("missing.yaml"))["error"])
        with open(os.path.join(self.tmp.name, "bad.yaml"), "w") as f:
            f.write("data: []\n")
        self.assertIn("sample_number", self.gen.importWindow(self.url("bad.yaml"))["error"])
        self.assertIn("i_coef", self.gen.importDemodulator(self.url("bad.yaml"))["error"])

    def test_bundled_sample_files_match_the_generator(self):
        root = os.path.join(os.path.dirname(__file__), "..", "..", "yaml")
        w = self.gen.importWindow(QUrl.fromLocalFile(os.path.join(root, "coef_win.yaml")))
        self.assertEqual(w["values"], self.gen.windowCoefficients(w["sampleNumber"], w["a0"], w["length"]))
        d = self.gen.importDemodulator(QUrl.fromLocalFile(os.path.join(root, "coef_demo.yaml")))
        g = self.gen.demodulatorCoefficients(d["step"], d["sample"], d["cycle"])
        self.assertEqual((d["i"], d["q"]), (g["i"], g["q"]))


if __name__ == "__main__":
    unittest.main()
