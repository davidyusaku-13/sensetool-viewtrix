import unittest

from src.services.update_service import UpdateService


class UpdateServiceTestCase(unittest.TestCase):
    def setUp(self):
        self._service = UpdateService()

    def test_select_download_asset_matches_platform(self):
        assets = [
            {"name": "sensetool-macos-arm64.dmg", "browser_download_url": "mac"},
            {"name": "sensetool-windows-amd64.exe", "browser_download_url": "win"},
            {"name": "sensetool-linux-x86_64.AppImage", "browser_download_url": "linux"},
        ]

        asset = self._service._select_download_asset(
            assets,
            system_name="Windows",
            machine_name="AMD64",
        )

        self.assertIsNotNone(asset)
        self.assertEqual(asset["browser_download_url"], "win")

    def test_is_newer_version_handles_prerelease(self):
        self.assertTrue(self._service._is_newer_version("v1.2.3", "v1.2.3-beta.1"))
        self.assertFalse(self._service._is_newer_version("v1.2.3-beta.1", "v1.2.3"))
        self.assertTrue(self._service._is_newer_version("v1.2.4-beta.1", "v1.2.3"))


if __name__ == '__main__':
    unittest.main()
