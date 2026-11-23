import os
import tempfile
import unittest
import requests
from src.modules import updatecheck
from src.modules.updatecheck import UpdateChecker, fetch_update_info, is_newer, parse_version


class FakeResponse:
    def __init__(self, data, fail=False):
        self._data, self._fail = data, fail

    def raise_for_status(self):
        if self._fail:
            raise requests.HTTPError("503")

    def json(self):
        return self._data


class UpdateCheckTestCase(unittest.TestCase):
    def test_version_compare(self):
        self.assertEqual(parse_version("v1.10.2-beta.1+3"), (1, 10, 2))
        self.assertTrue(is_newer("1.10.0", "1.9.0"))
        self.assertFalse(is_newer("1.9.0", "1.10.0"))
        self.assertFalse(is_newer("1.2", "1.2.0"))
        self.assertFalse(is_newer("1.0.0", ""), "unknown current version must not prompt")

    def test_fetch_reports_a_newer_release(self):
        release = {"tag_name": "v2.0.0", "body": "notes",
                   "assets": [{"browser_download_url": "https://x/sensetool.exe"}]}
        info = fetch_update_info("1.0.0", get=lambda url, timeout: FakeResponse(release))
        self.assertEqual(info, {"status": True, "version": "v2.0.0", "changelog": "notes",
                                "link": "https://x/sensetool.exe"})
        same = fetch_update_info("2.0.0", get=lambda url, timeout: FakeResponse(release))
        self.assertFalse(same["status"])

    def test_fetch_survives_network_errors(self):
        def boom(url, timeout):
            raise requests.ConnectionError("offline")
        self.assertFalse(fetch_update_info("1.0.0", get=boom)["status"])
        self.assertFalse(fetch_update_info("1.0.0", get=lambda u, timeout: FakeResponse({}, fail=True))["status"])

    def test_version_file(self):
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "VERSION.txt")
            with open(path, "w") as f:
                f.write("1.4.2\n")
            self.assertEqual(updatecheck.read_version(path), "1.4.2")
            self.assertEqual(updatecheck.read_version(os.path.join(d, "missing.txt")), "")

    def test_checker_keeps_the_download_link(self):
        release = {"tag_name": "v9.0.0", "assets": [{"browser_download_url": "https://x/a.exe"}]}
        checker = UpdateChecker(version="1.0.0", get=lambda url, timeout: FakeResponse(release))
        self.assertTrue(checker.checkNow()["status"])
        self.assertEqual(checker.updateLink(), "https://x/a.exe")
        self.assertEqual(checker.version(), "1.0.0")


if __name__ == "__main__":
    unittest.main()
