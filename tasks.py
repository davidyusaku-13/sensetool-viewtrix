from invoke import task

@task
def build(c):
    c.run("pyside6-rcc ./resource.qrc -o ./resource_rc.py")
@task
def test(c):
    c.run("python -m unittest -v")
    c.run("qmltestrunner.exe")
@task
def run(c):
    build(c)
    c.run("python main.py")
@task
def clean(c, bytecode=False, extra=''):
    patterns = ['deployed']
    for pattern in patterns:
        c.run("del {}".format(pattern))
@task
def deploy(c):
    build(c)
    c.run("pyside6-deploy -f")