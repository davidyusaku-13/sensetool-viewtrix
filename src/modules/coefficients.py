"""Window and demodulator coefficient generators (Hardware Utilities).

The pure functions hold the maths and the input rules; CoefficientGenerator is
the thin QML-facing object. It takes the input fields' text, so the rules live
in one place instead of being repeated in QML.
"""
import math
from PySide6.QtCore import QObject, Slot
from PySide6.QtQml import QmlElement
from .fileio import UserError, local_path, read_yaml, write_yaml, message
from .logger import AppLogger

QML_IMPORT_NAME = "Coefficients"
QML_IMPORT_MAJOR_VERSION = 1

logger = AppLogger.get_instance()

SCALE = 256           # coefficients are fixed point, 1.0 == 256
DEMOD_AMPLITUDE = 0.5
LENGTHS = ("Half", "Full")


# ---- maths -------------------------------------------------------------------
def window(sample_number, a0, length):
    """Generalized Hamming window w[n] = a0 - (1 - a0) cos(2 pi n / (N - 1)), scaled
    to SCALE. a0 = 0.5 is Hann, 0.54 Hamming. "Half" keeps the first N // 2 values."""
    n = int(sample_number)
    if n < 2:
        return []  # the formula divides by N - 1
    a1 = 1 - a0
    values = [round((a0 - a1 * math.cos(2 * math.pi * k / (n - 1))) * SCALE) for k in range(n)]
    return values[:n // 2] if length == "Half" else values


def demodulator(step, sample, cycle):
    """I (sine) and Q (cosine) coefficients over `sample` samples, `cycle` periods per
    4 * `step` samples, amplitude DEMOD_AMPLITUDE * SCALE."""
    n = step * 4
    if n == 0:
        return [], []
    phase = [2 * math.pi * cycle * k / n for k in range(sample)]
    i_coef = [round(math.sin(p) * DEMOD_AMPLITUDE * SCALE) for p in phase]
    q_coef = [round(math.cos(p) * DEMOD_AMPLITUDE * SCALE) for p in phase]
    return i_coef, q_coef


# ---- input rules -------------------------------------------------------------
def _whole(text, minimum):
    try:
        v = float(text)
    except (TypeError, ValueError):
        return None
    return int(v) if v.is_integer() and v >= minimum and "." not in str(text) else None


def check_window(sample_text, a0_text):
    """"" when the fields can be used, else what to fix."""
    if _whole(sample_text, 2) is None:
        return "Sample Number must be a whole number of at least 2."
    try:
        a0 = float(a0_text)
    except (TypeError, ValueError):
        a0 = None
    if a0 is None or not 0 <= a0 <= 1:
        return "a0 must be between 0 and 1 (0.5 = Hann, 0.54 = Hamming)."
    return ""


def check_demodulator(step_text, sample_text, cycle_text, adc_text):
    for label, text in (("Step", step_text), ("Sample", sample_text), ("Cycle", cycle_text), ("ADC Freq", adc_text)):
        if _whole(text, 1) is None:
            return f"{label} must be a whole number of at least 1."
    return ""


# ---- files -------------------------------------------------------------------
def window_doc(values, sample_number, a0, length):
    return {"sample_number": sample_number, "a0": a0, "coef_length": length,
            "data": [{"y": v} for v in values]}


def parse_window_doc(data, path):
    try:
        return ([item["y"] for item in data["data"]], data["sample_number"], data["a0"], data["coef_length"])
    except (KeyError, TypeError) as e:
        raise UserError(f"{path}: expected keys sample_number, a0, coef_length and a 'data' list of 'y' values") from e


def demodulator_doc(i_coef, q_coef, step, sample, cycle, adc):
    return {"step": step, "sample": sample, "cycle": cycle, "adc_freq": adc,
            "i_coef": [{"y_sin": v} for v in i_coef], "q_coef": [{"y_cos": v} for v in q_coef]}


def parse_demodulator_doc(data, path):
    try:
        return ([item["y_sin"] for item in data["i_coef"]], [item["y_cos"] for item in data["q_coef"]],
                data["step"], data["sample"], data["cycle"], data["adc_freq"])
    except (KeyError, TypeError) as e:
        raise UserError(f"{path}: expected keys step, sample, cycle, adc_freq, i_coef and q_coef") from e


def _num(text):
    v = float(text)
    return int(v) if v.is_integer() and "." not in str(text) else v


@QmlElement
class CoefficientGenerator(QObject):
    """What the Hardware Utilities page calls. Arguments are the fields' text."""

    @Slot(str, str, result=str)
    def checkWindow(self, sample_text, a0_text):
        return check_window(sample_text, a0_text)

    @Slot(str, str, str, result=list)
    def windowCoefficients(self, sample_text, a0_text, length):
        if check_window(sample_text, a0_text):
            return []
        return window(int(sample_text), float(a0_text), length)

    @Slot(str, str, str, str, result=str)
    def checkDemodulator(self, step_text, sample_text, cycle_text, adc_text):
        return check_demodulator(step_text, sample_text, cycle_text, adc_text)

    @Slot(str, str, str, result=dict)
    def demodulatorCoefficients(self, step_text, sample_text, cycle_text):
        if check_demodulator(step_text, sample_text, cycle_text, "1"):
            return {"i": [], "q": []}
        i_coef, q_coef = demodulator(int(step_text), int(sample_text), int(cycle_text))
        return {"i": i_coef, "q": q_coef}

    @Slot("QUrl", str, str, str, result=str)
    def exportWindow(self, url, sample_text, a0_text, length):
        def run():
            err = check_window(sample_text, a0_text)
            if err:
                raise UserError(err)
            values = self.windowCoefficients(sample_text, a0_text, length)
            write_yaml(local_path(url), window_doc(values, int(sample_text), _num(a0_text), length))
            logger.log(f"Exported window coefficients {local_path(url)}", "INFO")
        return message(run)

    @Slot("QUrl", result=dict)
    def importWindow(self, url):
        path = local_path(url)
        try:
            values, n, a0, length = parse_window_doc(read_yaml(path), path)
        except UserError as e:
            logger.log(str(e), "ERROR")
            return {"error": str(e)}
        return {"error": "", "values": values, "sampleNumber": str(n), "a0": str(a0), "length": str(length)}

    @Slot("QUrl", str, str, str, str, result=str)
    def exportDemodulator(self, url, step_text, sample_text, cycle_text, adc_text):
        def run():
            err = check_demodulator(step_text, sample_text, cycle_text, adc_text)
            if err:
                raise UserError(err)
            i_coef, q_coef = demodulator(int(step_text), int(sample_text), int(cycle_text))
            write_yaml(local_path(url), demodulator_doc(i_coef, q_coef, int(step_text), int(sample_text),
                                                        int(cycle_text), int(adc_text)))
            logger.log(f"Exported demodulator coefficients {local_path(url)}", "INFO")
        return message(run)

    @Slot("QUrl", result=dict)
    def importDemodulator(self, url):
        path = local_path(url)
        try:
            i_coef, q_coef, step, sample, cycle, adc = parse_demodulator_doc(read_yaml(path), path)
        except UserError as e:
            logger.log(str(e), "ERROR")
            return {"error": str(e)}
        return {"error": "", "i": i_coef, "q": q_coef, "step": str(step), "sample": str(sample),
                "cycle": str(cycle), "adcFreq": str(adc)}
