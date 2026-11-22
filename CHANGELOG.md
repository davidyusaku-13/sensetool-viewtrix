What's new in this update:

- Project Setting: generate `prjset.h` directly from the app
- Project Setting: import the legacy `prjcfg.xlsx` spreadsheet (PrjSet sheet)
- Project Setting: items are grouped into sections, with a review comment per item
- Project Setting: expression values are evaluated (e.g. `FRM_SZ = 840`), and duplicate names, undefined references and circular references are flagged
- Scan Arrangement: Import/Export to YAML; scan lists per arrangement can be added to and removed from

Bugfixes:

- Reordering Project Setting items by dragging could delete rows
- Saving an edit could modify the wrong row if the selection changed meanwhile
- Importing a file appended to the list instead of replacing it
- Values were exported with inconsistent types depending on how they were entered
- Value field rejected valid C operators (`& | ! ~ ^ % =`); names may no longer start with a digit
- Update check no longer blocks or crashes startup when offline, and compares versions numerically
- Coefficient import/export errors are shown instead of crashing; window coefficient export failed
- History entries all showed the app start time
