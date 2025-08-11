from PySide6.QtCore import QTranslator, QObject, Slot
from pathlib import Path
from typing import Optional
from ..core.base import BaseQmlObject

class Translator(BaseQmlObject):
    """Translation service for the application.
    
    Handles language switching and translation file loading.
    """
    
    def __init__(self, app, engine, parent: Optional[QObject] = None):
        """Initialize translator.
        
        Args:
            app: QApplication instance
            engine: QQmlApplicationEngine instance
            parent: Parent QObject
        """
        super().__init__(parent)
        self.app = app
        self.engine = engine
        self.translator = QTranslator()
        self._current_language = "en"  # Default language

    @Slot(str)
    def change_language(self, language: str) -> None:
        """Change application language.
        
        Args:
            language: Language code (e.g., 'en', 'es', 'fr')
        """
        try:
            script_dir = Path(__file__).parent
            langpath = script_dir / f'../../translations/sensetool_{language}.qm'
            
            if langpath.exists() and self.translator.load(str(langpath)):
                self.app.installTranslator(self.translator)
                self._current_language = language
                self._log_info(f"Language changed to: {language}")
            else:
                self.app.removeTranslator(self.translator)
                self._log_error(f"Translation file could not be loaded for language: {language}")
                
            self.engine.retranslate()
        except Exception as e:
            self._log_error(f"Failed to change language to {language}: {e}")
    
    @Slot(result=str)
    def getCurrentLanguage(self) -> str:
        """Get current language code.
        
        Returns:
            Current language code
        """
        return self._current_language