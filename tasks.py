from invoke import task

@task
def build(c):
    c.run("pyside6-rcc ./resource.qrc -o ./resource_rc.py")
@task
def test(c):
    c.run("python -m unittest -v")
    c.run("qmltestrunner.exe -o qmltestres.txt")
    c.run("cat qmltestres.txt")
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
    # Check what files were created and rename to main.exe if needed
    import os
    import glob
    
    # Look for executable files that might have been created
    exe_files = glob.glob("*.exe")
    if "main.exe" not in exe_files:
        # Look for SenseTool.exe or other potential names
        if "SenseTool.exe" in exe_files:
            os.rename("SenseTool.exe", "main.exe")
            print("Renamed SenseTool.exe to main.exe")
        elif exe_files:
            # Rename the first .exe file found to main.exe
            os.rename(exe_files[0], "main.exe")
            print(f"Renamed {exe_files[0]} to main.exe")
        else:
            print("No executable files found after deployment")
            # List all files to help debug
            all_files = os.listdir(".")
            print(f"Files in directory: {all_files}")
    else:
        print("main.exe already exists")