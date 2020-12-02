IF "%LOADED_config_bat%" == "1" EXIT /B 0
SET LOADED_config_bat=1
SET scriptpath=%~dp0
SET scriptpath=%scriptpath:~0,-1%
IF "%APPVEYOR_BUILD_FOLDER%" NEQ "^%APPVEYOR_BUILD_FOLDER^%" SET scriptpath=%APPVEYOR_BUILD_FOLDER%
IF "%scriptpath%" == "" SET scriptpath=%CD%
IF %scriptpath% == ^%scriptpath^% SET scriptpath=%CD%
SET PATH=%PATH%;%scriptpath%
SET py64=C:\Python38-x64\python.exe
SET py32=C:\Python38\python.exe
SET keylen=64
SET _7Z_OUPUT_=%scriptpath%\bin
set BUILDER_THREADING=0
set BUILDER_NB_THREAD=%NUMBER_OF_PROCESSORS%
set PYTHONOPTIMIZE=1
SET CGO_ENABLED=0
SET GOPATH=%scriptpath%\GOPATH\

:: Generate random key for encryption
powershell -exec bypass -nop -Command "-join ((65..90) + (97..122) | Get-Random -Count %keylen% | %% {[char]$_})" > %tmp%\pykey
SET /p pykey= < %tmp%\pykey
del /q /s /f %tmp%\pykey

:: Generate random key for 7z encryption
powershell -exec bypass -nop -Command "-join ((65..90) + (97..122) | Get-Random -Count %keylen% | %% {[char]$_})" > %tmp%\_7Z_PASSWORD_
SET /p _7Z_PASSWORD_= < %tmp%\_7Z_PASSWORD_
del /q /s /f %tmp%\_7Z_PASSWORD_


:: Generate random title for threading
IF "%BUILDER_THREADING%" == "1" (
	powershell -exec bypass -nop -Command "-join ((65..90) + (97..122) | Get-Random -Count %keylen% | %% {[char]$_})" > %tmp%\BUILDER_THREADING_TITLE
	SET /p BUILDER_THREADING_TITLE= < %tmp%\BUILDER_THREADING_TITLE
	del /q /s /f %tmp%\BUILDER_THREADING_TITLE
)


echo [105;93m===========================================================================
echo = CONFIG =
echo scriptpath=%scriptpath%
echo APPVEYOR_BUILD_FOLDER=%APPVEYOR_BUILD_FOLDER%
echo py64=%py64%
echo py32=%py32%
echo BUILDER_THREADING=%BUILDER_THREADING%
echo BUILDER_NB_THREAD=%BUILDER_NB_THREAD%
echo BUILDER_THREADING_TITLE=%BUILDER_THREADING_TITLE%
echo keylen=%keylen%
echo _7Z_OUPUT_=%_7Z_OUPUT_%
echo _7Z_PASSWORD_=%_7Z_PASSWORD_%
echo ===========================================================================[0m

appveyor SetVariable -Name _7Z_PASSWORD_ -Value %_7Z_PASSWORD_%
CALL log.bat "Using 7z key=%_7Z_PASSWORD_%" 1
EXIT /B 0