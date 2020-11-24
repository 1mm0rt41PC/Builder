CALL config.bat
CALL pre-install.bat


:: Build impacket
CALL clone.bat SecureAuthCorp/impacket
cd examples
CALL build-py.bat wmiexec , wmiexec , 0
CALL build-py.bat secretsdump , secretsdump , 0
CALL build-py.bat smbserver , smbserver , 0
CALL build-py.bat smbexec , smbexec , 0
CALL build-py.bat psexec , psexec , 0
CALL build-py.bat dcomexec , dcomexec , 0


:: Build pypykatz
CALL clone.bat skelsec/pypykatz
:: https://skelsec.medium.com/play-with-katz-get-scratched-6c2c350fadf2
:: https://drive.google.com/drive/folders/1KT2yWziJHvaH41jtZMsatey2KycWF824?usp=sharing
:: From https://github.com/skelsec/pypykatz/commit/f53ed8c691b32c2a5a0189604d56afe4732fb639
git config --global user.email "appveyor@appveyor-vm.com"
git config --global user.name "1mm0rt41PC"
git am %scriptpath%\patch_pypykatz
cd pypykatz
CALL build-py.bat __main__ , pypykatz , 0


:: Build BloodHound
CALL clone.bat fox-it/BloodHound.py
CALL build-py.bat bloodhound, bloodhound , 0


:: DISABLED => See https://github.com/fox-it/mitm6/issues/3
:: Build mitm6
::CALL clone.bat fox-it/mitm6
::cd mitm6
::%py64%\python.exe -m pip install service_identity
::%py32%\python.exe -m pip install service_identity
::CALL build-py.bat mitm6, mitm6 , 0


:: Build Responder3
CALL clone.bat skelsec/Responder3
cd responder3
echo ..\examples\config.py > Responder3.lst7z
CALL build-py.bat __main__ , responder3 , 0


:: Build responder
CALL clone.bat lgandx/Responder
echo Responder.conf > Responder.lst7z
echo logs >> Responder.lst7z
echo files >> Responder.lst7z
echo certs >> Responder.lst7z
CALL build-py.bat Responder , Responder , 0


:: Build sshdog
CALL clone.bat cyd01/sshdog
CALL build-go.bat sshdog , 0


:: Sync threading
CALL sync-thread.bat 0


:: #############################################################################
:END_MAIN
::7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\All.7z %scriptpath%\bin\*.exe
::appveyor PushArtifact %_7Z_OUPUT_%\All.7z
dir %scriptpath%\bin\
dir %_7Z_OUPUT_%
cd %_7Z_OUPUT_%
CALL log.bat "✅ Build END"
EXIT /B 0