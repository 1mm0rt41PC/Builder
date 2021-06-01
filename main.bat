CALL config.bat
CALL pre-install.bat


:: Build impacket
CALL clone.bat SecureAuthCorp/impacket
cd examples
CALL build-py.bat wmiexec , wmiexec , 0
CALL build-py.bat secretsdump , secretsdump , 0
CALL build-py.bat smbserver , smbserver , 0
CALL build-py.bat smbclient , smbclient , 0
CALL build-py.bat smbexec , smbexec , 0
CALL build-py.bat psexec , psexec , 0
CALL build-py.bat dcomexec , dcomexec , 0
CALL build-py.bat GetUserSPNs , GetUserSPNs , 0
CALL build-py.bat GetNPUsers , GetNPUsers , 0
CALL build-py.bat getST , getST , 0
CALL build-py.bat getTGT , getTGT , 0
CALL build-py.bat ticketer , ticketer , 0


CALL clone.bat NinjaStyle82/rbcd_permissions
CALL build-py.bat rbcd , rbcd , 0


:: See https://dirkjanm.io/krbrelayx-unconstrained-delegation-abuse-toolkit/
CALL clone.bat dirkjanm/krbrelayx
CALL build-py.bat krbrelayx , krbrelayx , 0
CALL build-py.bat printerbug , printerbug , 0
CALL build-py.bat dnstool , dnstool , 0
CALL build-py.bat addspn , addspn , 0


:: Build pypykatz
CALL clone.bat skelsec/pypykatz
%py64% -m pip install minidump minikerberos aiowinreg msldap winsspi
%py32% -m pip install minidump minikerberos aiowinreg msldap winsspi
:: https://skelsec.medium.com/play-with-katz-get-scratched-6c2c350fadf2
:: https://drive.google.com/drive/folders/1KT2yWziJHvaH41jtZMsatey2KycWF824?usp=sharing
:: From https://github.com/skelsec/pypykatz/commit/f53ed8c691b32c2a5a0189604d56afe4732fb639
git config --global user.email "appveyor@appveyor-vm.com"
git config --global user.name "1mm0rt41PC"
git am %scriptpath%\pypykatz\BruteForcer.patch
git am %scriptpath%\pypykatz\Add-debug-message-for-method-handledup.patch
cd pypykatz
CALL build-py.bat __main__ , pypykatz , 0


CALL clone.bat skelsec/kerberoast
cd kerberoast
CALL build-py.bat kerberoast , kerberoast , 0


:: Build BloodHound
CALL clone.bat fox-it/BloodHound.py
:: Patch bloodhound to avoid "unrecognized arguments: --multiprocessing-fork"
:: In case where the patch doesn't work DO NOT USE "-c ALL" and avoid DCOnly and ACL. Use -c "Group,LocalAdmin,Session,Trusts,DCOM,RDP,PSRemote,LoggedOn,ObjectProps"
:: Maybe the argument "--disable-pooling" can do the tricks
%py64% -c "f=open('bloodhound/__init__.py','r');d=f.read().replace('    main()','    import multiprocessing;multiprocessing.freeze_support();main()');f.close();f=open('bloodhound/__init__.py','w').write(d);f.close();"
CALL build-py.bat bloodhound, bloodhound , 0


:: DISABLED => See https://github.com/fox-it/mitm6/issues/3
:: Build mitm6
::CALL clone.bat fox-it/mitm6
::cd mitm6
::%py64% -m pip install service_identity
::%py32% -m pip install service_identity
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
::CALL clone.bat cyd01/sshdog
::echo PUT YOUR PUB KEY HERE > config/authorized_keys
::ssh-keygen -t rsa -b 2048 -N '' -f config/ssh_host_rsa_key
::echo 1mm0rt41 %_7Z_PASSWORD_% > config/users
::echo config/ > sshdog.lst7z
::CALL build-go.bat sshdog , 1


:: Build gpppfinder
CALL clone.bat https://bitbucket.org/grimhacker/gpppfinder.git
CALL build-py.bat cli , gpppfinder , 0


CALL clone.bat GhostPack/Rubeus
CALL log.bat "Building Rubeus..."
msbuild /property:Configuration=Release
CALL log.bat "Create Rubeus.7z with required files..."
cd Rubeus\bin\release
IF EXIST Rubeus (
	CALL log.bat "✅ Build Rubeus.exe OK" 1
	echo Rubeus.exe >Rubeus.lst7z
	echo Rubeus.exe.config >>Rubeus.lst7z
	7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\Rubeus.7z @Rubeus.lst7z
	appveyor PushArtifact Rubeus.7z
	copy Rubeus.exe %scriptpath%\bin\Rubeus.exe
)

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
