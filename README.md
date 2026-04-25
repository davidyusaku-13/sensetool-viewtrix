[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](./LICENSE.txt)

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3).
See `LICENSE.txt` for the full license text.

Copyright (C) 2025 davidyusaku-13

## Tech Stack

This project is built using the following main technologies:

- **Language:** Python 3.9–3.12
- **UI framework:** PySide6 (Qt for Python) + QML (Qt Quick)
- **Packaging:** PySide6 deploy / Nuitka (packaging to executable)
- **Build & CI:** GitHub Actions (matrixed tests on Windows/Linux/macOS)
- **Testing:** pytest (unit tests), qmltestrunner (QML unit tests)
- **Linting / Type checking:** flake8, mypy
- **Security scanning:** bandit (static analysis), safety (dependency security)
- **Versioning:** GitVersion (semantic versioning via `GitVersion.yml`)
- **Other tools:** Invoke task runner (`tasks.py`), PyYAML, requests

Supported platforms and environments reflected in CI:

- Windows, macOS, and Ubuntu/Linux
- Python versions: 3.9, 3.10, 3.11, 3.12

## Quick start (dev)

1. Create and activate a virtual environment (Windows example):

```pwsh
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

2. Install dependencies:

```pwsh
python -m pip install --upgrade pip
pip install -r requirements.txt
pip install invoke pytest pytest-cov pytest-xvfb
```

3. Run the application (dev):

```pwsh
invoke run
```

4. Run tests:

```pwsh
pytest tests/
```

## CI / CD notes

- The repository uses GitHub Actions to run tests, linting, and security scans across multiple platforms. `CI` runs on pull requests and manual dispatch, while `Release` runs only from manual workflow dispatch and bumps semver from the latest tag.
- Releases build platform assets: `sensetool-windows-<version>.exe`, `sensetool-linux-<version>`, and `sensetool-macos-<version>.dmg`.
