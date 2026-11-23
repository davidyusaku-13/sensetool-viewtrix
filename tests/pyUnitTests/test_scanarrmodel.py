import os
import tempfile
import unittest
import yaml
from PySide6.QtCore import QUrl
from src.models.scanarrmodel import ScanArrModel

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BUNDLED = QUrl.fromLocalFile(os.path.join(ROOT, "yaml", "scanarr.yaml"))
XLSX = os.path.join(ROOT, "prjcfg.xlsx")  # gitignored: tests using it run only where present


def column(list_model, role):
    """Values of one role, read through the Qt model interface like a view would."""
    rid = [k for k, v in list_model.roleNames().items() if v == role.encode()][0]
    return [list_model.data(list_model.index(i), rid) for i in range(list_model.rowCount())]


def small():
    m = ScanArrModel()
    m.loadData({"scan_items": [{"name": "AFE_END"}, {"name": "AFE_ON"}, {"name": "AFE_MS"}],
                "arrangements": [{"id": 1, "name": "ACTIVE", "scans": ["AFE_ON", "AFE_MS", "AFE_END"]},
                                 {"id": 4, "name": "IDLE", "scans": ["AFE_MS", "AFE_END"]}]})
    return m


class ScanArrModelTestCase(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()

    def tearDown(self):
        self.tmp.cleanup()

    def url(self, name):
        return QUrl.fromLocalFile(os.path.join(self.tmp.name, name))

    # ---- scan items ------------------------------------------------------
    def test_items_have_enum_values_in_order(self):
        m = small()
        self.assertEqual(column(m.items, "name"), ["AFE_END", "AFE_ON", "AFE_MS"])
        self.assertEqual(column(m.items, "value"), [0, 1, 2])
        self.assertEqual(m.moveItem(2, -1), 1)
        self.assertEqual(column(m.items, "name"), ["AFE_END", "AFE_MS", "AFE_ON"])
        self.assertEqual(column(m.items, "value"), [0, 1, 2])
        self.assertEqual(m.moveItem(0, -1), 0, "moving past the top does nothing")

    def test_add_item_validates(self):
        m = small()
        self.assertEqual(m.addItem("AFE_SS", "self scan"), "")
        self.assertEqual(column(m.items, "name")[-1], "AFE_SS")
        self.assertIn("already", m.addItem("AFE_ON", ""))
        self.assertIn("name", m.addItem("9BAD", ""))

    def test_renaming_an_item_renames_its_steps_everywhere(self):
        m = small()
        self.assertEqual(m.editItem(2, "AFE_MUTUAL", "mutual"), "")
        doc = m.document()
        self.assertEqual([a["scans"] for a in doc["arrangements"]],
                         [["AFE_ON", "AFE_MUTUAL", "AFE_END"], ["AFE_MUTUAL", "AFE_END"]])
        self.assertEqual(doc["scan_items"][2], {"name": "AFE_MUTUAL", "desc": "mutual"})
        self.assertIn("already", m.editItem(2, "AFE_ON", ""))
        self.assertEqual(m.editItem(2, "AFE_MUTUAL", "same name is fine"), "")

    def test_remove_items(self):
        m = small()
        m.removeItems([1, 2])
        self.assertEqual(column(m.items, "name"), ["AFE_END"])

    # ---- arrangements ----------------------------------------------------
    def test_arrangements_and_next_id(self):
        m = small()
        self.assertEqual(column(m.arrangements, "arrId"), ["1", "4"])
        self.assertEqual(column(m.arrangements, "stepCount"), [3, 2])
        self.assertEqual(m.nextArrangementId(), "5")
        self.assertEqual(m.addArrangement("5", "LP", "low power"), "")
        self.assertEqual(m.current, 2, "a new arrangement is shown in the Scan List")
        self.assertEqual(column(m.steps, "name"), ["AFE_END"], "new arrangements start with the terminator")
        self.assertIn("already", m.addArrangement("6", "LP", ""))
        self.assertIn("ID", m.addArrangement("x", "OTHER", ""))
        self.assertEqual(m.editArrangement(2, "7", "LOW_POWER", ""), "")
        self.assertEqual(column(m.arrangements, "name")[2], "LOW_POWER")
        self.assertEqual(column(m.steps, "name"), ["AFE_END"], "editing keeps the steps")
        self.assertEqual(ScanArrModel().nextArrangementId(), "1")

    def test_removing_the_current_arrangement_clears_the_scan_list(self):
        m = small()
        m.setCurrent(1)
        m.removeArrangements([1])
        self.assertEqual(m.current, -1)
        self.assertEqual(m.steps.rowCount(), 0)
        m.setCurrent(0)
        m.removeArrangements([])
        self.assertEqual(m.current, 0)

    # ---- steps of the current arrangement --------------------------------
    def test_steps_follow_the_current_arrangement(self):
        m = small()
        self.assertEqual(m.current, -1)
        m.setCurrent(0)
        self.assertEqual(column(m.steps, "name"), ["AFE_ON", "AFE_MS", "AFE_END"])
        self.assertEqual(column(m.steps, "step"), [1, 2, 3])
        self.assertEqual(m.currentName, "ACTIVE")

    def test_new_steps_go_before_the_terminator_or_after_the_selected_step(self):
        m = small()
        m.setCurrent(0)
        self.assertEqual(m.insertSteps(["AFE_MS", "AFE_ON"], -1), 2)
        self.assertEqual(column(m.steps, "name"), ["AFE_ON", "AFE_MS", "AFE_MS", "AFE_ON", "AFE_END"])
        m.insertSteps(["AFE_END"], 0)
        self.assertEqual(column(m.steps, "name")[:2], ["AFE_ON", "AFE_END"])
        self.assertEqual(column(m.arrangements, "stepCount")[0], 6)

    def test_remove_and_move_steps(self):
        m = small()
        m.setCurrent(0)
        self.assertEqual(m.moveStep(0, 1), 1)
        self.assertEqual(column(m.steps, "name"), ["AFE_MS", "AFE_ON", "AFE_END"])
        m.removeSteps([0, 1])
        self.assertEqual(column(m.steps, "name"), ["AFE_END"])
        self.assertEqual(column(m.arrangements, "stepCount")[0], 1)

    def test_step_edits_need_a_current_arrangement(self):
        m = small()
        self.assertEqual(m.insertSteps(["AFE_ON"], -1), 0)
        self.assertEqual(m.moveStep(0, 1), -1)
        m.removeSteps([0])
        self.assertEqual(m.document(), small().document())

    # ---- checking, files, generation -------------------------------------
    def test_check(self):
        m = small()
        self.assertEqual(m.check(), [])
        m.setCurrent(1)
        m.removeSteps([1])  # drop AFE_END
        self.assertTrue(any("AFE_END" in p for p in m.check()))

    def test_bundled_file(self):
        m = ScanArrModel()
        self.assertEqual(m.importFile(BUNDLED), "")
        self.assertEqual(m.items.rowCount(), 16)
        self.assertEqual(column(m.arrangements, "name"), ["AFE_SCAN_ACTIVE", "AFE_SCAN_IDLE"])
        self.assertEqual(m.check(), [])
        self.assertEqual(m.skippedRows(), [])

    def test_export_round_trip(self):
        m = ScanArrModel()
        m.importFile(BUNDLED)
        self.assertEqual(m.exportYAML(self.url("out.yaml")), "")
        with open(os.path.join(ROOT, "yaml", "scanarr.yaml"), encoding="utf-8") as f, \
                open(os.path.join(self.tmp.name, "out.yaml"), encoding="utf-8") as g:
            self.assertEqual(yaml.safe_load(g), yaml.safe_load(f))

    def test_files_without_ids_are_numbered(self):
        path = os.path.join(self.tmp.name, "old.yaml")
        with open(path, "w") as f:
            f.write("scan_items: []\narrangements:\n- name: A\n- name: B\n")
        m = ScanArrModel()
        self.assertEqual(m.importFile(QUrl.fromLocalFile(path)), "")
        self.assertEqual(column(m.arrangements, "arrId"), ["1", "2"])

    def test_bad_files_change_nothing(self):
        m = small()
        before = m.document()
        self.assertIn("Could not open", m.importFile(self.url("missing.yaml")))
        path = os.path.join(self.tmp.name, "bad.yaml")
        with open(path, "w") as f:
            f.write("scan_items:\n- desc: no name\n")
        self.assertIn("name", m.importFile(QUrl.fromLocalFile(path)))
        self.assertEqual(m.document(), before)

    @unittest.skipUnless(os.path.exists(XLSX), "prjcfg.xlsx not present")
    def test_import_sheet(self):
        m = ScanArrModel()
        self.assertEqual(m.importFile(QUrl.fromLocalFile(XLSX)), "")
        self.assertEqual(m.skippedRows(), ["For ScanState Idle (Use mutual)"])
        bundled = ScanArrModel()
        bundled.importFile(BUNDLED)
        self.assertEqual(m.document()["arrangements"], bundled.document()["arrangements"])

    def test_generate(self):
        m = small()
        self.assertEqual(m.generate(self.url("")), "")
        self.assertTrue(os.path.isfile(os.path.join(self.tmp.name, "afeScanArrg.h")))
        m.setCurrent(0)
        m.removeSteps([2])
        self.assertIn("AFE_END", m.generate(self.url("")))

    def test_every_change_is_announced(self):
        m = small()
        seen = []
        m.changed.connect(lambda: seen.append(1))
        m.addItem("AFE_X", "")
        m.setCurrent(0)
        m.insertSteps(["AFE_X"], -1)
        m.moveItem(1, 1)
        self.assertGreaterEqual(len(seen), 3)


if __name__ == "__main__":
    unittest.main()
