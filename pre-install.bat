IF "%LOADED_preinstall_bat%" == "1" EXIT /B 0
SET LOADED_preinstall_bat=1
CALL config.bat

IF EXIST "%py64%\python.exe" GOTO py64
	CALL log.bat "Installing Python 3 x64 in %py64% from %scriptpath%..."
	certutil.exe -urlcache -f https://www.python.org/ftp/python/3.9.0/python-3.8.0-amd64.exe python_installer.exe
	python_installer.exe /quiet "InstallAllUsers=0" SimpleInstall=1 "DefaultJustForMeTargetDir=%py64%" AssociateFiles=0 InstallLauncherAllUsers=0 Include_doc=0 Include_launcher=0 Include_test=0
	del /q /s python_installer.exe
	certutil.exe -urlcache -f https://bootstrap.pypa.io/get-pip.py %scriptpath%\get-pip.py
	%py64%\python.exe -c "print('It works');"
	%py64%\python.exe %scriptpath%\get-pip.py
	%py64%\python.exe -m pip install -U pip
:py64

IF EXIST "%py32%\python.exe" GOTO py32
	CALL log.bat "Installing Python 3 x86 in %py32% from %scriptpath%..."
	certutil.exe -urlcache -f https://www.python.org/ftp/python/3.8.0/python-3.8.0.exe python_installer.exe
	python_installer.exe /quiet "InstallAllUsers=0" SimpleInstall=1 "DefaultJustForMeTargetDir=%py32%" AssociateFiles=0 InstallLauncherAllUsers=0 Include_doc=0 Include_launcher=0 Include_test=0
	del /q /s python_installer.exe
	certutil.exe -urlcache -f https://bootstrap.pypa.io/get-pip.py %scriptpath%\get-pip.py
	%py32%\python.exe -c "print('It works');"
	%py32%\python.exe %scriptpath%\get-pip.py
	%py32%\python.exe -m pip install -U pip
:py32

mkdir %scriptpath%\bin


:: Install pyinstaller
%py64%\python.exe -m pip install -U pip wheel ldap3 pywin32 pypiwin32
%py64%\python.exe -m pip install -U tinyaes dnspython
%py64%\python.exe -m pip install -U git+https://github.com/pyinstaller/pyinstaller

%py32%\python.exe -m pip install -U pip wheel ldap3 pywin32 pypiwin32
%py32%\python.exe -m pip install -U tinyaes dnspython
%py32%\python.exe -m pip install -U git+https://github.com/pyinstaller/pyinstaller
::%py32%\python.exe -m pip install -U pip wheel tinyaes dnspython ldap3 pywin32 pypiwin32
::CALL clone.bat pyinstaller/pyinstaller , pyinstaller


go get -v github.com/akavel/rsrc
SET rsrc=%GOPATH%\bin\rsrc.exe

EXIT /B 0