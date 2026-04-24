"""Coefficient calculation service for SenseTool application.

This module provides services for generating and processing
various types of coefficients used in sensor applications.
"""

import math
from typing import List, Dict, Any, Tuple
from dataclasses import dataclass
from enum import Enum
from ..core.base import BaseService, ValidationMixin


class WindowLength(Enum):
    """Enumeration for window length options."""
    FULL = "Full"
    HALF = "Half"


@dataclass
class WindowCoefficients:
    """Data class for window coefficients."""
    sample_number: int
    a0: float
    length: WindowLength
    coefficients: List[int]
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization.
        
        Returns:
            Dictionary representation
        """
        return {
            'sample_number': self.sample_number,
            'a0': self.a0,
            'coef_length': self.length.value,
            'data': [{'y': coef} for coef in self.coefficients]
        }


@dataclass
class DemoCoefficients:
    """Data class for demo coefficients."""
    num_step: int
    sample_number: int
    cycle: int
    adc_sampling_freq: int
    coefficients: List[int]
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization.
        
        Returns:
            Dictionary representation
        """
        return {
            'demo_step': self.num_step,
            'demo_sample': self.sample_number,
            'demo_cycle': self.cycle,
            'demo_adc': self.adc_sampling_freq,
            'data': [{'y': coef} for coef in self.coefficients]
        }


class CoefficientService(BaseService, ValidationMixin):
    """Service for coefficient calculations.
    
    Handles generation of window coefficients and demo coefficients
    with proper validation and error handling.
    """
    
    def __init__(self):
        """Initialize coefficient service."""
        super().__init__()
        self._initialized = False
    
    def initialize(self) -> bool:
        """Initialize the coefficient service.
        
        Returns:
            True if initialization was successful
        """
        try:
            self._log_info("Initializing coefficient service")
            self._initialized = True
            return True
        except Exception as e:
            self._log_error(f"Failed to initialize coefficient service: {e}")
            return False
    
    def generate_window_coefficients(
        self,
        sample_number: int,
        a0: float,
        length: WindowLength
    ) -> WindowCoefficients:
        """Generate window coefficients using Hamming window function.
        
        Args:
            sample_number: Number of samples
            a0: Alpha parameter for window function
            length: Window length (Full or Half)
            
        Returns:
            WindowCoefficients object
            
        Raises:
            ValueError: If input parameters are invalid
        """
        # Validate inputs
        sample_number = self.validate_integer_range(
            sample_number, 2, 10000, "sample_number"
        )
        a0 = self.validate_positive_number(a0, "a0")
        
        if a0 >= 1.0:
            raise ValueError("a0 must be less than 1.0")
        
        try:
            self._log_debug(
                f"Generating window coefficients: samples={sample_number}, "
                f"a0={a0}, length={length.value}"
            )
            
            # Calculate coefficients
            win_step = 1
            win_n = sample_number // win_step
            a1 = 1 - a0
            
            coefficients = []
            for i in range(1, win_n + 1):
                val = a0 - a1 * math.cos(
                    2 * math.pi * (i - 1) / (sample_number / win_step - 1)
                )
                coefficients.append(round(val * 256))
            
            # Apply length filter
            if length == WindowLength.HALF:
                coefficients = coefficients[:len(coefficients) // 2]
            
            result = WindowCoefficients(
                sample_number=sample_number,
                a0=a0,
                length=length,
                coefficients=coefficients
            )
            
            self._log_info(
                f"Generated {len(coefficients)} window coefficients"
            )
            
            return result
            
        except Exception as e:
            self._log_error(f"Failed to generate window coefficients: {e}")
            raise
    
    def generate_demo_coefficients(
        self,
        num_step: int,
        sample_number: int,
        cycle: int,
        adc_sampling_freq: int
    ) -> DemoCoefficients:
        """Generate demo coefficients for demonstration purposes.
        
        Args:
            num_step: Number of steps
            sample_number: Number of samples
            cycle: Cycle count
            adc_sampling_freq: ADC sampling frequency
            
        Returns:
            DemoCoefficients object
            
        Raises:
            ValueError: If input parameters are invalid
        """
        # Validate inputs
        num_step = self.validate_integer_range(num_step, 1, 1000, "num_step")
        sample_number = self.validate_integer_range(
            sample_number, 1, 10000, "sample_number"
        )
        cycle = self.validate_integer_range(cycle, 1, 100, "cycle")
        adc_sampling_freq = self.validate_integer_range(
            adc_sampling_freq, 1, 1000000, "adc_sampling_freq"
        )
        
        try:
            self._log_debug(
                f"Generating demo coefficients: steps={num_step}, "
                f"samples={sample_number}, cycle={cycle}, freq={adc_sampling_freq}"
            )
            
            # Calculate demo coefficients
            coefficients = []
            for i in range(num_step):
                val = math.sin(
                    2 * math.pi * cycle * i / sample_number
                ) * (adc_sampling_freq / 2)
                coefficients.append(round(val))
            
            result = DemoCoefficients(
                num_step=num_step,
                sample_number=sample_number,
                cycle=cycle,
                adc_sampling_freq=adc_sampling_freq,
                coefficients=coefficients
            )
            
            self._log_info(
                f"Generated {len(coefficients)} demo coefficients"
            )
            
            return result
            
        except Exception as e:
            self._log_error(f"Failed to generate demo coefficients: {e}")
            raise
    
    def divide_array(self, array: List[Any]) -> Tuple[List[Any], List[Any]]:
        """Divide array into even and odd indexed elements.
        
        Args:
            array: Input array to divide
            
        Returns:
            Tuple of (even_elements, odd_elements)
        """
        if not isinstance(array, list):
            raise ValueError("Input must be a list")
        
        even_array = [array[i] for i in range(len(array)) if i % 2 == 0]
        odd_array = [array[i] for i in range(len(array)) if i % 2 != 0]
        
        self._log_debug(
            f"Divided array of {len(array)} elements into "
            f"{len(even_array)} even and {len(odd_array)} odd elements"
        )
        
        return even_array, odd_array
