[app]
# title of your application
title = SenseTool
# project directory. the general assumption is that project_dir is the parent directory
# of input_file
project_dir = .
# source file path
input_file = main.py
# directory where exec is stored
exec_directory = .
# application icon
icon = icon.ico

[python]
# python path
python_path = env/Scripts/python.exe
# python packages to install
# ordered-set = increase compile time performance of nuitka packaging
# zstandard = provides final executable size optimization
packages = Nuitka==2.5.1

[qt]
# comma separated path to qml files required
# normally all the qml files required by the project are added automatically
qml_files = qml/main.qml,qml/SenseTool.qml,qml/UpdateWindow.qml,qml/pages/hwutil/CoefGenChart.qml,qml/pages/hwutil/HwUtilPage.qml,qml/pages/prjset/ConfirmWindow.qml,qml/pages/prjset/PrjSetItem.qml,qml/pages/prjset/PrjSetObject.qml,qml/pages/prjset/PrjSetPage.qml,qml/pages/prjset/PrjSetWindow.qml,qml/pages/scanarr/ScanArrItem.qml,qml/pages/scanarr/ScanArrPage.qml,qml/pages/scanarr/ArrangementColumn/ScanArrColumn.qml,qml/pages/scanarr/ArrangementColumn/ScanArrItem.qml,qml/pages/scanarr/ArrangementColumn/ScanArrObject.qml,qml/pages/scanarr/ArrangementColumn/ScanArrWindow.qml,qml/pages/scanarr/ItemColumn/ScanItem.qml,qml/pages/scanarr/ItemColumn/ScanItemColumn.qml,qml/pages/scanarr/ItemColumn/ScanObject.qml,qml/pages/scanarr/ItemColumn/ScanWindow.qml,qml/pages/scanarr/ListColumn/ScanArrListColumn.qml,qml/pages/scanarr/ListColumn/ScanArrListItem.qml,qml/pages/scanarr/ListColumn/ScanArrListObject.qml,qml/pages/scanarr/ListColumn/ScanArrListWindow.qml,qml/pages/scanarr/ConfirmWindow.qml,qml/components/MyButton.qml,qml/components/ShadowRect.qml,qml/components/ToolbarBtn.qml,qml/layouts/Header.qml,qml/layouts/HeaderList.qml,qml/layouts/PopUpMenu.qml,qml/layouts/SideBar.qml,qml/layouts/SideBarList.qml
# excluded qml plugin binaries
excluded_qml_plugins = QtSensors,QtWebEngine
# qt modules used. comma separated
modules = OpenGL,Widgets,Network,Qml,Core,QmlModels,Gui,QuickTemplates2,QuickControls2,Quick
# qt plugins used by the application
plugins = platformthemes,tls,accessiblebridge,platforms/darwin,imageformats,qmltooling,egldeviceintegrations,xcbglintegrations,iconengines,networkinformation,scenegraph,styles,networkaccess,platforms,generic,platforminputcontexts

[nuitka]
# usage description for permissions requested by the app as found in the info.plist file
# of the app bundle
# eg = extra_args = --show-modules --follow-stdlib
# (str) specify any extra nuitka arguments
extra_args = --quiet --noinclude-qt-translations --disable-console --assume-yes-for-downloads --include-data-files=translations/sensetool_en.qm=translations/sensetool_en.qm --include-data-files=translations/sensetool_id.qm=translations/sensetool_id.qm
