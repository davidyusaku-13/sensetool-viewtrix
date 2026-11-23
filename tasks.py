from pathlib import Path
from invoke import task

@task
def build(c):
    c.run("pyside6-rcc ./resource.qrc -o ./resource_rc.py")
@task
def test(c):
    """Lint and run every test, as CI does."""
    c.run("uv run ruff check .")
    c.run("uv run pyside6-qmllint " + " ".join(str(p) for p in Path("qml").rglob("*.qml")))
    c.run("uv run python -m unittest -v")
    c.run("uv run python tests/run_qml_tests.py")
@task
def run(c):
    build(c)
    c.run("python main.py")
@task
def clean(c, bytecode=False, extra=''):
    patterns = ['main.exe']
    for pattern in patterns:
        c.run("del {}".format(pattern))
@task
def deploy(c):
    build(c)
    c.run("pyside6-deploy -f")
