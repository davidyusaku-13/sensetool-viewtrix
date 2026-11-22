import os
import unittest
from src.modules import prjset

# prjcfg.xlsx is gitignored, so tests using it only run where it is present.
XLSX = os.path.join(os.path.dirname(__file__), "..", "..", "prjcfg.xlsx")


def ev(text, defs=None):
    defs = defs or {}
    return prjset.evaluate(text, lambda n: defs[n])


class PrjSetExprTestCase(unittest.TestCase):
    def test_literals(self):
        self.assertEqual(ev("21"), 21)
        self.assertEqual(ev("-50"), -50)
        self.assertEqual(ev("0xD0001000"), 0xD0001000)
        self.assertEqual(ev("(500U)"), 500)

    def test_c_operators(self):
        self.assertEqual(ev("(TX > RX) ? TX : RX", {"TX": 21, "RX": 40}), 40)
        self.assertEqual(ev("(TX_LEN*2)+4", {"TX_LEN": 21}), 46)
        self.assertEqual(ev("1 << 3 | 1"), 9)
        self.assertEqual(ev("-7 / 2"), -3)  # C truncates toward zero
        self.assertEqual(ev("-7 % 2"), -1)
        self.assertEqual(ev("!0 && ~0"), 1)

    def test_errors(self):
        for bad in ["(1 +", "1 2", "1 / 0", "#", ""]:
            with self.assertRaises(prjset.ExprError, msg=bad):
                ev(bad)

    def test_analyze(self):
        res = prjset.analyze([("A", "B"), ("B", "A"), ("C", "X"), ("D", '"str"'), ("9X", "1")])
        self.assertIn("circular", res[0]["issue"])
        self.assertIn("undefined 'X'", res[2]["issue"])
        self.assertEqual(res[3], {"resolved": "", "issue": ""})
        self.assertEqual(res[4]["issue"], "invalid name")

    def test_header_value_parenthesizes_compound_expressions(self):
        self.assertEqual(prjset.header_value("21"), "21")
        self.assertEqual(prjset.header_value("-50"), "-50")
        self.assertEqual(prjset.header_value("RX_LEN"), "RX_LEN")
        self.assertEqual(prjset.header_value("(A * B)"), "(A * B)")
        self.assertEqual(prjset.header_value("(A*2)+B"), "((A*2)+B)")
        self.assertEqual(prjset.header_value("(A) + (B)"), "((A) + (B))")

    @unittest.skipUnless(os.path.exists(XLSX), "prjcfg.xlsx not present")
    def test_spreadsheet_evaluates_cleanly(self):
        items = prjset.read_prjcfg_xlsx(XLSX)
        res = dict(zip([i["name"] for i in items],
                       prjset.analyze([(i["name"], i["value"]) for i in items])))
        self.assertEqual([n for n, r in res.items() if r["issue"]], [])
        self.assertEqual(res["FRM_SZ"]["resolved"], "840")
        self.assertEqual(res["AFE_MUTUAL_DATA_LENGTH"]["resolved"], "1684")


if __name__ == '__main__':
    unittest.main()
