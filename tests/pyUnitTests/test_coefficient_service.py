import unittest

from src.services.coefficient_service import CoefficientService, WindowLength


class CoefficientServiceTestCase(unittest.TestCase):
    def setUp(self):
        self._service = CoefficientService()

    def test_window_coefficients_require_at_least_two_samples(self):
        with self.assertRaises(ValueError):
            self._service.generate_window_coefficients(1, 0.54, WindowLength.FULL)


if __name__ == '__main__':
    unittest.main()
