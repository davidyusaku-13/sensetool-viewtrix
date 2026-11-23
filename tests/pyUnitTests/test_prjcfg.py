"""yaml/prjcfg.yaml is the YAML replacement for prjcfg.xlsx. These tests run on
it everywhere (the spreadsheet itself is gitignored), and check it is still an
exact conversion of the spreadsheet where the spreadsheet is present."""
import os
import shutil
import subprocess
import tempfile
import unittest
import yaml
from PySide6.QtCore import QUrl
from src.modules import prjcfg, prjset
from src.modules.logic import AppLogic
from src.models.appsetmodel import AppSetModel
from src.models.prjsetmodel import PrjSetModel

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
XLSX = os.path.join(ROOT, "prjcfg.xlsx")  # gitignored: tests using it run only where present
PRJCFG = os.path.join(ROOT, "yaml", "prjcfg.yaml")
URL = QUrl.fromLocalFile(PRJCFG)


def load(path):
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f)


def prjset_model(url=URL):
    m = PrjSetModel()
    assert m.importFile(url) == "", url
    return m


class PrjCfgTestCase(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()

    def tearDown(self):
        self._tmp.cleanup()

    def tmp(self, name):
        return os.path.join(self._tmp.name, name)

    # ---- the file loads into every workspace --------------------------
    def test_project_setting(self):
        m = prjset_model()
        self.assertEqual(m.rowCount(), 140)
        self.assertEqual(m.issueCount, 0)
        first = m.get(0)
        self.assertEqual((first.name, first.value, first.group), ("TX_LEN", "21", "Project Information"))
        self.assertEqual(m.get(m.indexOfName("FWCFG_DIST_THRES")).value, "(500U)")
        self.assertEqual(len(m.groups()), 5)
        items = [m.get(i).to_dict() for i in range(m.rowCount())]
        res = dict(zip([i["name"] for i in items], prjset.analyze([(i["name"], i["value"]) for i in items])))
        self.assertEqual(res["FRM_SZ"]["resolved"], "840")
        self.assertEqual(res["AFE_MUTUAL_DATA_LENGTH"]["resolved"], "1684")

    def test_app_setting(self):
        m = AppSetModel()
        self.assertEqual(m.importFile(URL), "")
        self.assertEqual((m.rowCount(), m.issueCount, m.bytesUsed), (16, 0, 19))

    def test_scan_arrangement(self):
        logic = AppLogic()
        d = logic.importScanArr(URL)
        self.assertEqual(logic.lastError(), "")
        self.assertEqual(len(d["scan_items"]), 16)
        self.assertEqual([a["name"] for a in d["arrangements"]], ["AFE_SCAN_ACTIVE", "AFE_SCAN_IDLE"])
        self.assertEqual(logic.checkScanArr(d["scan_items"], d["arrangements"]), [])

    # ---- it agrees with the single-workspace files ---------------------
    def test_sections_match_bundled_files(self):
        data = load(PRJCFG)
        self.assertEqual(data["appset"], load(os.path.join(ROOT, "yaml", "appset.yaml")))
        self.assertEqual(data["scanarr"], load(os.path.join(ROOT, "yaml", "scanarr.yaml")))
        # prjset.yaml was tidied by hand (spacing in expressions, line breaks in
        # descriptions), so compare what the values mean rather than their text.
        a = prjset_model()
        b = prjset_model(QUrl.fromLocalFile(os.path.join(ROOT, "yaml", "prjset.yaml")))
        key = lambda m: [(m.get(i).name, m.get(i).group,
                          prjset.analyze([(m.get(j).name, m.get(j).value) for j in range(m.rowCount())])[i]["resolved"])
                         for i in range(m.rowCount())]
        self.assertEqual(key(a), key(b))

    def test_workspace_exports_reproduce_sections(self):
        data = load(PRJCFG)
        m = prjset_model()
        self.assertEqual(m.exportYAML(QUrl.fromLocalFile(self.tmp("p.yaml"))), "")
        self.assertEqual(load(self.tmp("p.yaml")), data["prjset"])

        a = AppSetModel()
        a.importFile(URL)
        self.assertEqual(a.exportYAML(QUrl.fromLocalFile(self.tmp("a.yaml"))), "")
        self.assertEqual(load(self.tmp("a.yaml")), data["appset"])

        logic = AppLogic()
        d = logic.importScanArr(URL)
        self.assertEqual(logic.exportScanArr(QUrl.fromLocalFile(self.tmp("s.yaml")),
                                             d["scan_items"], d["arrangements"]), "")
        self.assertEqual(load(self.tmp("s.yaml")), data["scanarr"])

    def test_single_workspace_file_still_accepted_by_section(self):
        self.assertEqual(prjcfg.section({"data": []}, "prjset"), {"data": []})
        self.assertEqual(prjcfg.section({"prjset": {"data": [1]}}, "prjset"), {"data": [1]})

    # ---- everything it generates builds together -----------------------
    @unittest.skipUnless(shutil.which("gcc"), "gcc not available")
    def test_all_generated_code_compiles_together(self):
        d = self._tmp.name
        self.assertEqual(prjset_model().exportHeader(QUrl.fromLocalFile(self.tmp("prjset.h"))), "")
        a = AppSetModel()
        a.importFile(URL)
        self.assertEqual(a.generate(QUrl.fromLocalFile(d)), "")
        logic = AppLogic()
        s = logic.importScanArr(URL)
        self.assertEqual(logic.generateScanArr(QUrl.fromLocalFile(d), s["scan_items"], s["arrangements"]), "")
        with open(self.tmp("main.c"), "w") as f:
            f.write('#include <stdio.h>\n#include "prjset.h"\n#include "appset.h"\n#include "afeScanArrg.h"\n'
                    "int main(void) {\n    appSetReset();\n"
                    '    printf("%d %d %u %u\\n", (int)FRM_SZ, (int)AFE_MUTUAL_DATA_LENGTH,\n'
                    "           (unsigned)appSetRead(APPSET_TCH_DET_THRES_ADDR, APPSET_TCH_DET_THRES_SIZE),\n"
                    "           (unsigned)AFE_SCAN_ARRG_CNT);\n    return 0;\n}\n")
        build = subprocess.run(["gcc", "-std=c99", "-Wall", "-Wextra", "-Werror", "-pedantic",
                                "appset.c", "afeScanArrg.c", "main.c", "-o", "t"],
                               cwd=d, capture_output=True, text=True)
        self.assertEqual(build.returncode, 0, build.stderr)
        out = subprocess.run([self.tmp("t")], capture_output=True, text=True).stdout
        self.assertEqual(out.strip(), "840 1684 150 2")

    # ---- it is still an exact conversion of the spreadsheet ------------
    @unittest.skipUnless(os.path.exists(XLSX), "prjcfg.xlsx not present")
    def test_matches_spreadsheet(self):
        doc, skipped = prjcfg.from_xlsx(XLSX)
        self.assertEqual(doc, load(PRJCFG), "regenerate: uv run python -m src.modules.prjcfg prjcfg.xlsx yaml/prjcfg.yaml")
        self.assertEqual(skipped, ["For ScanState Idle (Use mutual)"])

    def test_converter_usage(self):
        self.assertEqual(prjcfg.main([]), 2)


if __name__ == '__main__':
    unittest.main()
