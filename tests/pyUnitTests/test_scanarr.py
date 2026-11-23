import os
import shutil
import subprocess
import tempfile
import unittest
import yaml
from src.modules import scanarr

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
XLSX = os.path.join(ROOT, "prjcfg.xlsx")  # gitignored: tests using it run only where present


def bundled():
    with open(os.path.join(ROOT, "yaml", "scanarr.yaml")) as f:
        d = yaml.safe_load(f)
    items = [{"name": i["name"], "desc": i["desc"] or ""} for i in d["scan_items"]]
    return items, d["arrangements"]


class ScanArrTestCase(unittest.TestCase):
    def test_bundled_file_is_valid(self):
        items, arrs = bundled()
        self.assertEqual(scanarr.analyze(items, arrs), [])
        self.assertEqual(items[0]["name"], "AFE_END")
        self.assertEqual(len(items), 16)
        self.assertEqual([a["name"] for a in arrs], ["AFE_SCAN_ACTIVE", "AFE_SCAN_IDLE"])

    @unittest.skipUnless(os.path.exists(XLSX), "prjcfg.xlsx not present")
    def test_import_sheet_matches_bundled_file(self):
        d = scanarr.read_scanarrg_xlsx(XLSX)
        items, arrs = bundled()
        self.assertEqual(d["scan_items"], items)
        self.assertEqual([(a["id"], a["name"], a["scans"]) for a in d["arrangements"]],
                         [(a["id"], a["name"], a["scans"]) for a in arrs])
        self.assertEqual(d["skipped"], ["For ScanState Idle (Use mutual)"])
        # value hints like "(15)." are dropped from descriptions
        self.assertFalse(any(i["desc"].rstrip(".").endswith(")") and "(" in i["desc"][-6:]
                             for i in d["scan_items"]))

    def test_analyze_catches_problems(self):
        items = [{"name": "AFE_END"}, {"name": "AFE_ON"}, {"name": "AFE_ON"}]
        arrs = [
            {"id": 1, "name": "A", "scans": ["AFE_ON"]},                      # no terminator
            {"id": 1, "name": "B", "scans": ["AFE_END", "AFE_ON", "AFE_END"]},  # dup id, early END
            {"id": "x", "name": "AFE_ON", "scans": ["NOPE", "AFE_END"]},        # bad id, clash, unknown
            {"id": 4, "name": "D", "scans": ["AFE_ON"] * 10 + ["AFE_END"]},     # too long
            {"id": 5, "name": "E", "scans": []},
        ]
        text = "\n".join(scanarr.analyze(items, arrs))
        for expected in ["duplicate name", "must end with AFE_END", "duplicate ID 1",
                         "before the last step", "ID must be", "clashes with a scan item",
                         "unknown scan step(s) NOPE", "11 steps", "has no scan steps"]:
            self.assertIn(expected, text)
        self.assertIn("must be the first item",
                      "\n".join(scanarr.analyze([{"name": "AFE_ON"}, {"name": "AFE_END"}], [])))

    def test_generated_code(self):
        items, arrs = bundled()
        h = scanarr.generate_header(items, arrs)
        c = scanarr.generate_source(arrs)
        self.assertIn("AFE_END = 0,", h)
        self.assertIn("AFE_PROC_DATA = 15,", h)
        self.assertIn("AFE_SCAN_IDLE = 2,", h)
        self.assertIn("#define AFE_SCAN_ARRG_CNT       (2U)", h)
        self.assertIn("{ AFE_SCAN_IDLE, { AFE_ON, AFE_MSN_ACTIVE, AFE_PROC_DATA, AFE_SSTX_IDLE, "
                      "AFE_PROC_DATA, AFE_OFF, AFE_END } },", c)

    @unittest.skipUnless(shutil.which("gcc"), "gcc not available")
    def test_generated_code_compiles(self):
        items, arrs = bundled()
        with tempfile.TemporaryDirectory() as d:
            with open(os.path.join(d, "afeScanArrg.h"), "w") as f:
                f.write(scanarr.generate_header(items, arrs))
            with open(os.path.join(d, "afeScanArrg.c"), "w") as f:
                f.write(scanarr.generate_source(arrs))
            res = subprocess.run(["gcc", "-std=c99", "-Wall", "-Wextra", "-Werror", "-pedantic",
                                  "-c", "afeScanArrg.c", "-o", "afeScanArrg.o"],
                                 cwd=d, capture_output=True, text=True)
        self.assertEqual(res.returncode, 0, res.stderr)


if __name__ == '__main__':
    unittest.main()
