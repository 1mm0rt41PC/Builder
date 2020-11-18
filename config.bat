IF %LOADED_config_bat% == 1 GOTO EOF
SETLOCAL
set LOADED_config_bat=1
set scriptpath=%~dp0
set scriptpath=%scriptpath:~0,-1%
IF "%APPVEYOR_BUILD_FOLDER%" NEQ "^%APPVEYOR_BUILD_FOLDER^%" SET scriptpath=%APPVEYOR_BUILD_FOLDER%
IF "%scriptpath%" == "" SET scriptpath=%CD%
IF %scriptpath% == ^%scriptpath^% SET scriptpath=%CD%
set PATH=%PATH%;%scriptpath%
set py64=C:\Python38-x64
set py32=C:\Python38
set keylen=64
set DEBUG_BATCH=1
set _7Z_OUPUT_=%scriptpath%\bin

:: Generate random key for encryption
powershell -exec bypass -nop -Command "-join ((65..90) + (97..122) | Get-Random -Count %keylen% | % {[char]$_})" > %tmp%\pykey
set /p pykey= < %tmp%\pykey
del /q /s /f %tmp%\pykey

:: Generate random key for 7z encryption
powershell -exec bypass -nop -Command "-join ((65..90) + (97..122) | Get-Random -Count %keylen% | % {[char]$_})" > %tmp%\_7Z_PASSWORD_
set /p _7Z_PASSWORD_= < %tmp%\_7Z_PASSWORD_
del /q /s /f %tmp%\_7Z_PASSWORD_

echo [105;93m===========================================================================
echo = CONFIG =
echo scriptpath=%scriptpath%
echo APPVEYOR_BUILD_FOLDER=%APPVEYOR_BUILD_FOLDER%
echo py64=%py64%
echo py32=%py32%
echo keylen=%keylen%
echo DEBUG_BATCH=%DEBUG_BATCH%
echo _7Z_OUPUT_=%_7Z_OUPUT_%
echo _7Z_PASSWORD_=%_7Z_PASSWORD_%
echo ===========================================================================[0m


appveyor SetVariable -Name _7Z_PASSWORD_ -Value %_7Z_PASSWORD_%
appveyor AddMessage "[%date% %time%] Using 7z key=%_7Z_PASSWORD_%" -Category Information
:EOF
EXIT /B 0