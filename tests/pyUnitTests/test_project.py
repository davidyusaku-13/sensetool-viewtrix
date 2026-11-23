"""ProjectController: open/save of the combined prjcfg.yaml, unsaved-change
tracking and undo/redo across all workspaces (formerly QML in main.qml)."""
import os
import shutil
import tempfile
import unittest
from PySide6.QtCore import QCoreApplication, QSettings, QUrl
from src.models.appsetmodel import AppSetModel
from src.models.prjsetmodel import PrjSetModel
from src.models.project import ProjectController
from src.models.scanarrmodel import ScanArrModel

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PRJCFG = os.path.join(ROOT, "yaml", "prjcfg.yaml")
XLSX = os.path.join(ROOT, "prjcfg.xlsx")


def make():
    p, a, s = PrjSetModel(), AppSetModel(), ScanArrModel()
    c = ProjectController()
    for w in (p, a, s):
        c.addWorkspace(w)
    return c, p, a, s


class ProjectControllerTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        app = QCoreApplication.instance() or QCoreApplication([])
        cls._org = (app.organizationName(), app.applicationName())
        app.setOrganizationName("SenseToolTests")
        app.setApplicationName("project-test")

    @classmethod
    def tearDownClass(cls):
        QSettings().clear()
        app = QCoreApplication.instance()
        app.setOrganizationName(cls._org[0])
        app.setApplicationName(cls._org[1])

    def setUp(self):
        QSettings().clear()
        self.tmp = tempfile.TemporaryDirectory()
        self.file = os.path.join(self.tmp.name, "prjcfg.yaml")
        shutil.copy(PRJCFG, self.file)
        self.url = QUrl.fromLocalFile(self.file)

    def tearDown(self):
        self.tmp.cleanup()

    def test_a_new_project_is_clean_and_untitled(self):
        c, *_ = make()
        self.assertEqual((c.name, c.path, c.hasPath, c.dirty, c.canUndo, c.canRedo),
                         ("", "", False, False, False, False))

    def test_open_fills_every_workspace(self):
        c, p, a, s = make()
        self.assertEqual(c.open(self.url), "")
        self.assertEqual((p.rowCount(), a.rowCount(), s.items.rowCount()), (140, 16, 16))
        self.assertEqual((c.name, c.hasPath, c.dirty, c.canUndo), ("prjcfg.yaml", True, False, False))

    def test_open_then_save_does_not_change_the_file(self):
        c, *_ = make()
        c.open(self.url)
        self.assertEqual(c.save(), "")
        with open(self.file, encoding="utf-8") as f, open(PRJCFG, encoding="utf-8") as g:
            self.assertEqual(f.read(), g.read())

    def test_edits_make_it_dirty_until_saved(self):
        c, p, a, s = make()
        c.open(self.url)
        a.removeItem(0)
        c.track()
        self.assertTrue(c.dirty)
        self.assertTrue(c.canUndo)
        self.assertEqual(c.save(), "")
        self.assertFalse(c.dirty)
        reopened, _, a2, _ = make()
        reopened.open(self.url)
        self.assertEqual(a2.rowCount(), 15)

    def test_undo_and_redo_across_workspaces(self):
        c, p, a, s = make()
        c.open(self.url)
        p.edit(0, "TX_LEN", "22", "", "Project Information", "")
        c.track()
        s.addItem("AFE_NEW", "")
        c.track()
        self.assertEqual(s.items.rowCount(), 17)
        c.undo()
        self.assertEqual(s.items.rowCount(), 16)
        self.assertEqual(p.get(0).value, "22")
        c.undo()
        self.assertEqual(p.get(0).value, "21")
        self.assertFalse(c.dirty, "undoing everything returns to the saved state")
        self.assertFalse(c.canUndo)
        c.redo()
        c.redo()
        self.assertEqual((p.get(0).value, s.items.rowCount()), ("22", 17))
        self.assertFalse(c.canRedo)

    def test_a_new_edit_clears_redo(self):
        c, p, *_ = make()
        c.open(self.url)
        p.edit(0, "TX_LEN", "22", "", "Project Information", "")
        c.track()
        c.undo()
        self.assertTrue(c.canRedo)
        p.edit(0, "TX_LEN", "23", "", "Project Information", "")
        c.track()
        self.assertFalse(c.canRedo)

    def test_changes_are_tracked_without_polling(self):
        c, p, *_ = make()
        c.open(self.url)
        p.edit(0, "TX_LEN", "22", "", "Project Information", "")
        c.flush()  # what the debounce timer would do
        self.assertTrue(c.canUndo)

    def test_save_as_and_reopen_last(self):
        c, *_ = make()
        c.open(self.url)
        other = QUrl.fromLocalFile(os.path.join(self.tmp.name, "copy.yaml"))
        self.assertEqual(c.saveAs(other), "")
        self.assertEqual(c.name, "copy.yaml")
        fresh, p, *_ = make()
        self.assertTrue(fresh.openLast())
        self.assertEqual((fresh.name, p.rowCount()), ("copy.yaml", 140))

    def test_open_last_without_a_file(self):
        c, *_ = make()
        self.assertFalse(c.openLast())
        QSettings().setValue("lastProject", QUrl.fromLocalFile(os.path.join(self.tmp.name, "gone.yaml")).toString())
        self.assertFalse(c.openLast())

    def test_save_needs_a_path(self):
        c, *_ = make()
        self.assertNotEqual(c.save(), "")

    def test_non_project_files_are_rejected_and_change_nothing(self):
        c, p, a, _ = make()
        c.open(self.url)
        err = c.open(QUrl.fromLocalFile(os.path.join(ROOT, "yaml", "appset.yaml")))
        self.assertIn("not a project file", err)
        self.assertEqual((p.rowCount(), a.rowCount(), c.name), (140, 16, "prjcfg.yaml"))
        self.assertIn("Could not open", c.open(QUrl.fromLocalFile(os.path.join(self.tmp.name, "missing.yaml"))))

    def test_a_broken_section_rolls_back(self):
        c, p, a, s = make()
        c.open(self.url)
        bad = os.path.join(self.tmp.name, "bad.yaml")
        with open(bad, "w") as f:
            f.write("prjset: {data: []}\nappset: {registers: []}\nscanarr: {scan_items: [{desc: x}]}\n")
        self.assertIn("scanarr", c.open(QUrl.fromLocalFile(bad)))
        self.assertEqual((p.rowCount(), a.rowCount(), s.items.rowCount()), (140, 16, 16))

    @unittest.skipUnless(os.path.exists(XLSX), "prjcfg.xlsx not present")
    def test_importing_the_spreadsheet_needs_save_as(self):
        c, p, *_ = make()
        self.assertEqual(c.open(QUrl.fromLocalFile(XLSX)), "")
        self.assertEqual(p.rowCount(), 140)
        self.assertFalse(c.hasPath)
        self.assertTrue(c.dirty, "an imported spreadsheet has not been saved as a project yet")
        self.assertEqual(c.lastSkipped(), ["For ScanState Idle (Use mutual)"])


if __name__ == "__main__":
    unittest.main()
