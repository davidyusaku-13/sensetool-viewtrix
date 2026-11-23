"""Start the real app, close it like the close button does, and check it shuts
down cleanly. Regression: on exit the QML outlived the models it binds to and
printed dozens of "Cannot read property ... of null" errors, and a still-running
update-check thread aborted the process."""
import os
import subprocess
import sys
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SCRIPT = (
    "import sys, main\n"
    # a throwaway settings name, so the user's last project and window size are untouched
    "sys.exit(main.main(['main.py'], organization='SenseToolShutdownTest', close_after_ms=2000))\n"
)


class ShutdownTestCase(unittest.TestCase):
    def test_app_closes_cleanly(self):
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen")
        run = subprocess.run([sys.executable, "-c", SCRIPT], cwd=ROOT, env=env,
                             capture_output=True, text=True, timeout=60)
        output = run.stdout + run.stderr
        self.assertEqual(run.returncode, 0, output)
        problems = [ln for ln in output.splitlines() if "Error" in ln or "QThread" in ln or "Warning" in ln]
        self.assertEqual(problems, [], output)


if __name__ == "__main__":
    unittest.main()
