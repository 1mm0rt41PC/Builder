SETLOCAL
set scriptpath=%~dp0
set scriptpath=%scriptpath:~0,-1%
IF "%APPVEYOR_BUILD_FOLDER%" NEQ "^%APPVEYOR_BUILD_FOLDER^%" SET scriptpath=%APPVEYOR_BUILD_FOLDER%
IF "%scriptpath%" == "" SET scriptpath=%CD%
IF %scriptpath% == ^%scriptpath^% SET scriptpath=%CD%
set py64=C:\Python39-x64
set py32=C:\Python39
set keylen=64
IF EXIST "%py64%\python.exe" GOTO py64
	echo "Installing Python 3 x64 in %py64% from %scriptpath%..."
	certutil.exe -urlcache -f https://www.python.org/ftp/python/3.9.0/python-3.9.0-amd64.exe python_installer.exe
	choco install python3 --params "/InstallDir:%py64%" "/InstallDir32:%py32%"
	python_installer.exe /quiet "InstallAllUsers=0" SimpleInstall=1 "DefaultJustForMeTargetDir=%py64%" AssociateFiles=0 InstallLauncherAllUsers=0 Include_doc=0 Include_launcher=0 Include_test=0
	del /q /s python_installer.exe
	certutil.exe -urlcache -f https://bootstrap.pypa.io/get-pip.py %scriptpath%\get-pip.py
	%py64%\python.exe -c "print('It works');"
	%py64%\python.exe %scriptpath%\get-pip.py
	%py64%\python.exe -m pip install -U pip
:py64

IF EXIST "%py32%\python.exe" GOTO py32
	echo "Installing Python 3 x86 in %py32% from %scriptpath%..."
	certutil.exe -urlcache -f https://www.python.org/ftp/python/3.9.0/python-3.9.0-amd64.exe python_installer.exe
	::choco install python3 --params "/InstallDir32:%py32%"
	python_installer.exe /quiet "InstallAllUsers=0" SimpleInstall=1 "DefaultJustForMeTargetDir=%py32%" AssociateFiles=0 InstallLauncherAllUsers=0 Include_doc=0 Include_launcher=0 Include_test=0
	del /q /s python_installer.exe
	certutil.exe -urlcache -f https://bootstrap.pypa.io/get-pip.py %scriptpath%\get-pip.py
	%py32%\python.exe -c "print('It works');"
	%py32%\python.exe %scriptpath%\get-pip.py
	%py32%\python.exe -m pip install -U pip
:py32

:: Generate random key for encryption
%py64%\python.exe -c "import random,string; print(''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(%keylen%)));" > %tmp%\pykey
set /p pykey= < %tmp%\pykey
del /q /s /f %tmp%\pykey 


mkdir %scriptpath%\bin

:: Generate random key for encryption
%py64%\python.exe -c "import random,string; print(''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(%keylen%)));" > %tmp%\pykey
set /p pykey= < %tmp%\pykey
del /q /s /f %tmp%\pykey 

:: Install pyinstaller
%py64%\python.exe -m pip install -U pip wheel ldap3 pywin32 pypiwin32
%py64%\python.exe -m pip install -U tinyaes dnspython
%py32%\python.exe -m pip install -U pip wheel ldap3 pywin32 pypiwin32
%py32%\python.exe -m pip install -U tinyaes dnspython
::%py32%\python.exe -m pip install -U pip wheel tinyaes dnspython ldap3 pywin32 pypiwin32
CALL :Clone pyinstaller/pyinstaller , pyinstaller

:: Build impacket
CALL :Clone SecureAuthCorp/impacket , impacket
cd examples
CALL :Build wmiexec , wmiexec
CALL :Build secretsdump , secretsdump
CALL :Build smbserver , smbserver
CALL :Build smbexec , smbexec
CALL :Build psexec , psexec

:: Build pypykatz
CALL :Clone skelsec/pypykatz , pypykatz
:: From https://github.com/skelsec/pypykatz/commit/f53ed8c691b32c2a5a0189604d56afe4732fb639
git am %scriptpath%\patch_pypykatz
cd pypykatz
CALL :Build __main__ , pypykatz

:: Build BloodHound
CALL :Clone fox-it/BloodHound.py , BloodHound.py
CALL :Build bloodhound, bloodhound

dir %scriptpath%\bin\

EXIT /B %ERRORLEVEL%
:: #############################################################################


:Build
CALL :Build_x86 %~1 , %~2
CALL :Build_x64 %~1 , %~2
EXIT /B 0

:Build_x86
%py32%\Scripts\pyinstaller.exe --key=%pykey% --icon=%scriptpath%\pytools.ico --onefile %~1.py & copy dist\%~1.exe %scriptpath%\bin\%~2_x86.exe
::start "Building %~2 x86" /D "%CD%" cmd /c "%py32%\Scripts\pyinstaller.exe --key=%pykey% --icon=%scriptpath%\pytools.ico --onefile %~1.py & copy dist\%~1.exe %scriptpath%\bin\%~2_x86.exe"
EXIT /B 0

:Build_x64
%py64%\Scripts\pyinstaller.exe --key=%pykey% --icon=%scriptpath%\pytools.ico --onefile %~1.py & copy dist\%~1.exe %scriptpath%\bin\%~2_x64.exe
::start "Building %~2 x64" /D "%CD%" cmd /c "%py64%\Scripts\pyinstaller.exe --key=%pykey% --icon=%scriptpath%\pytools.ico --onefile %~1.py & copy dist\%~1.exe %scriptpath%\bin\%~2_x64.exe"
EXIT /B 0


:Clone
cd %tmp%
rmdir /s /q %~2
git clone https://github.com/%~1 --depth 1
cd %~2
%py64%\python.exe -m pip install -r requirements.txt
%py64%\python.exe -m pip install .
%py32%\python.exe -m pip install -r requirements.txt
%py32%\python.exe -m pip install .
