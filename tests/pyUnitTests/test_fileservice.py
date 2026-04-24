import tempfile
import unittest
from pathlib import Path

from PySide6.QtCore import QUrl

from src.models.prjsetmodel import PrjSetModel
from src.services.file_service import FileService


class FileServiceTestCase(unittest.TestCase):
    def setUp(self):
        self._service = FileService()

    def test_import_legacy_demo_coefficients_fixture(self):
        result = self._service.import_demo_coefficients(Path("yaml/coef_demo.yaml"))

        self.assertIsNotNone(result)
        self.assertEqual(result.num_step, 40)
        self.assertEqual(result.sample_number, 40)
        self.assertEqual(result.cycle, 4)
        self.assertEqual(result.adc_sampling_freq, 400)
        self.assertEqual(len(result.coefficients), 40)
        self.assertEqual(result.coefficients[:3], [0, 20, 40])

    def test_project_settings_round_trip_via_model(self):
        model = PrjSetModel()
        model.addItem("TX_LEN", "21", "desc")
        model.addItem("RX_LEN", "40", "")

        with tempfile.TemporaryDirectory() as tmp_dir:
            file_path = Path(tmp_dir) / "project.yaml"
            file_url = QUrl.fromLocalFile(str(file_path))

            model.exportYAML(file_url)
            model.clear()
            model.importYAML(file_url)

            self.assertEqual(model.rowCount(), 2)
            self.assertEqual(model.get(0).name, "TX_LEN")
            self.assertEqual(model.get(0).value, "21")
            self.assertEqual(model.get(0).desc, "desc")
            self.assertEqual(model.get(1).name, "RX_LEN")
            self.assertEqual(model.get(1).value, "40")
            self.assertEqual(model.get(1).desc, "")

    def test_import_project_settings_normalizes_null_desc(self):
        result = self._service.import_project_settings(Path("yaml/prjset.yaml"))

        self.assertIsNotNone(result)
        self.assertEqual(result[0]["name"], "TX_LEN")
        self.assertEqual(result[0]["value"], "21")
        self.assertEqual(result[0]["desc"], "")


if __name__ == '__main__':
    unittest.main()
