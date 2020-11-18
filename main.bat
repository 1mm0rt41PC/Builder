CALL config.bat
CALL pre-install.bat


:: Build impacket
CALL clone.bat SecureAuthCorp/impacket
cd examples
CALL build.bat wmiexec , wmiexec , 0
CALL build.bat secretsdump , secretsdump , 0
CALL build.bat smbserver , smbserver , 0
CALL build.bat smbexec , smbexec , 0
CALL build.bat psexec , psexec , 0
CALL build.bat dcomexec , dcomexec , 0


:: Build pypykatz
CALL clone.bat skelsec/pypykatz
:: https://skelsec.medium.com/play-with-katz-get-scratched-6c2c350fadf2
:: https://drive.google.com/drive/folders/1KT2yWziJHvaH41jtZMsatey2KycWF824?usp=sharing
:: From https://github.com/skelsec/pypykatz/commit/f53ed8c691b32c2a5a0189604d56afe4732fb639
git config --global user.email "appveyor@appveyor-vm.com"
git config --global user.name "1mm0rt41PC"
git am %scriptpath%\patch_pypykatz
cd pypykatz
CALL build.bat __main__ , pypykatz , 0


:: Build BloodHound
CALL clone.bat fox-it/BloodHound.py
CALL build.bat bloodhound, bloodhound , 0


:: Build mitm6
CALL clone.bat fox-it/mitm6
cd mitm6
%py64%\python.exe -m pip install service_identity
%py32%\python.exe -m pip install service_identity
CALL build.bat mitm6, mitm6 , 0


:: Build Responder3
CALL clone.bat skelsec/Responder3
cd responder3
echo ..\examples\config.py > Responder3.lst7z
CALL build.bat __main__ , responder3 , 0


:: Build responder
CALL clone.bat lgandx/Responder
echo Responder.conf > Responder.lst7z
echo logs >> Responder.lst7z
echo files >> Responder.lst7z
echo certs >> Responder.lst7z
CALL build.bat Responder , Responder , 0


:: Sync threading
IF "%BUILDER_THREADING%" == "1" (
	CALL log.bat "Waiting thread..."
	powershell -exec bypass -nop -Command "Get-Process -Name cmd | Where-Object { $_.MainWindowTitle -like '*%BUILDER_THREADING_TITLE%*' } | select MainWindowTitle"
	powershell -exec bypass -nop -Command "while ( (Get-Process -Name cmd | Where-Object { $_.MainWindowTitle -like '*%BUILDER_THREADING_TITLE%*' }).Count -ne 0 ){ Write-Host "Waiting for threads"; Get-Process -Name cmd | Where-Object { $_.MainWindowTitle -like '*%BUILDER_THREADING_TITLE%*' } | select MainWindowTitle; sleep -Seconds 5 }"
)


:: #############################################################################
:END_MAIN
::7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\All.7z %scriptpath%\bin\*.exe
::appveyor PushArtifact %_7Z_OUPUT_%\All.7z
dir %scriptpath%\bin\
dir %_7Z_OUPUT_%
cd %_7Z_OUPUT_%
CALL log.bat "✅ Build END"
EXIT /B 0