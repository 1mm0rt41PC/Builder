SETLOCAL
set scriptpath=%~dp0
set scriptpath=%scriptpath:~0,-1%
IF "%APPVEYOR_BUILD_FOLDER%" NEQ "^%APPVEYOR_BUILD_FOLDER^%" SET scriptpath=%APPVEYOR_BUILD_FOLDER%
IF "%scriptpath%" == "" SET scriptpath=%CD%
IF %scriptpath% == ^%scriptpath^% SET scriptpath=%CD%
set py64=C:\Python39-x64
set py32=C:\Python39
set keylen=64
set DEBUG_BATCH=1
set _7Z_OUPUT_=%scriptpath%\bin
set _7Z_PASSWORD_=PimpMyPowny
%py64%\python.exe -m pip install -U pip wheel ldap3 pywin32 pypiwin32
git clone https://github.com/pyinstaller/pyinstaller --depth 1
cd pyinstaller
%py64%\python.exe -m pip install -r requirements.txt
%py64%\python.exe -m pip install .
set pyi=%py64%\Scripts\pyinstaller.exe
%pyi%