import os
import shutil
import subprocess
import tempfile
import unittest
from PySide6.QtCore import QUrl
from src.modules import appset
from src.models.appsetmodel import AppSetModel

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
XLSX = os.path.join(ROOT, "prjcfg.xlsx")  # gitignored: tests using it run only where present
BUNDLED = QUrl.fromLocalFile(os.path.join(ROOT, "yaml", "appset.yaml"))


def reg(addr, name, size, *fields):
    return {"addr": str(addr), "name": name, "size": str(size), "category": "", "desc": "",
            "fields": [{"name": n, "msb": str(msb), "lsb": str(lsb), "default": d} for n, msb, lsb, d in fields]}


def bundled():
    m = AppSetModel()
    assert m.importFile(BUNDLED) == ""
    return m, [m.get(i) for i in range(m.rowCount())]


class AppSetTestCase(unittest.TestCase):
    def test_bundled_file(self):
        m, regs = bundled()
        self.assertEqual(m.rowCount(), 16)
        self.assertEqual(m.issueCount, 0)
        self.assertEqual(m.bytesUsed, 19)
        by_name = {r["name"]: r for r in regs}
        self.assertEqual(by_name["tch_det_thres"]["size"], "2")
        self.assertEqual([(f["name"], f["msb"], f["lsb"]) for f in by_name["tch_in_dly"]["fields"]],
                         [("tch_out_dly", "3", "2"), ("tch_in_dly", "1", "0")])

    @unittest.skipUnless(os.path.exists(XLSX), "prjcfg.xlsx not present")
    def test_import_sheet_matches_bundled_file(self):
        _, regs = bundled()
        sheet = AppSetModel()
        self.assertEqual(sheet.importFile(QUrl.fromLocalFile(XLSX)), "")
        self.assertEqual([sheet.get(i) for i in range(sheet.rowCount())], regs)

    def test_defaults_and_layout(self):
        info = appset.analyze([
            reg(0, "ctrl", 1, ("a", 3, 2, "0x2"), ("b", 0, 0, "1")),
            reg(1, "wide", 2, ("wide", 15, 0, "0x12C")),
        ])
        self.assertEqual(info[0]["default"], "0x09")
        self.assertEqual(info[0]["layout"], "[3:2] a = 0x2   [0] b = 1")
        self.assertEqual(info[1]["default"], "0x012C")
        self.assertEqual([i["issue"] for i in info], ["", ""])

    def test_problems_are_flagged(self):
        regs = [
            reg(0, "A", 2, ("x", 7, 0, "")),
            reg(1, "B", 1, ("y", 7, 0, "")),                 # overlaps A (A covers 0..1)
            reg(2, "C", 1, ("z", 8, 0, ""), ("q", 3, 4, "")),  # out of range, lsb > msb
            reg(3, "D", 1, ("p", 3, 0, "0x10")),              # default too big
            reg(4, "E", 1, ("r", 3, 0, ""), ("s", 2, 1, "")),  # fields overlap
            reg(5, "a", 1, ("x", 0, 0, "")),                  # dup reg name (case), dup field
            reg(1023, "F", 2, ("t", 0, 0, "")),               # past the end
            reg(6, "G", 3, ("u", 0, 0, "")),                  # bad size
            reg(7, "H", 1),                                   # no fields
        ]
        text = " | ".join(i["issue"] for i in appset.analyze(regs))
        for expected in ["overlaps 'B'", "overlaps 'A'", "bits must satisfy", "does not fit in 4 bit(s)",
                         "field 's': overlaps r", "duplicate register name", "name used more than once",
                         "runs past the end", "size must be 1, 2 or 4", "has no fields"]:
            self.assertIn(expected, text)

    def test_model_sorts_by_address_and_edits(self):
        m = AppSetModel()
        m.addRegister(reg(5, "late", 1, ("late", 7, 0, "")))
        row = m.addRegister(reg(1, "early", 1, ("early", 7, 0, "")))
        self.assertEqual(row, 0)
        self.assertEqual([m.get(i)["name"] for i in range(2)], ["early", "late"])
        self.assertEqual(m.nextFreeAddress(), "6")
        self.assertEqual(m.indexOfName("LATE", -1), 1)
        self.assertEqual(m.indexOfName("late", 1), -1)
        m.editRegister(0, reg(9, "early", 1, ("early", 7, 0, "")))
        self.assertEqual([m.get(i)["name"] for i in range(2)], ["late", "early"])
        m.removeItems([0, 1])
        self.assertEqual(m.rowCount(), 0)

    def test_generate_refuses_with_problems(self):
        m = AppSetModel()
        m.addRegister(reg(0, "A", 1))
        with tempfile.TemporaryDirectory() as d:
            self.assertIn("problems", m.generate(QUrl.fromLocalFile(d)))
            self.assertFalse(os.path.exists(os.path.join(d, "appset.h")))

    def test_what_the_table_shows(self):
        m, _ = bundled()
        roles = {v.decode(): k for k, v in m.roleNames().items()}
        row = {name: m.data(m.index(0), rid) for name, rid in roles.items()}
        self.assertEqual((row["addrHex"], row["name"], row["defaultValue"], row["issue"]),
                         ("0x000", "ScanState_Ctrl", "0x01", ""))
        self.assertEqual(row["layout"], "[0] sstat_idle_en = 0x1")
        self.assertIsNone(m.data(m.index(99), roles["name"]))
        self.assertIn("Core", m.categories())
        self.assertEqual(len(m.categories()), len(set(m.categories())))

    def test_bad_input_is_refused(self):
        m, _ = bundled()
        self.assertEqual(m.editRegister(99, reg(0, "x", 1)), -1)
        m.removeItem(99)
        self.assertEqual(m.rowCount(), 16)
        with tempfile.TemporaryDirectory() as d:
            bad = os.path.join(d, "bad.yaml")
            for body, why in [("registers: 3\n", "registers"), ("registers:\n- name: a\n", "addr"),
                              ("registers:\n- {name: a, addr: 0, fields: 3}\n", "fields"), ("- 1\n", "mapping")]:
                with open(bad, "w") as f:
                    f.write(body)
                self.assertIn(why, m.importFile(QUrl.fromLocalFile(bad)))
            self.assertEqual(m.rowCount(), 16, "a failed import changes nothing")
        m.clear()
        with tempfile.TemporaryDirectory() as d:
            self.assertIn("no registers", m.generate(QUrl.fromLocalFile(d)))

    @unittest.skipUnless(shutil.which("gcc"), "gcc not available")
    def test_generated_code_compiles_and_has_right_defaults(self):
        m, _ = bundled()
        main = r'''
#include <stdio.h>
#include "appset.h"
int main(void) {
    appSetReset();
    printf("%u %u %u %u\n", (unsigned)appSetRead(APPSET_TCH_DET_THRES_ADDR, APPSET_TCH_DET_THRES_SIZE),
           (unsigned)APPSET_GET(SCANSTATE_CTRL, SSTAT_IDLE_EN), (unsigned)appSet[APPSET_TRK_DIST_THRES_ADDR + 1U],
           (unsigned)APPSET_GET(BL_RECOVERY, FCAL_M_NEG_DET_EN));
    appSetWrite(APPSET_TCH_IN_DLY_ADDR, 1U, 0x0EU);
    printf("%u %u\n", (unsigned)APPSET_GET(TCH_IN_DLY, TCH_OUT_DLY), (unsigned)APPSET_GET(TCH_IN_DLY, TCH_IN_DLY));
    return 0;
}
'''
        with tempfile.TemporaryDirectory() as d:
            self.assertEqual(m.generate(QUrl.fromLocalFile(d)), "")
            with open(os.path.join(d, "main.c"), "w") as f:
                f.write(main)
            build = subprocess.run(["gcc", "-std=c99", "-Wall", "-Wextra", "-Werror", "-pedantic",
                                    "appset.c", "main.c", "-o", "t"], cwd=d, capture_output=True, text=True)
            self.assertEqual(build.returncode, 0, build.stderr)
            out = subprocess.run([os.path.join(d, "t")], capture_output=True, text=True).stdout
        # tch_det_thres = 0x96, sstat_idle_en = 1, trk_dist_thres high byte = 0x01, neg det = 1
        # after writing 0b1110: tch_out_dly = 0b11, tch_in_dly = 0b10
        self.assertEqual(out.split("\n")[:2], ["150 1 1 1", "3 2"])


if __name__ == '__main__':
    unittest.main()
