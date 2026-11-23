"""Application Setting helpers: import of the AppSet sheet of prjcfg.xlsx,
validation, and generation of appset.h / appset.c.

AppSet is a byte-addressed register map (1 KB). A register is 1, 2 or 4
bytes at an address and holds bit fields with default values.

Register dict (all values may be text as typed in the UI):
    {"addr": "5", "name": "tch_det_thres", "size": "2", "category": "Frame",
     "desc": "...", "fields": [{"name": "tch_det_thres", "msb": "15", "lsb": "0",
                                "default": "0x96"}]}

Multi-byte registers are little-endian: the byte at `addr` is the least
significant one.
"""

import re
from .cgen import IDENT_RE, banner, cell_text as _s, line_comment as _comment

APPSET_SIZE = 1024          # "support size of 1K byte" (prjcfg.xlsx ReadMe, 2023-08-18)
SIZES = (1, 2, 4)
PREFIX = "APPSET_"

_FIELD_RE = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?:\[\s*([^\]]*?)\s*\])?\s*$")
RESERVED = {"reserve", "reserved", "rsvd"}



def to_int(v):
    """int from int/'12'/'0x1F'/'0b101', or None."""
    if isinstance(v, bool):
        return None
    if isinstance(v, int):
        return v
    t = _s(v)
    if not t:
        return None
    try:
        return int(t, 0)
    except ValueError:
        # "010" style decimals are rejected by int(x, 0)
        return int(t) if t.isdigit() else None


# ---- import ---------------------------------------------------------------

def read_appset_xlsx(path):
    """Read the AppSet sheet into a list of register dicts."""
    import openpyxl

    # Merged cells are needed, so this cannot use read_only mode.
    wb = openpyxl.load_workbook(path, data_only=True)
    try:
        if "AppSet" not in wb.sheetnames:
            raise ValueError("sheet 'AppSet' not found in workbook")
        ws = wb["AppSet"]
        heads = {}
        header = None
        for r in range(1, min(ws.max_row, 20) + 1):
            if _s(ws.cell(r, 1).value).lower() == "addr":
                header = r
                for c in range(1, ws.max_column + 1):
                    heads[_s(ws.cell(r, c).value).lower().replace(" ", "")] = c
                break
        if header is None:
            raise ValueError("header row with 'Addr' not found in sheet 'AppSet'")
        try:
            c_name, c_bit7, c_bit0 = heads["name"], heads["bit7"], heads["bit0"]
        except KeyError as e:
            raise ValueError(f"column {e} not found in sheet 'AppSet'") from e
        c_desc, c_cat = heads.get("description"), heads.get("category")

        # top-left cell -> (rows, cols) span; covered cells -> top-left
        span, covered = {}, {}
        for m in ws.merged_cells.ranges:
            span[(m.min_row, m.min_col)] = (m.max_row - m.min_row + 1, m.max_col - m.min_col + 1)
            for r in range(m.min_row, m.max_row + 1):
                for c in range(m.min_col, m.max_col + 1):
                    if (r, c) != (m.min_row, m.min_col):
                        covered[(r, c)] = (m.min_row, m.min_col)

        regs, r = [], header + 1
        while r <= ws.max_row:
            has_content = any(_s(ws.cell(r, c).value) for c in range(c_name, c_bit0 + 1)) \
                and (r, c_name) not in covered
            if not has_content:
                r += 1
                continue
            # Size from the tallest merge starting on this row (name, bits, description).
            rows = 1
            for c in list(range(c_name, c_bit0 + 1)) + [c for c in (c_desc, c_cat) if c]:
                rows = max(rows, span.get((r, c), (1, 1))[0])
            fields = []
            for k in range(rows):
                for c in range(c_bit7, c_bit0 + 1):
                    if (r + k, c) in covered:
                        continue
                    text = _s(ws.cell(r + k, c).value)
                    if not text:
                        continue
                    h, w = span.get((r + k, c), (1, 1))
                    m = _FIELD_RE.match(text)
                    if not m:
                        raise ValueError(f"row {r + k}: cannot read bit field '{text}'")
                    if m.group(1).lower() in RESERVED:
                        continue
                    hi_col, lo_col = c, c + w - 1
                    lsb = k * 8 + (c_bit0 - lo_col)
                    msb = (k + h - 1) * 8 + (c_bit0 - hi_col)
                    fields.append({"name": m.group(1), "msb": str(msb), "lsb": str(lsb),
                                   "default": m.group(2) or ""})
            fields.sort(key=lambda f: -int(f["msb"]))
            regs.append({
                "addr": _s(ws.cell(r, 1).value),
                "name": _s(ws.cell(r, c_name).value),
                "size": str(rows),
                "category": _s(ws.cell(r, c_cat).value) if c_cat else "",
                "desc": _s(ws.cell(r, c_desc).value) if c_desc else "",
                "fields": fields,
            })
            r += rows
    finally:
        wb.close()
    return regs


# ---- validation ------------------------------------------------------------

def analyze(regs):
    """Per register (same order): {"issue": str, "default": "0x..", "layout": str}."""
    parsed = []
    for reg in regs:
        parsed.append((to_int(reg.get("addr")), to_int(reg.get("size"))))

    reg_names = {}
    field_names = {}
    for i, reg in enumerate(regs):
        reg_names.setdefault(_s(reg.get("name")).upper(), []).append(i)
        for f in reg.get("fields") or []:
            field_names.setdefault(_s(f.get("name")).upper(), []).append(i)

    out = []
    for i, reg in enumerate(regs):
        issues = []
        addr, size = parsed[i]
        name = _s(reg.get("name"))
        if not IDENT_RE.match(name):
            issues.append("invalid name")
        elif len(reg_names[name.upper()]) > 1:
            issues.append("duplicate register name")
        if addr is None or not 0 <= addr < APPSET_SIZE:
            issues.append(f"address must be 0..{APPSET_SIZE - 1}")
        if size not in SIZES:
            issues.append("size must be 1, 2 or 4 bytes")
        if addr is not None and size in SIZES:
            if addr + size > APPSET_SIZE:
                issues.append(f"runs past the end of the {APPSET_SIZE}-byte table")
            for j, (a2, s2) in enumerate(parsed):
                if j != i and a2 is not None and s2 in SIZES and addr < a2 + s2 and a2 < addr + size:
                    issues.append(f"overlaps '{_s(regs[j].get('name'))}'")
                    break

        bits = size * 8 if size in SIZES else 32
        used = [None] * bits
        value = 0
        layout = []
        fields = reg.get("fields") or []
        if not fields:
            issues.append("has no fields")
        for f in fields:
            fname = _s(f.get("name"))
            msb, lsb, dflt = to_int(f.get("msb")), to_int(f.get("lsb")), _s(f.get("default"))
            dval = to_int(dflt) if dflt else 0
            if not IDENT_RE.match(fname):
                issues.append(f"field '{fname}': invalid name")
            elif len(field_names[fname.upper()]) > 1:  # in this or another register
                issues.append(f"field '{fname}': name used more than once")
            if msb is None or lsb is None or not 0 <= lsb <= msb < bits:
                issues.append(f"field '{fname}': bits must satisfy 0 <= lsb <= msb <= {bits - 1}")
                continue
            width = msb - lsb + 1
            if dval is None or not 0 <= dval < (1 << width):
                issues.append(f"field '{fname}': default {dflt} does not fit in {width} bit(s)")
                dval = 0
            clash = {used[b] for b in range(lsb, msb + 1) if used[b]}
            if clash:
                issues.append(f"field '{fname}': overlaps {', '.join(sorted(clash))}")
            for b in range(lsb, msb + 1):
                used[b] = used[b] or fname
            value |= dval << lsb
            span = f"{msb}" if msb == lsb else f"{msb}:{lsb}"
            layout.append(f"[{span}] {fname}" + (f" = {dflt}" if dflt else ""))
        digits = 2 * (size if size in SIZES else 1)
        out.append({"issue": "; ".join(dict.fromkeys(issues)),
                    "default": f"0x{value:0{digits}X}",
                    "layout": "   ".join(layout),
                    "value": value})
    return out


# ---- generation ------------------------------------------------------------



def _sorted(regs):
    return sorted(regs, key=lambda r: to_int(r.get("addr")))


def generate_header(regs):
    regs = _sorted(regs)
    defs = []  # (macro, value, comment) per register, None for a blank/banner line

    def add(name, value, comment=""):
        defs.append((f"{PREFIX}{name.upper()}", value, comment))

    current = None
    for reg in regs:
        cat = _s(reg.get("category"))
        if cat != current:
            current = cat
            defs.append(("banner", cat or "Uncategorised", ""))
        addr, size = to_int(reg["addr"]), to_int(reg["size"])
        defs.append(("blank", "", ""))
        desc = _s(reg.get("desc"))
        defs.append(("comment", f"{reg['name']} (0x{addr:03X}, {size} byte{'s' if size > 1 else ''})"
                     + (f": {desc}" if desc else ""), ""))
        add(f"{reg['name']}_ADDR", f"(0x{addr:03X}U)")
        add(f"{reg['name']}_SIZE", f"({size}U)")
        for f in reg.get("fields") or []:
            msb, lsb = to_int(f["msb"]), to_int(f["lsb"])
            width = msb - lsb + 1
            mask = ((1 << width) - 1) << lsb
            dval = to_int(f.get("default")) if _s(f.get("default")) else 0
            add(f"{f['name']}_POS", f"({lsb}U)")
            add(f"{f['name']}_MSK", f"(0x{mask:0{2 * size}X}U)")
            add(f"{f['name']}_DFLT", f"(0x{dval:X}U)")

    width = max([len(m) for m, _, _ in defs if m not in ("banner", "blank", "comment")] + [24])
    lines = banner("appset.h", "Application Setting register map", "application setting in SenseTool") + [
        "",
        "#ifndef APPSET_H",
        "#define APPSET_H",
        "",
        "#include <stdint.h>",
        "",
        "/* Size of the application setting table in bytes. */",
        f"#define {'APPSET_SIZE'.ljust(width)}  ({APPSET_SIZE}U)",
    ]
    for macro, value, _ in defs:
        if macro == "banner":
            lines += ["", f"/* {'=' * 8} {value} {'=' * 8} */"]
        elif macro == "blank":
            lines.append("")
        elif macro == "comment":
            lines.append(_comment(value))
        else:
            lines.append(f"#define {macro.ljust(width)}  {value}")
    lines += [
        "",
        "/* Live settings (writable at runtime) and their power-on defaults. */",
        "extern uint8_t appSet[APPSET_SIZE];",
        "extern const uint8_t appSetDefault[APPSET_SIZE];",
        "",
        "/* Restore every setting to its default. */",
        "void appSetReset(void);",
        "/* Little-endian read/write of a `size`-byte register (size 1, 2 or 4). */",
        "uint32_t appSetRead(uint16_t addr, uint8_t size);",
        "void appSetWrite(uint16_t addr, uint8_t size, uint32_t value);",
        "",
        "/* Field access, e.g. APPSET_GET(TCH_IN_DLY, TCH_OUT_DLY). */",
        "#define APPSET_GET(REG, FIELD) \\",
        "    ((appSetRead(APPSET_##REG##_ADDR, APPSET_##REG##_SIZE) & APPSET_##FIELD##_MSK) >> APPSET_##FIELD##_POS)",
        "",
        "#endif /* APPSET_H */",
        "",
    ]
    return "\n".join(lines)


def generate_source(regs):
    regs = _sorted(regs)
    info = analyze(regs)
    lines = banner("appset.c", "Application Setting defaults and access", "application setting in SenseTool") + [
        "",
        "#include <string.h>",
        '#include "appset.h"',
        "",
        "uint8_t appSet[APPSET_SIZE];",
        "",
        "const uint8_t appSetDefault[APPSET_SIZE] =",
        "{",
    ]
    for reg, a in zip(regs, info):
        addr, size = to_int(reg["addr"]), to_int(reg["size"])
        for k in range(size):
            byte = (a["value"] >> (8 * k)) & 0xFF
            if byte:
                part = f" byte {k}" if size > 1 else ""
                lines.append(f"    [0x{addr + k:03X}] = 0x{byte:02X}U, /* {reg['name']}{part} */")
    lines += [
        "};",
        "",
        "void appSetReset(void)",
        "{",
        "    (void)memcpy(appSet, appSetDefault, sizeof(appSet));",
        "}",
        "",
        "uint32_t appSetRead(uint16_t addr, uint8_t size)",
        "{",
        "    uint32_t value = 0U;",
        "    for (uint8_t i = 0U; (i < size) && ((uint32_t)addr + i < APPSET_SIZE); i++)",
        "    {",
        "        value |= (uint32_t)appSet[addr + i] << (8U * i);",
        "    }",
        "    return value;",
        "}",
        "",
        "void appSetWrite(uint16_t addr, uint8_t size, uint32_t value)",
        "{",
        "    for (uint8_t i = 0U; (i < size) && ((uint32_t)addr + i < APPSET_SIZE); i++)",
        "    {",
        "        appSet[addr + i] = (uint8_t)(value >> (8U * i));",
        "    }",
        "}",
        "",
    ]
    return "\n".join(lines)
