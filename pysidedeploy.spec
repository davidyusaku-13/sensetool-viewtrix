[app]
# title of your application
title = SenseTool
# project directory. the general assumption is that project_dir is the parent directory
# of input_file
project_dir = .
# source file path
input_file = D:\Kuliah\Viewtrix\sensetool-viewtrix\main.py
# directory where exec is stored
exec_directory = .
# application icon
icon = D:\Kuliah\Viewtrix\sensetool-viewtrix\icon.ico

[python]
# python path
python_path = D:\Kuliah\Viewtrix\sensetool-viewtrix\env\Scripts\python.exe
# python packages to install
# ordered-set = increase compile time performance of nuitka packaging
# zstandard = provides final executable size optimization
packages = Nuitka==2.1

[qt]
# comma separated path to qml files required
# normally all the qml files required by the project are added automatically
qml_files = qml\main.qml,qml\sensetrix.qml,qml\updatewindow.qml,qml\pages\hwutil\coefgenchart.qml,qml\pages\hwutil\hwutilpage.qml,qml\pages\prjset\confirmwindow.qml,qml\pages\prjset\prjsetitem.qml,qml\pages\prjset\prjsetobject.qml,qml\pages\prjset\prjsetpage.qml,qml\pages\prjset\prjsetwindow.qml,qml\pages\scanarr\scanarritem.qml,qml\pages\scanarr\scanarrpage.qml,qml\pages\scanarr\arrangementcolumn\scanarrcolumn.qml,qml\pages\scanarr\arrangementcolumn\scanarritem.qml,qml\pages\scanarr\arrangementcolumn\scanarrobject.qml,qml\pages\scanarr\arrangementcolumn\scanarrwindow.qml,qml\pages\scanarr\itemcolumn\scanitem.qml,qml\pages\scanarr\itemcolumn\scanitemcolumn.qml,qml\pages\scanarr\itemcolumn\scanobject.qml,qml\pages\scanarr\itemcolumn\scanwindow.qml,qml\pages\scanarr\listcolumn\scanarrlistcolumn.qml,qml\pages\scanarr\listcolumn\scanarrlistitem.qml,qml\pages\scanarr\listcolumn\scanarrlistobject.qml,qml\pages\scanarr\listcolumn\scanarrlistwindow.qml,qml\pages\scanarr\confirmwindow.qml,qml\components\mybutton.qml,qml\components\shadowrect.qml,qml\components\toolbarbtn.qml,qml\layouts\header.qml,qml\layouts\headerlist.qml,qml\layouts\popupmenu.qml,qml\layouts\sidebar.qml,qml\layouts\sidebarlist.qml
# excluded qml plugin binaries
excluded_qml_plugins = QtSensors,QtWebEngine
# qt modules used. comma separated
modules = Network,Widgets,QmlModels,OpenGL,Gui,Qml,QuickControls2,Core,Quick,QuickTemplates2
# qt plugins used by the application
plugins = platformthemes,tls,accessiblebridge,platforms/darwin,imageformats,qmltooling,egldeviceintegrations,xcbglintegrations,iconengines,networkinformation,scenegraph,styles,networkaccess,platforms,generic,platforminputcontexts

[nuitka]
# usage description for permissions requested by the app as found in the info.plist file
# of the app bundle
# eg = extra_args = --show-modules --follow-stdlib
# (str) specify any extra nuitka arguments
extra_args = --quiet --noinclude-qt-translations --disable-console --assume-yes-for-downloads --include-data-files=VERSION.txt=VERSION.txt --include-data-files=translations/sensetool_en.qm=translations/sensetool_en.qm --include-data-files=translations/sensetool_id.qm=translations/sensetool_id.qm

