What's new in this update:

- Project Setting: generate `prjset.h` directly from the app
- Project Setting: import the legacy `prjcfg.xlsx` spreadsheet (PrjSet sheet)
- Project Setting: items are grouped into sections, with a review comment per item
- Project Setting: expression values are evaluated (e.g. `FRM_SZ = 840`), and duplicate names, undefined references and circular references are flagged
- New App Setting workspace replaces the AppSet sheet: a 1 KB register map with bit fields and defaults; generate `appset.c` / `appset.h`, import the AppSet sheet of `prjcfg.xlsx`, Import/Export to YAML
- App Setting: overlapping registers or bit fields, defaults that don't fit, bad sizes and duplicate names are flagged
- Scan Arrangement replaces the ScanArrg sheet: generate `afeScanArrg.c` / `afeScanArrg.h`, import the ScanArrg sheet of `prjcfg.xlsx`, Import/Export to YAML
- Scan Arrangement: scan items are the `eAfeScanID_t` enum with their values shown and can be reordered; arrangements have an editable ID; step sequences can be inserted into, reordered and repeated
- Scan Arrangement: Check finds unknown steps, missing `AFE_END`, more than 10 steps, duplicate names/IDs; renaming a scan item updates every arrangement
- `yaml/prjcfg.yaml` replaces `prjcfg.xlsx`: one file with all three sheets (plus the ReadMe revision history) that every workspace can import; convert an updated spreadsheet with `uv run python -m src.modules.prjcfg prjcfg.xlsx yaml/prjcfg.yaml`
- Project files: Open / Save / Save As in the header work on one `prjcfg.yaml` for all workspaces (Ctrl+O, Ctrl+S); the last project reopens on startup, the title shows unsaved changes, and closing asks to save
- Undo / Redo across all workspaces (Ctrl+Z, Ctrl+Shift+Z); deleting now asks first, and saving an edit no longer does
- Project Setting: search (Ctrl+F) and a "Problems only" filter; compact rows, review comments on hover; a broken item is shown in red and items that only depend on it in orange
- Scan Arrangement: rebuilt layout - toolbars wrap instead of squashing, names no longer break mid-word, headers line up with columns, the Scan List always shows the picked arrangement
- App Setting: the register window shows problems while you type and the address in both hex and decimal
- Keyboard: Ctrl+N add, Enter/F2 or double-click edit, Del delete, Ctrl+A select all, Ctrl+G generate; header checkbox selects all rows
- One look across pages: shared toolbar style with Generate as the main action, Viewtrix orange accent with readable text in light and dark themes, sidebar labels (menu button) and distinct icons, empty-state hints, labelled Hardware Utilities inputs, clearer Settings (Dark mode switch, language list)
- Edit windows check names as you save (e.g. a duplicate scan item) and keep the window open with the reason; Esc cancels, Ctrl+Enter saves

Bugfixes:

- Reordering Project Setting items by dragging could delete rows
- Saving an edit could modify the wrong row if the selection changed meanwhile
- Importing a file appended to the list instead of replacing it
- Values were exported with inconsistent types depending on how they were entered
- Value field rejected valid C operators (`& | ! ~ ^ % =`); names may no longer start with a digit
- Update check no longer blocks or crashes startup when offline, and compares versions numerically
- Coefficient import/export errors are shown instead of crashing; window coefficient export failed
- History entries all showed the app start time
- Scan item drag icon did not load

Under the hood:

- Scan Arrangement data and rules moved from QML into a Python model, and project open/save, unsaved changes and undo into a Python controller, so they are unit-tested
- AppLogic split into focused pieces (coefficients, update check, project); shared C-generation, file and table code written once
- Pages get their data passed in instead of reaching for globals; one table, edit window and shortcut component shared by every page
- CI lints (ruff, qmllint) and runs the Python and QML tests on every push and pull request

