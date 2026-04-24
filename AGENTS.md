# Repository Guidelines

## Project Structure & Module Organization
`main.py` is the desktop app entry point. Python application code lives under `src/`: `core/` for shared base/config code, `modules/` for QML-facing controllers such as `logic.py`, `services/` for business logic and file/update handling, and `models/` for `QAbstractListModel` implementations. QML UI files live in `qml/`, with reusable pieces in `qml/components/` and `qml/layouts/`, and feature pages under `qml/pages/`. Tests are split between `tests/pyUnitTests/` for Python logic and `tests/qmlUnitTests/` for QML views. Static assets include `resource.qrc`, `resource_rc.py`, `translations/`, `yaml/`, and `qml/images/`.

## Build, Test, and Development Commands
Create a virtual environment, then install deps with `pip install -r requirements.txt` plus dev tools from `README.md` such as `invoke` and `pytest`.

- `invoke run` builds Qt resources with `pyside6-rcc` and starts the app.
- `invoke build` regenerates `resource_rc.py` from `resource.qrc`.
- `pytest tests/ -v --tb=short` runs Python tests the same way CI does.
- `python -m unittest -v` also works because the Python tests are `unittest`-based.
- `qmltestrunner tests/qmlUnitTests` runs QML tests when Qt test tooling is installed.

## Coding Style & Naming Conventions
Use 4-space indentation in Python and follow existing module structure before adding new files. Prefer `snake_case` for Python modules, functions, and internal methods; preserve `camelCase` only where QML-facing APIs already use it. Keep QML component filenames in `PascalCase` such as `PrjSetWindow.qml`. Match the existing lint target used in CI: `flake8` with `--max-line-length=127` and complexity capped at 10.

## Testing Guidelines
Add Python unit tests beside related coverage in `tests/pyUnitTests/` with names like `test_logic.py`. Add QML view tests under `tests/qmlUnitTests/` with `tst_*.qml` names. Qt-dependent Python tests should ensure a `QApplication` instance exists before exercising models or slots. Run `pytest tests/` before opening a PR; run QML tests for UI changes.

## Commit & Pull Request Guidelines
Recent history uses Conventional Commits such as `fix: ...` and `refactor: ...`; continue that format and keep subjects concise. PRs should describe the user-visible change, note affected areas (`src/services`, `qml/pages`, etc.), link issues when relevant, and include screenshots or short recordings for QML/UI updates. Call out any platform-specific behavior, especially Windows-only packaging or `qmltestrunner.exe` assumptions in `tasks.py`.

## Configuration & Release Notes
Treat `src/modules/config.ini`, `VERSION.txt`, and YAML fixtures in `yaml/` as runtime inputs; update them deliberately and mention changes in the PR. CI tests on Windows, macOS, and Ubuntu, while release packaging uses Python 3.11, so avoid unverified packaging changes.
