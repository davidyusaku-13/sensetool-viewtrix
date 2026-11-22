import os
import tempfile
import unittest
import yaml
from PySide6.QtCore import QUrl
from src.models.prjsetmodel import PrjSetModel, ISSUE_ROLE, RESOLVED_ROLE

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


class PrjSetModelTestCase(unittest.TestCase):
    def setUp(self):
        self._model = PrjSetModel()
        self._model.clear()
        self._model.addItem("name", "value", "desc")
        self._tmp = tempfile.TemporaryDirectory()

    def url(self, name):
        return QUrl.fromLocalFile(os.path.join(self._tmp.name, name))

    def names(self):
        return [self._model.get(i).name for i in range(self._model.rowCount())]

    def fill(self, *names):
        self._model.clear()
        for n in names:
            self._model.addItem(n, "1", "")

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

    def test_move_down_several_rows_keeps_all_rows(self):
        self.fill("A", "B", "C", "D", "E", "F")
        self.assertTrue(self._model.move(0, 3))
        self.assertEqual(self.names(), ["B", "C", "D", "A", "E", "F"])

    def test_move_up_several_rows(self):
        self.fill("A", "B", "C", "D", "E", "F")
        self.assertTrue(self._model.move(4, 1))
        self.assertEqual(self.names(), ["A", "E", "B", "C", "D", "F"])

    def test_move_to_end_and_noop(self):
        self.fill("A", "B", "C")
        self.assertTrue(self._model.move(0, 2))
        self.assertEqual(self.names(), ["B", "C", "A"])
        self.assertFalse(self._model.move(1, 1))
        self.assertFalse(self._model.move(0, 3))
        self.assertEqual(self.names(), ["B", "C", "A"])

    def test_move_adopts_target_group(self):
        self._model.clear()
        self._model.addItem("A", "1", "", "G1", "")
        self._model.addItem("B", "1", "", "G2", "")
        self._model.move(0, 1)
        self.assertEqual(self._model.get(1).name, "A")
        self.assertEqual(self._model.get(1).group, "G2")

    def test_add_keeps_groups_contiguous(self):
        self._model.clear()
        self._model.addItem("A", "1", "", "G1", "")
        self._model.addItem("B", "1", "", "G2", "")
        self._model.addItem("C", "1", "", "G1", "")
        self.assertEqual(self.names(), ["A", "C", "B"])
        self.assertEqual(self._model.groups(), ["G1", "G2"])

    def test_values_stored_as_text(self):
        path = os.path.join(self._tmp.name, "in.yaml")
        with open(path, "w") as f:
            yaml.dump({"data": [{"name": "TX_LEN", "value": 21, "desc": None}]}, f)
        self.assertEqual(self._model.importYAML(QUrl.fromLocalFile(path)), "")
        self.assertEqual(self._model.get(0).value, "21")
        self.assertEqual(self._model.get(0).desc, "")

    def test_import_replaces_instead_of_appending(self):
        url = QUrl.fromLocalFile(os.path.join(ROOT, "yaml", "prjset.yaml"))
        self.assertEqual(self._model.importFile(url), "")
        self.assertEqual(self._model.importFile(url), "")
        self.assertEqual(self._model.rowCount(), 140)
        self.assertEqual(self._model.issueCount, 0)

    def test_import_errors_are_reported(self):
        self.assertNotEqual(self._model.importYAML(self.url("missing.yaml")), "")
        path = os.path.join(self._tmp.name, "bad.yaml")
        with open(path, "w") as f:
            f.write("data:\n- value: 1\n")
        self.assertIn("name", self._model.importYAML(QUrl.fromLocalFile(path)))
        self.assertEqual(self._model.rowCount(), 1, "failed import must not touch the list")

    @unittest.skipUnless(os.path.exists(os.path.join(ROOT, "prjcfg.xlsx")), "prjcfg.xlsx not present")
    def test_import_xlsx(self):
        self.assertEqual(self._model.importFile(QUrl.fromLocalFile(os.path.join(ROOT, "prjcfg.xlsx"))), "")
        self.assertEqual(self._model.rowCount(), 140)
        first = self._model.get(0)
        self.assertEqual((first.name, first.value, first.group), ("TX_LEN", "21", "Project Information"))
        dist = self._model.get(self._model.indexOfName("FWCFG_DIST_THRES"))
        self.assertEqual(dist.value, "(500U)")

    def test_yaml_round_trip(self):
        self._model.clear()
        self._model.addItem("A", "21", "first", "G", "note")
        self._model.addItem("B", "0x10", "", "G", "")
        self.assertEqual(self._model.exportYAML(self.url("out.yaml")), "")
        with open(os.path.join(self._tmp.name, "out.yaml")) as f:
            data = yaml.safe_load(f)["data"]
        self.assertEqual(data[0]["value"], 21)
        self.assertEqual(data[1]["value"], "0x10")
        other = PrjSetModel()
        self.assertEqual(other.importYAML(self.url("out.yaml")), "")
        self.assertEqual([other.get(i).to_dict() for i in range(2)],
                         [self._model.get(i).to_dict() for i in range(2)])

    def test_validation_and_resolved_values(self):
        self._model.clear()
        self._model.addItem("TX_LEN", "21", "")
        self._model.addItem("RX_LEN", "40", "")
        self._model.addItem("FRM_SZ", "(RX_LEN * TX_LEN)", "")
        self._model.addItem("BAD", "MISSING + 1", "")
        idx = lambda r: self._model.index(r, 0)
        self.assertEqual(self._model.data(idx(2), RESOLVED_ROLE), "840")
        self.assertEqual(self._model.data(idx(0), RESOLVED_ROLE), "")
        self.assertIn("MISSING", self._model.data(idx(3), ISSUE_ROLE))
        self.assertEqual(self._model.issueCount, 1)
        self.assertNotEqual(self._model.exportHeader(self.url("prjset.h")), "")
        self._model.removeItem(3)
        self.assertEqual(self._model.issueCount, 0)

    def test_duplicate_names_flagged(self):
        self.fill("A", "A")
        self.assertEqual(self._model.issueCount, 2)
        self.assertEqual(self._model.indexOfName("A"), 0)
        self.assertEqual(self._model.indexOfName("Z"), -1)

    def test_export_header(self):
        self._model.clear()
        self._model.addItem("RX_LEN", "40", "Rx count", "Info", "review note")
        self._model.addItem("LEN", "(RX_LEN*2)+4", "", "Info", "")
        self.assertEqual(self._model.exportHeader(self.url("prjset.h")), "")
        with open(os.path.join(self._tmp.name, "prjset.h")) as f:
            text = f.read()
        self.assertIn("#ifndef PRJSET_H", text)
        self.assertIn("/* Rx count */", text)
        self.assertRegex(text, r"#define RX_LEN\s+40\n")
        self.assertRegex(text, r"#define LEN\s+\(\(RX_LEN\*2\)\+4\)\n")
        self.assertNotIn("review note", text)

    def tearDown(self):
        self._model.clear()
        self.assertEqual(self._model.rowCount(), 0, "Failed to cleanup")
        del self._model
        self._tmp.cleanup()


if __name__ == '__main__':
    unittest.main()
