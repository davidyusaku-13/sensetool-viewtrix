"""Run the QML tests (tests/qmlUnitTests/tst_*.qml) with the app's Python types
registered. qmltestrunner can't load PySide-registered types, so use this.

Components take their dependencies as properties, so QML tests pass small
fakes and test the UI on its own; the Python models are covered by the Python
tests (the registered types can still be created in QML tests if needed).

    uv run python tests/run_qml_tests.py [tests/qmlUnitTests/tst_X.qml]
"""
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import resource_rc  # noqa: E402,F401  (qrc:/images used by components)
# Importing the models/services registers their QML types.
from src.models import appsetmodel, historymodel, prjsetmodel, project, scanarrmodel  # noqa: E402,F401
from src.modules import coefficients, updatecheck  # noqa: E402,F401
from PySide6.QtQuickControls2 import QQuickStyle  # noqa: E402
from PySide6.QtWidgets import QApplication  # noqa: E402
from PySide6.QtQuickTest import QUICK_TEST_MAIN  # noqa: E402

if __name__ == "__main__":
    # Qt Charts (Hardware Utilities) needs a QApplication; the test main reuses this one.
    app = QApplication(sys.argv[:1])
    QQuickStyle.setStyle("Material")
    os.chdir(ROOT)
    args = sys.argv[1:]
    # a single test file may be given first: tests/run_qml_tests.py tests/qmlUnitTests/tst_X.qml
    target = os.path.abspath(args.pop(0)) if args and args[0].endswith(".qml") else \
        os.path.join(ROOT, "tests", "qmlUnitTests")
    sys.exit(QUICK_TEST_MAIN("sensetool", ["sensetool", "-input", target] + args))
