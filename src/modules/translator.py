from PySide6.QtCore import QTranslator, QObject, Slot
import os

class Translator(QObject):
    def __init__(self, app, engine):
        super().__init__()
        self.app = app
        self.engine = engine
        self.translator = QTranslator()

    @Slot(str)
    def change_language(self, language):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        langpath = os.path.join(script_dir, f'../../translations/sensetool_{language}.qm')
        if self.translator.load(langpath):
            self.app.installTranslator(self.translator)
        else:
            self.app.removeTranslator(self.translator)
        self.engine.retranslate()