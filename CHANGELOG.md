# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

### Removed

## [0.2.1] - 2026-04-25

### Changed

- ci: let release action create tags instead of manual tagging
- ci: update artifact actions for Node 24 compatibility
- ci: split checks and release workflows for cleaner gates
- ci: run release workflow manually
- ci: update actions for Node 24

### Fixed

- refactor(version): remove VERSION.txt runtime file (version read from GitVersion at build time instead)

## [0.2.0] - 2026-04-25

### Added

- feat(ui): runtime language switching (EN/ID) with settings persistence
- feat(ui): sidebar folding with animated transition
- feat(ui): add Copilot instructions and enhance CI/CD workflows
- feat: enhance CI/CD workflows with Python version checks and Nuitka compatibility notes

### Changed

- refactor(release): overhaul versioning, update mechanism, and CI pipeline — unified CI/CD workflow with GitVersion semantic versioning, cross-platform build support, and automated GitHub Releases
- refactor(ui): extract reusable base button components (`BaseButton`, `ToolbarBtn`, `ShadowRect`) and replace ad-hoc button implementations
- refactor: combine CI and Release into single workflow
- refactor: restructure CI/CD with separate workflows and cross-platform support
- refactor: export LoggingMixin from core module
- refactor: simplify demo coefficients to single list (YAGNI/KISS)
- refactor: simplify global config manager (KISS)
- refactor: consolidate duplicate `level_map` into class constant (DRY)
- refactor: simplify logger singleton pattern (KISS)
- refactor: consolidate logging methods into LoggingMixin (DRY)
- refactor: remove unused config file loading (YAGNI/KISS)
- refactor: remove unused parent property from AppLogic (YAGNI)
- refactor: remove unused `validate_string_not_empty` method (YAGNI)

### Fixed

- fix(app): harden imports and update flow
- fix: remove parent property assignment in QML after AppLogic refactoring
- fix: update QML frontend for simplified demo coefficients
- fix: replace undefined `_log_warning` with `_log_error`
- fix: use cross-platform paths with correct case in `pysidedeploy.spec`
- fix: convert Windows paths to Unix in `pysidedeploy.spec` for cross-platform builds
- fix: upgrade Nuitka to 2.5.1 for Python 3.12 support
- fix: update deployment error message for Python version compatibility
- ci: fix release build artifact handling
- ci: add Linux Qt window and effects
- ci: add Linux QtQuick QML packages
- ci: add missing Linux QML module
- ci: fix Linux headless QML tests
- ci: harden workflow gates and releases

## [0.1.15] - 2024-09-14

### Fixed

- Bugfix: deployment bug fixes
- Bugfix: header display fixes
- Renamed SenseTrix into SenseTool (project rename)

## [0.1.14] - 2024-07-19

### Fixed

- Minor deployment bug fixes

## [0.1.13] - 2024-07-03

### Fixed

- File conflict resolutions in scan arrangement
- Adjust pip requirements for deployment

## [0.1.12] - 2024-07-03

### Fixed

- General bugfixes

## [0.1.11] - 2024-07-02

### Fixed

- Bugfix: logs folder not created automatically

## [0.1.10] - 2024-07-02

### Fixed

- Minor fixes and bugfixes

## [0.1.9] - 2024-06-28

### Fixed

- Fixed chart not generating
- General bugfixes

## [0.1.8] - 2024-06-28

### Added

- Update window UI
- Background download thread
- Auto-restart after update
- In-app update checking via GitHub Releases API

## [0.1.7] - 2024-06-28

### Fixed

- Translations not included in deployment
- Various translation-related fixes

## [0.1.6] - 2024-06-28

### Changed

- Migrated from 3rd-party release actions to default GitHub release action
- Workflow hardening and release process improvements

## [0.1.5] - 2024-06-27

### Fixed

- Wrong version reading in workflow
- Version number parsing fixes

## [0.1.4] - 2024-06-27

### Changed

- Release finalized without scan arrangement feature
- Workflow migration to combined workflow

## [0.1.3] - 2024-06-27

### Fixed

- Language/translation errors in deployment
- Temporary console disable for release builds

## [0.1.2] - 2024-06-27

### Fixed

- Deployment error: QML files not loaded
- Deployment error: wrong filename in Nuitka build
- Deployment error: namespace issue in CI
- Workflow fixes for dumpbin extraction error

## [0.1.1] - 2024-06-27

### Fixed

- Deployment error fixes
- Version number in executable filename

## [0.1.0] - 2024-06-27

### Added

- Initial release of Viewtrix application
- Multiple workspace support with drag-and-drop item reordering
- YAML import/export for project settings and coefficients
- Window coefficient generation and export
- Demo coefficient generation (sine/cosine)
- Scan arrangement list with customizable items
- Hardware utility tools
- Multi-language support (English, Indonesian)
- Theme toggle (light/dark mode)
- In-app update notification system
- Notification history panel
- PySide6/QML-based GUI with Material Design

[Unreleased]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.15+6...v0.2.0
[0.1.15]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.14+4...0.1.15+6
[0.1.14]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.13+20...0.1.14+4
[0.1.13]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.12+2...0.1.13+20
[0.1.12]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.11+2...0.1.12+2
[0.1.11]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.10+2...0.1.11+2
[0.1.10]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.9+2...0.1.10+2
[0.1.9]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.8+2...0.1.9+2
[0.1.8]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.7+2...0.1.8+2
[0.1.7]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.6+15...0.1.7+2
[0.1.6]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.5+2...0.1.6+15
[0.1.5]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.4+12...0.1.5+2
[0.1.4]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.3+2...0.1.4+12
[0.1.3]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.2+3...0.1.3+2
[0.1.2]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.1+6...0.1.2+3
[0.1.1]: https://github.com/davidyusaku-13/sensetool-viewtrix/compare/0.1.0+201...0.1.1+6
[0.1.0]: https://github.com/davidyusaku-13/sensetool-viewtrix/releases/tag/0.1.0%2B201
