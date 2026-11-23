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
