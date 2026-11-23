"""Composition root: the models and services the QML app works with.

They are created here in Python (not inside QML) and handed to main.qml as
initial properties, so they outlive the QML engine: on exit the engine is
destroyed first, and no binding ever sees a model that is already gone.
"""
from .models.appsetmodel import AppSetModel
from .models.historymodel import HistoryModel
from .models.prjsetmodel import PrjSetModel
from .models.project import ProjectController
from .models.scanarrmodel import ScanArrModel
from .modules.coefficients import CoefficientGenerator
from .modules.updatecheck import UpdateChecker


def create_services():
    """{name: object} for main.qml's required properties of the same names."""
    services = {
        "prjSet": PrjSetModel(),
        "appSet": AppSetModel(),
        "scanArr": ScanArrModel(),
        "history": HistoryModel(),
        "updateChecker": UpdateChecker(),
        "coefficientGen": CoefficientGenerator(),
        "projectCtl": ProjectController(),
    }
    for name in ("prjSet", "appSet", "scanArr"):
        services["projectCtl"].addWorkspace(services[name])
    return services
