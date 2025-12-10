# Copilot / AI Agent Instructions for SenseTool (Viewtrix)

This file contains specific, actionable guidance to help AI coding agents (Copilot, Code Assistants, etc.) be productive in this repository.

## 🚀 Big picture (what this repo is / how it works)

- This is a PySide6 (Qt for Python) desktop app with a QML UI: UI in `qml/`, Python business logic in `src/`.
- Python is the bridge between QML and the app logic. QML types are registered via `@QmlElement` and `QML_IMPORT_NAME` in Python classes (see `src/models/`, `src/modules/`).
- Main entry point: `main.py` — sets up `QApplication`, `QQmlApplicationEngine`, registers context properties (e.g., `translator`, `updateManager`) and loads `qml/main.qml`.

## 🔧 Top-level architecture components

- src/core/ — base classes and configuration:
  - `config.py` — central AppConfig and ConfigManager (reads `modules/config.ini`).
  - `base.py` — `BaseQmlObject`, `BaseService`, and validation mixins used across services and models.
- src/modules/ — QML-facing modules and app wiring:
  - `logic.py` — `AppLogic` is the main QML interface (by `@QmlElement QML_IMPORT_NAME="AppLogic"`). This exposes slots for coefficient generation, imports/exports, update checks, etc.
  - `translator.py` & `updater.py` — QML-exposed helper objects set as context properties in `main.py`.
  - `logger.py` — logging singleton used by modules and services.
- src/services/ — business logic & IO:
  - `coefficient_service.py` — coefficient generators, validation. Important functions: `generate_window_coefficients`, `generate_demo_coefficients`, and helpers.
  - `file_service.py` — YAML import/export for demo/window coefficients and project settings; uses `PySide6.QtCore.QUrl` or `Path` for paths.
  - `update_service.py` — checks GitHub releases via config and supports download workers.
- src/models/ — QAbstractListModel-based models exposed to QML:
  - `prjsetmodel.py`, `historymodel.py`, and item classes (PrjSetModelItem, HistoryModelItem). They use `QAbstractListModel` role and roleNames pattern.
- qml/ — the UI, which imports the above QML types (e.g., `import AppLogic`, `import PrjSetModel`). Root QML file: `qml/main.qml`.

## 📁 Integration points and conventions you must follow

- QML registration: Use `@QmlElement` and set `QML_IMPORT_NAME` + `QML_IMPORT_MAJOR_VERSION`. Example in `src/modules/logic.py`:
  - QML: `import AppLogic` (appears in `qml/main.qml`), then `property AppLogic logic: AppLogic{}`
- File handling: QML uses `QUrl.fromLocalFile()` to pass file URIs. Python services expect either `QUrl` or `Path`/`str` and validate content & extension (YAML only).
- Logging conventions: Use `AppLogger.get_instance()` and `logger.log("message", "INFO")` (string log level). Logs are in `./logs/app.log`.
- Versioning & updates: `src/core/config.py` exposes `get_version()` which reads `VERSION.txt` — used by update checks in `update_service.py` and `AppLogic.checkUpdate()`.
- QML exposes Python objects and uses CamelCase method names for QML calls. Python code uses snake_case for internal functions and camelCase for QML-exposed functions where appropriate (e.g., `win_coef_gen`, `exportWinCoef`).

## 🧭 How to get the app running (dev) — commands & workflows

- Recommended environment (Windows example):
  1. Create venv & activate (PowerShell):

```pwsh
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

2. Install runtime dependencies:

```pwsh
python -m pip install --upgrade pip
pip install -r requirements.txt
pip install invoke pytest pytest-cov pytest-xvfb
```

3. Dev run the app:

```pwsh
invoke run
# alternative: python main.py
```

- Build/Resource pipeline (used in `invoke run`):
  - `pyside6-rcc ./resource.qrc -o ./resource_rc.py` to compile resources.
- Packaging: `pyside6-deploy -f` (used in `invoke deploy` which will attempt to rename an exe to `main.exe`). See `tasks.py` for details.

## ✅ How tests run and testing conventions

- Unit tests live in `tests/pyUnitTests` and use Python `unittest` (PySide-friendly). `pytest` can also run them since it collects `unittest` tests.
- QML tests: `qmltestrunner` is used, and `invoke test` runs both Python tests and QML tests via `qmltestrunner.exe`. It outputs `qmltestres.txt` (see `tasks.py`).
- Tests that depend on Qt must ensure `QApplication` exists. Many tests call `QApplication.instance()` or create it if not present (see `test_logic.py`).
- For new tests: follow the `unittest` pattern and ensure `QApplication` is created where needed.

## 🔍 Common code patterns & best practices specific to this project

- PySide QML bindings:
  - QML-exposed classes typically inherit `QObject` or `QAbstractListModel` and use `@QmlElement`.
  - Use `roleNames()` in models to expose data to QML by names such as `name`, `value`, `desc`.
- Services and logging:
  - Business logic lives in `src/services/`. Services initialize via `initialize()` and should return a boolean. Use `BaseService` and `ValidationMixin` where possible.
  - Always `AppLogger.get_instance()` and use `_log_info/_log_error/_log_debug` wrappers.
- File I/O & YAML:
  - FileService validates supported extensions (`.yaml`, `.yml`) and data structure for YAML contents.
  - Files are written with `yaml.dump` and read with `yaml.safe_load`.
- QML-Python method names & types:
  - QML calls expect specific types, e.g., sequences are often passed as `list` of numbers and `QUrl` for files; method signatures in slots include `QUrl`, `list`, `int`, `float`, `str`.

## ⚠️ Notable edge cases, TODOs, and inconsistencies

- Demo coefficient mismatch: `AppLogic.demo_coef_gen` expects `generate_demo_coefficients` to return both `i_coefficients` and `q_coefficients` but the `DemoCoefficients` dataclass in `coefficient_service.py` only stores a single `coefficients` list. This is a functional mismatch and likely to cause runtime errors — check tests and code paths.
- tests vs `invoke test`: `tasks.py` uses `unittest` command (`python -m unittest -v`) while most TDD uses `pytest`. Both are acceptable but tests in `tests/pyUnitTests` are `unittest`-based; `pytest` will also discover them.
- QML & context properties: Many Python objects are accessible by QML via `@QmlElement` registration or via `engine.rootContext().setContextProperty` (see `translator` and `updateManager` in `main.py`). Prefer @QmlElement types for new UI models before context properties when possible.

## 🔁 How to add a new QML-exposed service or model (example)

- For a new model:
  1. Create a model `src/models/newmodel.py` inheriting `QAbstractListModel`.
  2. Define `QML_IMPORT_NAME = "NewModel"` and `QML_IMPORT_MAJOR_VERSION = 1`.
  3. Add `@QmlElement` decorator and implement `rowCount`, `data`, and `roleNames`.
  4. Expose to QML with `import NewModel` then `property NewModel nm: NewModel {}`.
- For a new service usable from QML:
  1. Create under `src/modules/` and use `@QmlElement` (if it interacts directly with QML) or place under `src/services/` if it’s pure logic.
  2. Use `BaseService` and/or `BaseQmlObject` for uniform logging/config.

## 🧪 Running tests & debugging locally

- Run Python unit tests:

```pwsh
pytest tests/   # or python -m unittest -v
```

- Run QML unit tests (Windows):

```pwsh
# qmltestrunner must be installed/available on PATH
qmltestrunner.exe -o qmltestres.txt
Get-Content qmltestres.txt  # PowerShell
```

- Enable verbose logs: `src/modules/logger.py` uses `RotatingFileHandler` to `./logs/app.log`.

## 📘 Where to look next (important files)

- `main.py` — app entrypoint, context properties, engine setup
- `qml/main.qml` — root QML file showing how registered types are used
- `src/modules/logic.py` — primary QML->Python bridge for app features
- `src/services/*` — app logic and backends (coefficient, file, update)
- `src/models/*` — QAbstractListModel implementations
- `tasks.py` — helper commands for development: build, test, run, deploy
- `requirements.txt` & `README.md` — dependencies and development workflow

## 💡 Tips for AI/automation tasks

- When editing QML or Python, make minimal, testable changes using existing patterns (e.g., roleNames in models, or adding QML-importable types).
- Prefer using `FileService` and `CoefficientService` for business logic operations rather than embedding YAML parsing logic inside QML-facing modules.
- If adding network calls (e.g., release checks), follow `UpdateService` timeouts and error handling patterns.
- Tests that need a `QApplication` instance already follow an idiom; reuse that pattern when writing new tests.

## 🔖 Commit guidelines (Conventional Commits)

- This repository follows Conventional Commits for clear changelogs and semantic versioning; see https://www.conventionalcommits.org/en/v1.0.0/ for the full spec.
- Use clear, short scope and type in commit messages, for example:
  - `feat(coefficient): add I/Q output for demo coefficients`
  - `fix(file): validate YAML 'data' fields before import`
  - `chore: bump pyside6 version`
- For breaking changes, use the `BREAKING CHANGE:` footer in your commit body. Example:

  ```
  feat(coefficient)!: change return format for demo coefficients

  BREAKING CHANGE: demo_coef_gen now returns {i_coefficients, q_coefficients}
  ```

- Reference related issues/PRs using `(#123)` or `refs #123` where applicable.
- Rationale: Conventional commits help the project's `GitVersion.yml` and CI to infer the next semantic version bump and automatically create release notes.

## ⚠️ CI / Packaging notes (Nuitka & Python compatibility)

- The Windows build uses `pyside6-deploy` which invokes Nuitka for packaging. Nuitka versions may not support the latest Python (e.g., Nuitka 2.1 does not support Python 3.12).
- CI currently pins the build job to Python 3.11 to avoid Nuitka compatibility issues. If you need to use Python 3.12, update Nuitka (or pyside6-deploy) to a version that supports it.
- When debugging deployment failures, inspect the CI logs for the actual Python version used by `pyside6-deploy` and examine `nuitka` output. A helpful pre-build step in workflows is:

  ```pwsh
  python --version
  pip --version
  ```

  This ensures the correct interpreter is used and is very useful when diagnosing `pyside6-deploy` installation behavior.

- CI enforcement: The Windows deployment job verifies the runtime interpreter is Python 3.11 before proceeding with packaging; if a mismatch is detected the job fails early to avoid running Nuitka with an unsupported interpreter.

- When the deployment check fails, the workflow prints helpful diagnostics and points to this documentation section. Suggested next steps if the check fails:
  - Confirm the job uses Python 3.11 (check `actions/setup-python` and/or workflow env). If not using 3.11, update your workflow to set Python to 3.11 for the build job.
  - If you need to support Python 3.12, update `Nuitka` (or `pyside6-deploy`) to a version that supports it and adjust the workflow accordingly.
  - If this is unexpected and you believe there's a toolchain issue, open a GitHub issue and include CI logs and the `python --version` / `pip --version` output shown in CI for faster triage.

---

Please review these instructions for clarity and completeness. If you want, I can:

- Merge additional content from a later `AGENT.md` if you create one
- Add specific unit / integration test examples
- Add a quick snippet for implementing a new `@QmlElement`-exposed service

Feedback requested: are there any additional patterns or developer steps you want included (packaging nuances, CI secrets, or expected target platform peculiarities)?
