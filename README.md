# SenseTool (app-viewtrix)

Desktop tool (PySide6 / QML) that replaces the `prjcfg.xlsx` spreadsheet: it edits
the Project Setting, App Setting and Scan Arrangement of a touch-controller
firmware, keeps them in one `prjcfg.yaml`, and generates the C files
(`prjset.h`, `appset.c/.h`, `afeScanArrg.c/.h`).

## Development

Everything runs through [uv](https://docs.astral.sh/uv/) (Python 3.12; PySide6 6.7.1 has no newer wheels).

```sh
uv run main.py                        # run the app
uv run python -m unittest             # Python tests
uv run python tests/run_qml_tests.py  # QML tests (one file: ... tests/qmlUnitTests/tst_X.qml)
uv run ruff check .                   # lint Python
uv run pyside6-qmllint $(find qml -name '*.qml')   # lint QML
uv run python -m src.modules.prjcfg prjcfg.xlsx yaml/prjcfg.yaml   # convert an updated spreadsheet
```

CI (`.github/workflows/python-app.yml`) runs the lint and both test suites on every
push and pull request; pushes to `main` also build and release the Windows app.

## How the code is organised

- `src/modules/` holds plain Python with no UI. This includes the expression evaluator and C generators
  (`prjset`, `appset`, `scanarr`, sharing `cgen`), the coefficient maths
  (`coefficients`), the update check (`updatecheck`) and file helpers (`fileio`).
- `src/models/` holds what QML talks to:
  - one model per workspace (`PrjSetModel`, `AppSetModel`, `ScanArrModel`), all
    following the small workspace interface in `workspace.py`;
  - `ProjectController`, which owns opening and saving `prjcfg.yaml`, unsaved changes and undo/redo across all
    workspaces.
- `src/app.py` creates the models and services once, and `main.py` passes them into `main.qml`. They outlive
  the QML engine, so shutdown is clean.
- `qml/` contains only presentation code. `main.qml` hands the models and services down, and pages receive them as
  properties rather than reaching for globals. Shared
  pieces live in `qml/components` (`SelectableTable` + `TableRow`/`TableCell`,
  `EditWindow`, `PageShortcuts`, `ErrorDialog`, `Theme`).

Conventions:
- **Errors:** a slot QML calls returns `""` on success or a message for the user. A slot that also returns data returns a
  dict with an `"error"` key. Internally, failures raise `fileio.UserError`.
- **Tests:** rules live in Python and are unit-tested there. QML tests pass small fakes to components to test the UI
  on its own.
