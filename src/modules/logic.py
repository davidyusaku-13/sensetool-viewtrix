from PySide6.QtCore import Signal, Slot, QUrl, QObject, Property
from PySide6.QtQml import QmlElement
from typing import Any, List, Dict
from ..core.base import BaseQmlObject
from ..services.coefficient_service import CoefficientService, WindowLength
from ..services.file_service import FileService
from ..services.update_service import UpdateService

QML_IMPORT_NAME = "AppLogic"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class AppLogic(BaseQmlObject):
    """Main application logic controller.
    
    Provides QML interface for core application functionality
    including coefficient generation, file operations, and updates.
    """
    
    # Signals
    parentChanged = Signal(QObject)
    
    def __init__(self, parent: QObject = None):
        """Initialize application logic.
        
        Args:
            parent: Parent QObject
        """
        super().__init__(parent)
        
        # Initialize services
        self._coefficient_service = CoefficientService()
        self._file_service = FileService()
        self._update_service = UpdateService()
        
        # Initialize services
        self._coefficient_service.initialize()
        self._file_service.initialize()
        self._update_service.initialize()
        
    @Property(QObject)
    def parent(self) -> QObject:
        return super().parent()
    
    @parent.setter
    def parent(self, parent: QObject):
        super().setParent(parent)
        self.parentChanged.emit(parent)

    @Slot(result=dict)
    def checkUpdate(self) -> Dict[str, Any]:
        """Check for application updates.
        
        Returns:
            Dictionary containing update information
        """
        try:
            update_info = self._update_service.check_for_updates()
            return update_info.to_dict()
        except Exception as e:
            self._log_error(f"Failed to check for updates: {e}")
            return {
                "status": False,
                "current_version": self.getVersion(),
                "version": self.getVersion(),
                "changelog": f"Error checking for updates: {e}",
                "link": ""
            }
        
    @Slot(result=str)
    def getVersion(self) -> str:
        """Get application version.
        
        Returns:
            Application version string
        """
        return self._config.get_version()

    @Slot(list, result=list)
    def divideArray(self, array: List[Any]) -> List[List[Any]]:
        """Divide array into even and odd indexed elements.
        
        Args:
            array: Input array to divide
            
        Returns:
            List containing [even_elements, odd_elements]
        """
        try:
            even_array, odd_array = self._coefficient_service.divide_array(array)
            return [even_array, odd_array]
        except Exception as e:
            self._log_error(f"Failed to divide array: {e}")
            return [[], []]

    @Slot(int, float, str, result=list)
    def win_coef_gen(self, win_sample_number: int, win_a0: float, win_length: str) -> List[int]:
        """Generate window coefficients.
        
        Args:
            win_sample_number: Number of samples
            win_a0: Alpha parameter
            win_length: Window length ('Full' or 'Half')
            
        Returns:
            List of window coefficients
        """
        try:
            length = WindowLength.FULL if win_length == "Full" else WindowLength.HALF
            coefficients = self._coefficient_service.generate_window_coefficients(
                win_sample_number, win_a0, length
            )
            return coefficients.coefficients
        except Exception as e:
            self._log_error(f"Failed to generate window coefficients: {e}")
            return []

    @Slot(QUrl, list, int, float, str)
    def exportWinCoef(self, fname: QUrl, y: List[int], win_sample_number: int, 
                     win_a0: float, win_coef_length: str) -> None:
        """Export window coefficients to file.
        
        Args:
            fname: File URL to export to
            y: Coefficient values
            win_sample_number: Number of samples
            win_a0: Alpha parameter
            win_coef_length: Window length
        """
        try:
            from ..services.coefficient_service import WindowCoefficients, WindowLength
            
            length = WindowLength.FULL if win_coef_length == "Full" else WindowLength.HALF
            coefficients = WindowCoefficients(
                sample_number=win_sample_number,
                a0=win_a0,
                length=length,
                coefficients=y
            )
            
            success = self._file_service.export_window_coefficients(fname, coefficients)
            if success:
                self._log_info(f"Exported window coefficients to {fname.toLocalFile()}")
            else:
                self._log_error("Failed to export window coefficients")
                
        except Exception as e:
            self._log_error(f"Failed to export window coefficients: {e}")

    @Slot(QUrl, result='QVariant')
    def importWinCoef(self, fname: QUrl) -> Dict[str, Any]:
        """Import window coefficients from file.
        
        Args:
            fname: File URL to import from
            
        Returns:
            Dictionary containing coefficients, sample_number, a0, and coef_length
        """
        try:
            coefficients = self._file_service.import_window_coefficients(fname)
            if coefficients:
                self._log_info(f"Imported window coefficients from {fname.toLocalFile()}")
                length_str = "Full" if coefficients.length == WindowLength.FULL else "Half"
                return {
                    "coefficients": coefficients.coefficients,
                    "sample_number": coefficients.sample_number,
                    "a0": coefficients.a0,
                    "coef_length": length_str
                }
            else:
                self._log_error("Failed to import window coefficients")
                return {"coefficients": [], "sample_number": 0, "a0": 0.0, "coef_length": "Full"}
        except Exception as e:
            self._log_error(f"Failed to import window coefficients: {e}")
            return {"coefficients": [], "sample_number": 0, "a0": 0.0, "coef_length": "Full"}
    
    @Slot(int, int, int, int, result=list)
    def demo_coef_gen(self, demo_num_step: int, demo_sample_number: int, 
                     demo_cycle: int, demo_adc_sampling_freq: int) -> List[List[int]]:
        """Generate demo coefficients.
        
        Args:
            demo_num_step: Number of steps
            demo_sample_number: Number of samples
            demo_cycle: Cycle count
            demo_adc_sampling_freq: ADC sampling frequency
            
        Returns:
            List containing [I_coefficients, Q_coefficients]
        """
        try:
            coefficients = self._coefficient_service.generate_demo_coefficients(
                demo_num_step, demo_sample_number, demo_cycle, demo_adc_sampling_freq
            )
            return [coefficients.i_coefficients, coefficients.q_coefficients]
        except Exception as e:
            self._log_error(f"Failed to generate demo coefficients: {e}")
            return [[], []]

    @Slot(QUrl, list, int, int, int, int)
    def exportDemoCoef(self, fname: QUrl, y: List[List[int]], demo_step: int, 
                      demo_sample: int, demo_cycle: int, demo_adc: int) -> None:
        """Export demo coefficients to file.
        
        Args:
            fname: File URL to export to
            y: List containing [I_coefficients, Q_coefficients]
            demo_step: Number of steps
            demo_sample: Number of samples
            demo_cycle: Cycle count
            demo_adc: ADC frequency
        """
        try:
            from ..services.coefficient_service import DemoCoefficients
            
            y_sin, y_cos = y
            coefficients = DemoCoefficients(
                num_step=demo_step,
                sample_number=demo_sample,
                cycle=demo_cycle,
                adc_sampling_freq=demo_adc,
                coefficients=y_sin  # Note: DemoCoefficients only stores one coefficient list
            )
            
            success = self._file_service.export_demo_coefficients(fname, coefficients)
            if success:
                self._log_info(f"Exported demo coefficients to {fname.toLocalFile()}")
            else:
                self._log_error("Failed to export demo coefficients")
                
        except Exception as e:
            self._log_error(f"Failed to export demo coefficients: {e}")

    @Slot(QUrl, result='QVariant')
    def importDemoCoef(self, fname: QUrl) -> Dict[str, Any]:
        """Import demo coefficients from file.
        
        Args:
            fname: File URL to import from
            
        Returns:
            Dictionary containing i_coefficients, q_coefficients, step, sample, cycle, and adc_freq
        """
        try:
            coefficients = self._file_service.import_demo_coefficients(fname)
            if coefficients:
                self._log_info(f"Imported demo coefficients from {fname.toLocalFile()}")
                return {
                    "i_coefficients": coefficients.coefficients,
                    "q_coefficients": [],  # DemoCoefficients only stores one coefficient list
                    "step": coefficients.num_step,
                    "sample": coefficients.sample_number,
                    "cycle": coefficients.cycle,
                    "adc_freq": coefficients.adc_sampling_freq
                }
            else:
                self._log_error("Failed to import demo coefficients")
                return {"i_coefficients": [], "q_coefficients": [], "step": 0, "sample": 0, "cycle": 0, "adc_freq": 0}
        except Exception as e:
            self._log_error(f"Failed to import demo coefficients: {e}")
            return {"i_coefficients": [], "q_coefficients": [], "step": 0, "sample": 0, "cycle": 0, "adc_freq": 0}
