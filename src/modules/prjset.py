"""Project Setting helpers: C macro expression evaluation, validation,
prjset.h generation and import of the legacy prjcfg.xlsx spreadsheet."""

import re

IDENT_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")

_TOKEN_RE = re.compile(r"""
    (?P<ws>\s+)
  | (?P<num>0[xX][0-9A-Fa-f]+|0[bB][01]+|\d+)(?P<suffix>[uUlL]*)
  | (?P<ident>[A-Za-z_][A-Za-z0-9_]*)
  | (?P<str>"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')
  | (?P<op><<|>>|<=|>=|==|!=|&&|\|\||[-+*/%()?:<>!~&|^])
""", re.VERBOSE)

# Binary operator precedence (higher binds tighter), as in C.
_BINARY = {
    "||": 1, "&&": 2, "|": 3, "^": 4, "&": 5,
    "==": 6, "!=": 6, "<": 7, ">": 7, "<=": 7, ">=": 7,
    "<<": 8, ">>": 8, "+": 9, "-": 9, "*": 10, "/": 10, "%": 10,
}


class ExprError(Exception):
    pass


class CircularError(ExprError):
    pass


class DependentError(ExprError):
    """The expression is fine, but an item it refers to has a problem."""
    def __init__(self, root):
        super().__init__(f"depends on '{root}', which has a problem")
        self.root = root


class NotNumeric(Exception):
    """Value is valid but not a numeric expression (e.g. a string literal)."""


def tokenize(text):
    tokens, pos = [], 0
    while pos < len(text):
        m = _TOKEN_RE.match(text, pos)
        if not m:
            raise ExprError(f"unexpected character '{text[pos]}'")
        pos = m.end()
        if m.lastgroup == "ws":
            continue
        if m.group("num") is not None:
            if re.search(r"[^uUlL]", m.group("suffix") or ""):
                raise ExprError("bad number suffix")
            tokens.append(("num", int(m.group("num"), 0)))
        elif m.group("ident") is not None:
            tokens.append(("ident", m.group("ident")))
        elif m.group("str") is not None:
            tokens.append(("str", m.group("str")))
        else:
            tokens.append(("op", m.group("op")))
    return tokens


def identifiers(text):
    """Identifiers referenced by an expression (empty set if it can't be tokenized)."""
    try:
        return {v for k, v in tokenize(text) if k == "ident"}
    except ExprError:
        return set()


def _c_div(a, b):
    if b == 0:
        raise ExprError("division by zero")
    q = abs(a) // abs(b)
    return q if (a >= 0) == (b >= 0) else -q


def _c_mod(a, b):
    return a - _c_div(a, b) * b


_APPLY = {
    "||": lambda a, b: int(bool(a) or bool(b)),
    "&&": lambda a, b: int(bool(a) and bool(b)),
    "|": lambda a, b: a | b, "^": lambda a, b: a ^ b, "&": lambda a, b: a & b,
    "==": lambda a, b: int(a == b), "!=": lambda a, b: int(a != b),
    "<": lambda a, b: int(a < b), ">": lambda a, b: int(a > b),
    "<=": lambda a, b: int(a <= b), ">=": lambda a, b: int(a >= b),
    "<<": lambda a, b: a << b, ">>": lambda a, b: a >> b,
    "+": lambda a, b: a + b, "-": lambda a, b: a - b, "*": lambda a, b: a * b,
    "/": _c_div, "%": _c_mod,
}


class _Parser:
    def __init__(self, tokens, lookup):
        self.t, self.i, self.lookup = tokens, 0, lookup

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else (None, None)

    def take(self, op=None):
        tok = self.peek()
        if op is not None and tok != ("op", op):
            raise ExprError(f"expected '{op}'")
        self.i += 1
        return tok

    def parse(self):
        if not self.t:
            raise ExprError("empty value")
        v = self.ternary()
        if self.i != len(self.t):
            raise ExprError(f"unexpected '{self.peek()[1]}'")
        return v

    def ternary(self):
        cond = self.binary(1)
        if self.peek() == ("op", "?"):
            self.take()
            a = self.ternary()
            self.take(":")
            b = self.ternary()
            return a if cond else b
        return cond

    def binary(self, min_prec):
        left = self.unary()
        while True:
            kind, op = self.peek()
            prec = _BINARY.get(op) if kind == "op" else None
            if prec is None or prec < min_prec:
                return left
            self.take()
            right = self.binary(prec + 1)
            left = _APPLY[op](left, right)

    def unary(self):
        kind, val = self.peek()
        if kind == "op" and val in ("-", "+", "!", "~"):
            self.take()
            v = self.unary()
            return {"-": -v, "+": v, "!": int(not v), "~": ~v}[val]
        return self.primary()

    def primary(self):
        kind, val = self.take()
        if kind == "num":
            return val
        if kind == "ident":
            return self.lookup(val)
        if kind == "str":
            raise NotNumeric()
        if (kind, val) == ("op", "("):
            v = self.ternary()
            self.take(")")
            return v
        raise ExprError("unexpected end of value" if kind is None else f"unexpected '{val}'")


def evaluate(text, lookup):
    return _Parser(tokenize(text), lookup).parse()


def is_literal(text):
    """True for a plain number like 21, -50, 0xFF or (500U)."""
    t = text.strip()
    while t.startswith("(") and t.endswith(")") and _fully_parenthesized(t):
        t = t[1:-1].strip()
    return bool(re.fullmatch(r"-?(0[xX][0-9A-Fa-f]+|0[bB][01]+|\d+)[uUlL]*", t))


def _fully_parenthesized(t):
    if not (t.startswith("(") and t.endswith(")")):
        return False
    depth = 0
    for i, c in enumerate(t):
        depth += c == "("
        depth -= c == ")"
        if depth == 0 and i != len(t) - 1:
            return False
    return depth == 0


def analyze(items):
    """items: list of (name, value). Returns a list (same order) of
    dicts {"resolved": str, "issue": str, "dependent": bool}. `dependent` is
    true when the item's own value is fine but something it refers to is not,
    so the UI can point at the root cause."""
    names = [n for n, _ in items]
    counts = {}
    for n in names:
        counts[n] = counts.get(n, 0) + 1
    # First definition wins, as the C preprocessor would complain on redefinition anyway.
    defs = {}
    for n, v in items:
        defs.setdefault(n, v)

    cache, stack = {}, []

    def _blame(name, err):
        # Errors in a referenced item surface as "depends on <root cause>".
        if isinstance(err, (CircularError, DependentError, NotNumeric)):
            return err
        return DependentError(name)

    def resolve(name):
        if name in cache:
            res = cache[name]
            if isinstance(res, Exception):
                raise _blame(name, res)
            return res
        if name not in defs:
            raise ExprError(f"undefined '{name}'")
        if name in stack:
            raise CircularError("circular reference: " + " -> ".join(stack[stack.index(name):] + [name]))
        stack.append(name)
        try:
            res = evaluate(defs[name], resolve)
        except NotNumeric as e:
            cache[name] = e
            raise
        except ExprError as e:
            cache[name] = e
            raise _blame(name, e)
        finally:
            stack.pop()
        cache[name] = res
        return res

    out = []
    for n, v in items:
        issue, resolved, dependent = "", "", False
        if not IDENT_RE.match(n or ""):
            issue = "invalid name"
        elif counts[n] > 1:
            issue = "duplicate name"
        if not (v or "").strip():
            issue = issue or "empty value"
        else:
            stack[:] = [n]
            try:
                val = evaluate(v, resolve)
                if not is_literal(v):
                    resolved = str(val)
            except NotNumeric:
                pass
            except ExprError as e:
                if not issue:
                    issue, dependent = str(e), isinstance(e, DependentError)
            except RecursionError:
                issue = issue or "expression too deeply nested"
        out.append({"resolved": resolved, "issue": issue, "dependent": dependent})
    return out


def _c_comment(text):
    lines = [ln.rstrip() for ln in text.replace("*/", "* /").splitlines() if ln.strip()]
    if not lines:
        return []
    if len(lines) == 1:
        return [f"/* {lines[0].strip()} */"]
    return ["/*"] + [f" * {ln.strip()}" for ln in lines] + [" */"]


def header_value(value):
    v = value.strip()
    tokens = tokenize(v) if v else []
    simple = len(tokens) <= 1 or (len(tokens) == 2 and tokens[0] == ("op", "-"))
    if simple or _fully_parenthesized(v):
        return v
    return f"({v})"


def generate_header(items, guard="PRJSET_H"):
    """items: list of dicts with name, value, desc, group."""
    lines = [
        "/*",
        " * prjset.h - Project Setting",
        " * Generated by SenseTool. Do not edit by hand; edit the project",
        " * setting file and regenerate instead.",
        " */",
        "",
        f"#ifndef {guard}",
        f"#define {guard}",
    ]
    width = max([len(i["name"]) for i in items] + [0])
    current = None
    for it in items:
        group = it.get("group") or ""
        if group != current:
            current = group
            if group:
                lines += ["", f"/* {'=' * 8} {group} {'=' * 8} */"]
        lines.append("")
        lines += _c_comment(it.get("desc") or "")
        lines.append(f"#define {it['name'].ljust(width)}  {header_value(it['value'])}")
    lines += ["", f"#endif /* {guard} */", ""]
    return "\n".join(lines)


# Keywords in the spreadsheet's Comment column that name a section. Rows
# without a recognised keyword stay in the section of the row above.
_GROUP_KEYWORDS = [
    ("project information", "Project Information"),
    ("host interface", "Host Interface Related"),
    ("fw feature", "FW Feature"),
    ("data processing", "Data Processing Threshold"),
    ("afe board", "AFE Board"),
]


def _cell_str(v):
    if v is None:
        return ""
    if isinstance(v, float) and v.is_integer():
        v = int(v)
    return str(v).replace("\t", " ").strip()


def read_prjcfg_xlsx(path):
    """Read the PrjSet sheet of prjcfg.xlsx into a list of item dicts."""
    import openpyxl

    wb = openpyxl.load_workbook(path, read_only=True, data_only=False)
    if "PrjSet" not in wb.sheetnames:
        raise ValueError("sheet 'PrjSet' not found in workbook")
    rows = list(wb["PrjSet"].iter_rows(values_only=True))
    header = next((i for i, r in enumerate(rows)
                   if r and _cell_str(r[0]).lower() == "item"), None)
    if header is None:
        raise ValueError("header row with 'Item' not found in sheet 'PrjSet'")
    items, group = [], ""
    for r in rows[header + 1:]:
        r = list(r) + [None] * 4
        name = _cell_str(r[0])
        if not name:
            continue
        comment = _cell_str(r[3])
        low = comment.lower()
        for kw, g in _GROUP_KEYWORDS:
            if kw in low:
                group = g
                break
        items.append({
            "name": name,
            "value": _cell_str(r[1]),
            "desc": _cell_str(r[2]),
            "group": group,
            "comment": comment,
        })
    wb.close()
    return items
