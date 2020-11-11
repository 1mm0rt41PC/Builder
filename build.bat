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
echo [105;93m===========================================================================
echo = CONFIG =
echo scriptpath=%scriptpath%
echo APPVEYOR_BUILD_FOLDER=%APPVEYOR_BUILD_FOLDER%
echo py64=%py64%
echo py32=%py32%
echo keylen=%keylen%
echo DEBUG_BATCH=%DEBUG_BATCH%
echo _7Z_OUPUT_=%_7Z_OUPUT_%
echo ===========================================================================[0m

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
	certutil.exe -urlcache -f https://www.python.org/ftp/python/3.9.0/python-3.9.0.exe python_installer.exe
	::choco install python3 --params "/InstallDir32:%py32%"
	python_installer.exe /quiet "InstallAllUsers=0" SimpleInstall=1 "DefaultJustForMeTargetDir=%py32%" AssociateFiles=0 InstallLauncherAllUsers=0 Include_doc=0 Include_launcher=0 Include_test=0
	del /q /s python_installer.exe
	certutil.exe -urlcache -f https://bootstrap.pypa.io/get-pip.py %scriptpath%\get-pip.py
	%py32%\python.exe -c "print('It works');"
	%py32%\python.exe %scriptpath%\get-pip.py
	%py32%\python.exe -m pip install -U pip
:py32

mkdir %scriptpath%\bin

:: Generate random key for encryption
%py64%\python.exe -c "import random,string; print(''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(%keylen%)));" > %tmp%\pykey
set /p pykey= < %tmp%\pykey
del /q /s /f %tmp%\pykey

:: Generate random key for 7z encryption
%py64%\python.exe -c "import random,string; print(''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(%keylen%)));" > %tmp%\pykey
set /p _7Z_PASSWORD_= < %tmp%\pykey
del /q /s /f %tmp%\pykey

appveyor SetVariable -Name _7Z_PASSWORD_ -Value %_7Z_PASSWORD_%

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
CALL :Build wmiexec , wmiexec , 1
CALL :Build secretsdump , secretsdump , 1
CALL :Build smbserver , smbserver , 1
CALL :Build smbexec , smbexec , 1
CALL :Build psexec , psexec , 1

:: Build pypykatz
CALL :Clone skelsec/pypykatz , pypykatz
:: From https://github.com/skelsec/pypykatz/commit/f53ed8c691b32c2a5a0189604d56afe4732fb639
git am %scriptpath%\patch_pypykatz
cd pypykatz
CALL :Build __main__ , pypykatz , 2

:: Build BloodHound
CALL :Clone fox-it/BloodHound.py , BloodHound.py
CALL :Build bloodhound, bloodhound , 1


:: #############################################################################
IF "%DEBUG_BATCH%" == "1" GOTO End

:: Wait for 01min00
set I=A
:LOOP
	dir %scriptpath%\bin\
	dir %_7Z_OUPUT_%
	:: Sleep 10
	ping -n 10 127.0.0.1
	set I=A%I%
	IF "%I%" == "AAAAAA" EXIT /B 42
IF NOT EXIST %scriptpath%\bin\bloodhound_x64.ok GOTO LOOP

:End
7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\All.7z %scriptpath%\bin\*.exe
appveyor PushArtifact %_7Z_OUPUT_%\All.7z
dir %scriptpath%\bin\
dir %_7Z_OUPUT_%
cd %_7Z_OUPUT_%
echo [42;93m= Build END[0m

EXIT /B 0
:: #############################################################################



:: #############################################################################
:: @brief Build bin in x64 and in x86
:: @param python script to build
:: @param prefix for the exe name
:: @param Error code expected
:Build
CALL :Build_arch %~1 , %~2 , x86 , %py32%\Scripts\pyinstaller.exe , %~3
CALL :Build_arch %~1 , %~2 , x64 , %py64%\Scripts\pyinstaller.exe , %~3
EXIT /B 0


:: #############################################################################
:: @brief Build bin
:: @param python script to build
:: @param prefix for the exe name
:: @param arch: x64 / x86
:: @param pyinstaller to use
:: @param Error code expected
:Build_arch
echo [105;93m===========================================================================
set _pyTarget=%~1
set _outTarget=%~2
set _arch=%~3
set _pyinstaller=%~4
set _errorExpected=%~5
echo = Building %_outTarget%_%_arch%.exe[0m
if "%DEBUG_BATCH%" == "0" GOTO Build_arch_thread
	%_pyinstaller% --key=%pykey% --icon=%scriptpath%\pytools.ico --onefile %_pyTarget%.py
	dist\%_pyTarget%.exe
	IF "%ERRORLEVEL%" == "%_errorExpected%" (
		echo [42;93m= Build %_outTarget%_%_arch%.exe OK[0m
		copy dist\%_pyTarget%.exe %scriptpath%\bin\%_outTarget%_%_arch%.exe
		7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\%_outTarget%_%_arch%.7z %scriptpath%\bin\%_outTarget%_%_arch%.exe
		appveyor PushArtifact %_7Z_OUPUT_%\%_outTarget%_%_arch%.7z
	) else (
		echo [101;93m= Build %_outTarget%_%_arch%.exe FAIL with %ERRORLEVEL%[0m
	)
	EXIT /B 0
:Build_arch_thread
	start "Building %_outTarget% %_arch%" /D "%CD%" cmd /c "%_pyinstaller% --key=%pykey% --icon=%scriptpath%\pytools.ico --onefile %_pyTarget%.py & dist\%_pyTarget%.exe && ( echo = Build %_outTarget%_%_arch%.exe OK & copy dist\%_pyTarget%.exe %scriptpath%\bin\%_outTarget%_%_arch%.exe & 7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\%_outTarget%_%_arch%.7z %scriptpath%\bin\%_outTarget%_%_arch%.exe & appveyor PushArtifact %_7Z_OUPUT_%\%_outTarget%_%_arch%.7z ) || ( echo = Build %_outTarget%_%_arch%.exe FAIL !!!!!! ) & echo . > %scriptpath%\bin\%~2_x86.ok"
	EXIT /B 0


:Clone
cd %tmp%
rmdir /s /q %~2
git clone https://github.com/%~1 --depth 1
cd %~2
IF EXIST requirements.txt %py64%\python.exe -m pip install -r requirements.txt
%py64%\python.exe -m pip install .
IF EXIST requirements.txt %py32%\python.exe -m pip install -r requirements.txt
%py32%\python.exe -m pip install .