"""Scan Arrangement helpers: import of the ScanArrg sheet of prjcfg.xlsx,
validation, and generation of afeScanArrg.h / afeScanArrg.c.

Data shape used throughout:
    scan_items:   [{"name": "AFE_END", "desc": "..."}, ...]   order = enum value
    arrangements: [{"id": 1, "name": "AFE_SCAN_ACTIVE", "desc": "...",
                    "scans": ["AFE_ON", ..., "AFE_END"]}, ...]
"""

import re
from .cgen import IDENT_RE, banner, cell_text as _s, line_comment as _comment

END = "AFE_END"           # terminator; must be value 0 so zero-filled slots end a sequence
STEP_MAX = 10             # columns #1..#10 of the ScanArrg sheet (terminator included)
SCAN_ENUM = "eAfeScanID_t"
ARRG_ENUM = "eAfeScanArrgID_t"
ARRG_STRUCT = "stAfeScanArrg_t"
ARRG_TABLE = "afeScanArrg"
ARRG_GETTER = "afeScanArrgGet"




def parse_id(value):
    """Arrangement ID as int, or None if missing/invalid."""
    text = _s(value)
    try:
        n = int(text, 0)
    except ValueError:
        return None
    return n if n >= 0 else None


# ---- import ---------------------------------------------------------------

def read_scanarrg_xlsx(path):
    """Read the ScanArrg sheet. Returns {"scan_items", "arrangements", "skipped"}
    where skipped lists descriptions of arrangement rows that had no name and no steps."""
    import openpyxl

    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    try:
        if "ScanArrg" not in wb.sheetnames:
            raise ValueError("sheet 'ScanArrg' not found in workbook")
        rows = [list(r) for r in wb["ScanArrg"].iter_rows(values_only=True)]
    finally:
        wb.close()

    header = next((i for i, r in enumerate(rows) if r and _s(r[0]).lower() == "scan name"), None)
    if header is None:
        raise ValueError("header row with 'Scan Name' not found in sheet 'ScanArrg'")
    heads = [_s(h).lower().replace(" ", "") for h in rows[header]]

    def col(*names):
        for n in names:
            if n in heads:
                return heads.index(n)
        return None

    c_desc = col("desription", "description")          # scan item description (sic in sheet)
    c_arr_desc = next((i for i, h in enumerate(heads) if h == "description" and i != c_desc), None)
    c_arr_id = col("scanarrangmentid", "scanarrangementid")
    c_arr_name = col("scanarrangmentname", "scanarrangementname")
    c_steps = [i for i, h in enumerate(heads) if re.fullmatch(r"#\d+", h)]
    if c_arr_name is None or not c_steps:
        raise ValueError("arrangement columns ('Scan ArrangmentName', '#1'...) not found in sheet 'ScanArrg'")

    items, arrangements, skipped = [], [], []
    for r in rows[header + 1:]:
        r = r + [None] * (len(heads) - len(r))
        raw = _s(r[0])
        if raw:
            # "AFE_END = 0," / "AFE_OFF,"  ->  AFE_END / AFE_OFF
            name = raw.rstrip(",").split("=")[0].strip()
            desc = _s(r[c_desc]) if c_desc is not None else ""
            # Descriptions end with the enum value, e.g. "(15).": it is shown by the app
            # and would go stale when steps are reordered.
            desc = re.sub(r"\s*\(\d+\)(\.?)\s*$", r"\1", desc)
            items.append({"name": name, "desc": desc})

        name = _s(r[c_arr_name])
        steps = [_s(r[c]) for c in c_steps if _s(r[c])]
        desc = _s(r[c_arr_desc]) if c_arr_desc is not None else ""
        if name or steps:
            arr_id = parse_id(r[c_arr_id]) if c_arr_id is not None else None
            arrangements.append({"id": arr_id if arr_id is not None else "", "name": name,
                                 "desc": desc, "scans": steps})
        elif desc:
            skipped.append(desc)
    return {"scan_items": items, "arrangements": arrangements, "skipped": skipped}


# ---- validation ------------------------------------------------------------

def analyze(scan_items, arrangements):
    """Returns a list of human-readable problems (empty when generation is safe)."""
    issues = []
    names = [i.get("name", "") for i in scan_items]
    if not names:
        issues.append("Scan items: the list is empty")
    elif names[0] != END:
        issues.append(f"Scan items: {END} must be the first item (value 0) so unused steps terminate the sequence")
    seen = set()
    for pos, n in enumerate(names):
        label = f"Scan item {pos} '{n}'"
        if not IDENT_RE.match(n):
            issues.append(f"{label}: not a valid C name")
        elif n in seen:
            issues.append(f"{label}: duplicate name")
        seen.add(n)
    known = set(names)

    if not arrangements:
        issues.append("Arrangements: the list is empty")
    seen_names, seen_ids = set(), set()
    for pos, a in enumerate(arrangements, 1):
        name = a.get("name", "")
        label = f"Arrangement {pos} '{name}'" if name else f"Arrangement {pos}"
        if not IDENT_RE.match(name):
            issues.append(f"{label}: not a valid C name")
        elif name in seen_names:
            issues.append(f"{label}: duplicate name")
        elif name in known:
            issues.append(f"{label}: name clashes with a scan item")
        seen_names.add(name)

        arr_id = parse_id(a.get("id"))
        if arr_id is None:
            issues.append(f"{label}: ID must be a non-negative whole number")
        elif arr_id in seen_ids:
            issues.append(f"{label}: duplicate ID {arr_id}")
        else:
            seen_ids.add(arr_id)

        scans = list(a.get("scans") or [])
        if not scans:
            issues.append(f"{label}: has no scan steps")
            continue
        if len(scans) > STEP_MAX:
            issues.append(f"{label}: {len(scans)} steps, at most {STEP_MAX} (including {END})")
        unknown = sorted({s for s in scans if s not in known})
        if unknown:
            issues.append(f"{label}: unknown scan step(s) {', '.join(unknown)}")
        if scans[-1] != END:
            issues.append(f"{label}: must end with {END}")
        if END in scans[:-1]:
            issues.append(f"{label}: {END} before the last step; later steps would never run")
    return issues


# ---- generation ------------------------------------------------------------



def generate_header(scan_items, arrangements):
    names = [i["name"] for i in scan_items]
    w = max(len(n) for n in names + [a["name"] for a in arrangements]) + len(" = 99,")
    lines = banner("afeScanArrg.h", "AFE scan arrangement", "scan arrangement in SenseTool") + [
        "",
        "#ifndef AFESCANARRG_H",
        "#define AFESCANARRG_H",
        "",
        "#include <stdint.h>",
        "",
        "/* Scan steps executed by the AFE. */",
        "typedef enum",
        "{",
    ]
    for value, it in enumerate(scan_items):
        entry = f"{it['name']} = {value},"
        lines.append(f"    {entry.ljust(w)}  {_comment(it.get('desc'))}".rstrip())
    lines += [
        f"    {'AFE_SCAN_ID_CNT'.ljust(w)}  /* Number of scan steps */",
        f"}} {SCAN_ENUM};",
        "",
        "/* Scan arrangements. */",
        "typedef enum",
        "{",
    ]
    for a in arrangements:
        entry = f"{a['name']} = {parse_id(a['id'])},"
        lines.append(f"    {entry.ljust(w)}  {_comment(a.get('desc'))}".rstrip())
    lines += [
        f"}} {ARRG_ENUM};",
        "",
        f"#define AFE_SCAN_ARRG_CNT       ({len(arrangements)}U)",
        f"#define AFE_SCAN_ARRG_STEP_MAX  ({STEP_MAX}U)",
        "",
        "typedef struct",
        "{",
        f"    {ARRG_ENUM} id;",
        f"    {SCAN_ENUM} scan[AFE_SCAN_ARRG_STEP_MAX]; /* terminated by {END} */",
        f"}} {ARRG_STRUCT};",
        "",
        f"extern const {ARRG_STRUCT} {ARRG_TABLE}[AFE_SCAN_ARRG_CNT];",
        "",
        "/* Scan steps of arrangement `id`, or NULL if there is no such arrangement. */",
        f"const {SCAN_ENUM} *{ARRG_GETTER}({ARRG_ENUM} id);",
        "",
        "#endif /* AFESCANARRG_H */",
        "",
    ]
    return "\n".join(lines)


def generate_source(arrangements):
    lines = banner("afeScanArrg.c", "AFE scan arrangement table", "scan arrangement in SenseTool") + [
        "",
        "#include <stddef.h>",
        '#include "afeScanArrg.h"',
        "",
        f"const {ARRG_STRUCT} {ARRG_TABLE}[AFE_SCAN_ARRG_CNT] =",
        "{",
    ]
    for a in arrangements:
        c = _comment(a.get("desc"))
        if c:
            lines.append(f"    {c}")
        lines.append(f"    {{ {a['name']}, {{ {', '.join(a['scans'])} }} }},")
    lines += [
        "};",
        "",
        f"const {SCAN_ENUM} *{ARRG_GETTER}({ARRG_ENUM} id)",
        "{",
        "    for (uint32_t i = 0U; i < AFE_SCAN_ARRG_CNT; i++)",
        "    {",
        f"        if ({ARRG_TABLE}[i].id == id)",
        "        {",
        f"            return {ARRG_TABLE}[i].scan;",
        "        }",
        "    }",
        "    return NULL;",
        "}",
        "",
    ]
    return "\n".join(lines)
