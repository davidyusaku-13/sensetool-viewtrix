import unittest
from pathlib import Path

from src.modules.updater import UpdateManager


class UpdateManagerTestCase(unittest.TestCase):
    def setUp(self):
        self._manager = UpdateManager()

    def test_can_install_update_disabled_in_dev_environment(self):
        self.assertFalse(self._manager.canInstallUpdate())

    def test_windows_installer_script_uses_backup_and_rollback(self):
        script = self._manager._build_windows_installer_script(
            Path("C:/app/sensetool.exe"),
            Path("C:/app/sensetool.exe.download"),
            Path("C:/app/sensetool.exe.bak"),
        )

        self.assertIn('move /Y "%TARGET%" "%BACKUP%"', script)
        self.assertIn('move /Y "%DOWNLOAD%" "%TARGET%"', script)
        self.assertIn(":rollback", script)
        self.assertIn('move /Y "%BACKUP%" "%TARGET%"', script)


if __name__ == '__main__':
    unittest.main()
