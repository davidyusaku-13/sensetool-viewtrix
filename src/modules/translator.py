from PySide6.QtCore import QTranslator, QObject, Slot

class Translator(QObject):
    def __init__(self, app, engine):
        super().__init__()
        self.app = app
        self.engine = engine
        self.translator = QTranslator()

    @Slot(str)
    def change_language(self, language):
        if self.translator.load(f"translations/sensetool_{language}.qm"):
            self.app.installTranslator(self.translator)
        else:
            self.app.removeTranslator(self.translator)
        self.engine.retranslate()