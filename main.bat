CALL config.bat
CALL pre-install.bat


:: Build impacket
CALL clone.bat SecureAuthCorp/impacket
cd examples
%py64% -m pip install pcapy pyreadline
set hiddenimports= --hidden-import Get-GPPPassword --hidden-import ntfs-read --hidden-import registry-read
type %scriptpath%\custom-scripts\impacker.py > impacker.py
set "hiddenimports="
CALL build-py.bat impacker , impacker , 0
CALL build-py.bat Get-GPPPassword , Get-GPPPassword , 0
CALL build-py.bat GetADUsers , GetADUsers , 0
CALL build-py.bat GetNPUsers , GetNPUsers , 0
CALL build-py.bat GetUserSPNs , GetUserSPNs , 0
CALL build-py.bat addcomputer , addcomputer , 0
CALL build-py.bat dcomexec , dcomexec , 0
CALL build-py.bat findDelegation , findDelegation , 0
CALL build-py.bat getST , getST , 0
CALL build-py.bat getTGT , getTGT , 0
CALL build-py.bat psexec , psexec , 0
CALL build-py.bat rbcd , rbcd , 0
CALL build-py.bat rdp_check , rdp_check , 0
CALL build-py.bat rpcmap , rpcmap , 0
CALL build-py.bat secretsdump , secretsdump , 0
CALL build-py.bat services , services , 0
CALL build-py.bat smbclient , smbclient , 0
CALL build-py.bat smbexec , smbexec , 0
CALL build-py.bat smbserver , smbserver , 0
CALL build-py.bat ticketer , ticketer , 0
CALL build-py.bat tstool , tstool , 0
CALL build-py.bat wmiexec , wmiexec , 0
CALL build-py.bat atexec , atexec , 0
CALL build-py.bat ntlmrelayx , ntlmrelayx , 0
CALL build-py.bat lookupsid , lookupsid , 0

CALL clone.bat Hackndo/WebclientServiceScanner
cd webclientservicescanner
git am %scriptpath%\WebclientServiceScanner\0001-Add-color-by-k4nfr3-WebclientServiceScanner.patch
CALL build-py.bat console , WebclientServiceScanner , 0

CALL clone.bat ly4k/Certipy
cd build\lib\certipy
CALL build-py.bat entry , certipy , 0

CALL clone.bat ShutdownRepo/pywhisker
CALL build-py.bat pywhisker , pywhisker , 0

CALL clone.bat topotam/PetitPotam
CALL build-py.bat PetitPotam , PetitPotam , 0

:: See https://dirkjanm.io/krbrelayx-unconstrained-delegation-abuse-toolkit/
CALL clone.bat dirkjanm/krbrelayx
CALL build-py.bat krbrelayx , krbrelayx , 0
CALL build-py.bat printerbug , printerbug , 0
CALL build-py.bat dnstool , dnstool , 0
CALL build-py.bat addspn , addspn , 0

:: Build pypykatz
CALL clone.bat skelsec/pypykatz
%py64% -m pip install minidump minikerberos aiowinreg msldap winsspi winacl pycryptodome
%py64% -m pip install git+https://github.com/skelsec/unicrypto
:: https://skelsec.medium.com/play-with-katz-get-scratched-6c2c350fadf2
:: https://drive.google.com/drive/folders/1KT2yWziJHvaH41jtZMsatey2KycWF824?usp=sharing
:: From https://github.com/skelsec/pypykatz/commit/f53ed8c691b32c2a5a0189604d56afe4732fb639
::git am %scriptpath%\pypykatz\BruteForcer.patch
::git am %scriptpath%\pypykatz\Add-debug-message-for-method-handledup.patch
%py64% setup.py install
cd pypykatz
set hiddenimports= --hidden-import cryptography --hidden-import cffi --hidden-import cryptography.hazmat.backends.openssl --hidden-import cryptography.hazmat.bindings._openssl --hidden-import unicrypto --hidden-import unicrypto.backends.pycryptodome.DES --hidden-import  unicrypto.backends.pycryptodome.TDES --hidden-import unicrypto.backends.pycryptodome.AES --hidden-import unicrypto.backends.pycryptodome.RC4 --hidden-import unicrypto.backends.pure.DES --hidden-import  unicrypto.backends.pure.TDES --hidden-import unicrypto.backends.pure.AES --hidden-import unicrypto.backends.pure.RC4 --hidden-import unicrypto.backends.cryptography.DES --hidden-import  unicrypto.backends.cryptography.TDES --hidden-import unicrypto.backends.cryptography.AES --hidden-import unicrypto.backends.cryptography.RC4 --hidden-import unicrypto.backends.pycryptodomex.DES --hidden-import  unicrypto.backends.pycryptodomex.TDES --hidden-import unicrypto.backends.pycryptodomex.AES --hidden-import unicrypto.backends.pycryptodomex.RC4 --hidden-import unicrypto.backends.pycryptodomex
CALL build-py.bat __main__ , pypykatz , 0

CALL clone.bat zyn3rgy/LdapRelayScan
%py64% -m pip install minidump minikerberos aiowinreg msldap winsspi winacl pycryptodome
%py64% -m pip install git+https://github.com/skelsec/unicrypto
set hiddenimports= --hidden-import cryptography --hidden-import cffi --hidden-import cryptography.hazmat.backends.openssl --hidden-import cryptography.hazmat.bindings._openssl --hidden-import unicrypto --hidden-import unicrypto.backends.pycryptodome.DES --hidden-import  unicrypto.backends.pycryptodome.TDES --hidden-import unicrypto.backends.pycryptodome.AES --hidden-import unicrypto.backends.pycryptodome.RC4 --hidden-import unicrypto.backends.pure.DES --hidden-import  unicrypto.backends.pure.TDES --hidden-import unicrypto.backends.pure.AES --hidden-import unicrypto.backends.pure.RC4 --hidden-import unicrypto.backends.cryptography.DES --hidden-import  unicrypto.backends.cryptography.TDES --hidden-import unicrypto.backends.cryptography.AES --hidden-import unicrypto.backends.cryptography.RC4 --hidden-import unicrypto.backends.pycryptodomex.DES --hidden-import  unicrypto.backends.pycryptodomex.TDES --hidden-import unicrypto.backends.pycryptodomex.AES --hidden-import unicrypto.backends.pycryptodomex.RC4 --hidden-import unicrypto.backends.pycryptodomex
CALL build-py.bat LdapRelayScan , LdapRelayScan , 0

CALL clone.bat Hackndo/pyGPOAbuse
%py64% -m pip install minidump minikerberos aiowinreg msldap winsspi winacl pycryptodome
%py64% -m pip install git+https://github.com/skelsec/unicrypto
set hiddenimports= --hidden-import cryptography --hidden-import cffi --hidden-import cryptography.hazmat.backends.openssl --hidden-import cryptography.hazmat.bindings._openssl --hidden-import unicrypto --hidden-import unicrypto.backends.pycryptodome.DES --hidden-import  unicrypto.backends.pycryptodome.TDES --hidden-import unicrypto.backends.pycryptodome.AES --hidden-import unicrypto.backends.pycryptodome.RC4 --hidden-import unicrypto.backends.pure.DES --hidden-import  unicrypto.backends.pure.TDES --hidden-import unicrypto.backends.pure.AES --hidden-import unicrypto.backends.pure.RC4 --hidden-import unicrypto.backends.cryptography.DES --hidden-import  unicrypto.backends.cryptography.TDES --hidden-import unicrypto.backends.cryptography.AES --hidden-import unicrypto.backends.cryptography.RC4 --hidden-import unicrypto.backends.pycryptodomex.DES --hidden-import  unicrypto.backends.pycryptodomex.TDES --hidden-import unicrypto.backends.pycryptodomex.AES --hidden-import unicrypto.backends.pycryptodomex.RC4 --hidden-import unicrypto.backends.pycryptodomex
CALL build-py.bat pygpoabuse , pygpoabuse , 0

CALL clone.bat skelsec/kerberoast
cd kerberoast
%py64% -m pip install minidump minikerberos aiowinreg msldap winsspi winacl pycryptodome
%py64% -m pip install git+https://github.com/skelsec/unicrypto
set hiddenimports= --hidden-import cryptography --hidden-import cffi --hidden-import cryptography.hazmat.backends.openssl --hidden-import cryptography.hazmat.bindings._openssl --hidden-import unicrypto --hidden-import unicrypto.backends.pycryptodome.DES --hidden-import  unicrypto.backends.pycryptodome.TDES --hidden-import unicrypto.backends.pycryptodome.AES --hidden-import unicrypto.backends.pycryptodome.RC4 --hidden-import unicrypto.backends.pure.DES --hidden-import  unicrypto.backends.pure.TDES --hidden-import unicrypto.backends.pure.AES --hidden-import unicrypto.backends.pure.RC4 --hidden-import unicrypto.backends.cryptography.DES --hidden-import  unicrypto.backends.cryptography.TDES --hidden-import unicrypto.backends.cryptography.AES --hidden-import unicrypto.backends.cryptography.RC4 --hidden-import unicrypto.backends.pycryptodomex.DES --hidden-import  unicrypto.backends.pycryptodomex.TDES --hidden-import unicrypto.backends.pycryptodomex.AES --hidden-import unicrypto.backends.pycryptodomex.RC4 --hidden-import unicrypto.backends.pycryptodomex
CALL build-py.bat __main__ , kerberoast , 0


:: Build BloodHound
CALL clone.bat fox-it/BloodHound.py
:: Patch bloodhound to avoid "unrecognized arguments: --multiprocessing-fork"
:: In case where the patch doesn't work DO NOT USE "-c ALL" and avoid DCOnly and ACL. Use -c "Group,LocalAdmin,Session,Trusts,DCOM,RDP,PSRemote,LoggedOn,ObjectProps"
:: Maybe the argument "--disable-pooling" can do the tricks
%py64% -c "f=open('bloodhound/__init__.py','r');d=f.read().replace('    main()','    import multiprocessing;multiprocessing.freeze_support();main()');f.close();f=open('bloodhound/__init__.py','w');f.write(d);f.close();"
CALL build-py.bat bloodhound, bloodhound , 0


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


::CALL clone.bat icyguider/Nimcrypt2
::CALL log.bat "Install requirements for Nimcrypt2..."
::choco install -y nim
::RefreshEnv.cmd
::nimble install winim nimcrypto docopt ptr_math strenc -y
::CALL log.bat "Building Nimcrypt2..."
::nim c -d=release --cc:gcc --embedsrc=on --hints=on --app=console --cpu=amd64 --out=nimcrypt.exe nimcrypt.nim
::IF EXIST nimcrypt.exe (
::	CALL log.bat "✅ Build nimcrypt.exe OK" 1
::	echo nimcrypt.exe >nimcrypt.lst7z
::	7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\nimcrypt.7z @nimcrypt.lst7z
::	appveyor PushArtifact %_7Z_OUPUT_%\nimcrypt.7z
::	copy nimcrypt.exe %scriptpath%\bin\nimcrypt.exe
::	xcopy nimcrypt.exe C:\Windows
::) else (
::	CALL log.bat ERR "FAIL to build a valid nimcrypt.exe ..." , 1
::)


CALL clone.bat GhostPack/Rubeus
CALL log.bat "Building Rubeus..."
msbuild /t:Build /property:Configuration=Release
CALL log.bat "Create Rubeus.7z with required files..."
cd Rubeus\bin\release
Rubeus.exe -h
set _err=%ERRORLEVEL%
set _errorExpected=0
IF "%ERRORLEVEL%" == "%_errorExpected%" (
	CALL log.bat "✅ Build Rubeus.exe OK" 1
	::nimcrypt -f Rubeus.exe -o Rubeus.nimcrypt.exe -t csharp  -u -e
	echo Rubeus.exe >Rubeus.lst7z
	echo Rubeus.exe.config >>Rubeus.lst7z
	::echo Rubeus.nimcrypt.exe >>Rubeus.lst7z
	7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\Rubeus.7z @Rubeus.lst7z
	appveyor PushArtifact %_7Z_OUPUT_%\Rubeus.7z
	copy Rubeus.exe %scriptpath%\bin\Rubeus.exe
) else (
	CALL log.bat ERR "FAIL to build a valid Rubeus.exe (This bin return %_err%, expected %_errorExpected%)..." , 1
)


CALL clone.bat GhostPack/Certify
CALL log.bat "Building Certify..."
msbuild /t:Build /property:Configuration=Release
CALL log.bat "Create Certify.7z with required files..."
cd Certify\bin\release
Certify.exe -h
set _err=%ERRORLEVEL%
set _errorExpected=0
IF "%ERRORLEVEL%" == "%_errorExpected%" (
	CALL log.bat "✅ Build Certify.exe OK" 1
	echo Certify.exe >Certify.lst7z
	7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\Certify.7z @Certify.lst7z
	appveyor PushArtifact %_7Z_OUPUT_%\Certify.7z
	copy Certify.exe %scriptpath%\bin\Certify.exe
) else (
	CALL log.bat ERR "FAIL to build a valid Certify.exe (This bin return %_err%, expected %_errorExpected%)..." , 1
)


CALL clone.bat OPENCYBER-FR/RustHound
CALL log.bat "Installing Rust tool chain..."
choco install -y rustup.install
set "PATH=%PATH%;%USERPROFILE%\.cargo\bin"
::rustup.exe install stable-x86_64-pc-windows-gnu
::rustup.exe target add x86_64-pc-windows-gnu
rustup.exe install stable-x86_64-pc-windows-msvc
rustup.exe target add x86_64-pc-windows-msvc
CALL log.bat "Building RustHound..."
set "RUSTFLAGS=-C target-feature=+crt-static"
cargo build --release --target x86_64-pc-windows-msvc -j %NUMBER_OF_PROCESSORS%
cd target\x86_64-pc-windows-msvc\release
IF EXIST rusthound.exe (
	CALL log.bat "✅ Build rusthound.exe OK" 1
	echo rusthound.exe >rusthound.lst7z
	7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\rusthound.7z @rusthound.lst7z
	appveyor PushArtifact %_7Z_OUPUT_%\rusthound.7z
	copy rusthound.exe %scriptpath%\bin\rusthound.exe
) else (
	CALL log.bat ERR "FAIL to build a valid RustHound.exe ..." , 1
)


CALL clone.bat helpsystems/nanodump
CALL log.bat "Install requirements for nanodump..."
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
nmake -f Makefile.msvc
cd dist
IF EXIST nanodump.x64.exe (
	CALL log.bat "✅ Build nanodump OK" 1
	::nimcrypt -f nanodump.x64.exe -o nanodump.x64.nimcrypt.exe -t pe -p explorer.exe -u -e
	::nimcrypt -f nanodump_ppl.x64.exe -o nanodump_ppl.x64.nimcrypt.exe -t pe -p explorer.exe -u -e
	
	echo load_ssp.x64.exe >nanodump.lst7z
	echo load_ssp.x86.exe >>nanodump.lst7z
	echo nanodump.x64.exe >>nanodump.lst7z
	::echo nanodump.x64.nimcrypt.exe >>nanodump.lst7z
	echo nanodump.x86.exe >>nanodump.lst7z
	echo nanodump_ppl.x64.dll >>nanodump.lst7z
	echo nanodump_ppl.x64.exe >>nanodump.lst7z
	::echo nanodump_ppl.x64.nimcrypt.exe >>nanodump.lst7z
	echo nanodump_ppl.x86.dll >>nanodump.lst7z
	echo nanodump_ppl.x86.exe >>nanodump.lst7z
	echo nanodump_ssp.x64.dll >>nanodump.lst7z
	echo nanodump_ssp.x86.dll >>nanodump.lst7z
	
	7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\nanodump.7z @nanodump.lst7z
	appveyor PushArtifact %_7Z_OUPUT_%\nanodump.7z
	copy nanodump.x64.exe %scriptpath%\bin\nanodump.x64.exe
) else (
	CALL log.bat ERR "FAIL to build a valid nanodump ..." , 1
)


CALL clone.bat deepinstinct/LsassSilentProcessExit
CALL log.bat "Building LsassSilentProcessExit..."
msbuild /property:Configuration=Release
CALL log.bat "Create LsassSilentProcessExit.7z with required files..."
cd x64\Release
:: Running LsassSilentProcessExit will crash the script :'(
IF EXIST LsassSilentProcessExit.exe (
	CALL log.bat "✅ Build LsassSilentProcessExit.exe OK" 1
	::nimcrypt -f LsassSilentProcessExit.exe -o LsassSilentProcessExit.nimcrypt.exe -t pe -p explorer.exe -u -e
	echo LsassSilentProcessExit.exe >LsassSilentProcessExit.lst7z
	::echo LsassSilentProcessExit.nimcrypt.exe >>LsassSilentProcessExit.lst7z
	7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\LsassSilentProcessExit.7z @LsassSilentProcessExit.lst7z
	appveyor PushArtifact %_7Z_OUPUT_%\LsassSilentProcessExit.7z
	copy LsassSilentProcessExit.exe %scriptpath%\bin\LsassSilentProcessExit.exe
) else (
	CALL log.bat ERR "FAIL to build a valid LsassSilentProcessExit.exe ..." , 1
)


CALL clone.bat cube0x0/KrbRelay
CALL log.bat "Building KrbRelay..."
msbuild /property:Configuration=Release
CALL log.bat "Create KrbRelay.7z with required files..."
:: Running KrbRelay will crash the script :'(
IF EXIST KrbRelay\bin\Release\KrbRelay.exe (
	CALL log.bat "✅ Build KrbRelay.exe OK" 1
	echo KrbRelay\bin\Release\KrbRelay.exe            >  KrbRelay.lst7z
	echo KrbRelay\bin\Release\BouncyCastle.Crypto.dll >> KrbRelay.lst7z
	echo KrbRelay\bin\Release\KrbRelay.exe.config     >> KrbRelay.lst7z
	echo KrbRelay\bin\Release\MimeKitLite.dll         >> KrbRelay.lst7z
	echo KrbRelay\bin\Release\MimeKitLite.xml         >> KrbRelay.lst7z
	echo KrbRelay\bin\Release\System.Buffers.dll      >> KrbRelay.lst7z
	echo KrbRelay\bin\Release\System.Buffers.xml      >> KrbRelay.lst7z
	echo CheckPort\bin\Release\CheckPort.exe           >> KrbRelay.lst7z
	echo CheckPort\bin\Release\CheckPort.exe.config    >> KrbRelay.lst7z
	7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\KrbRelay.7z @KrbRelay.lst7z
	appveyor PushArtifact %_7Z_OUPUT_%\KrbRelay.7z
	copy KrbRelay\bin\Release\* %scriptpath%\bin\
	copy CheckPort\bin\Release\* %scriptpath%\bin\
) else (
	CALL log.bat ERR "FAIL to build a valid KrbRelay.exe ..." , 1
)

CALL clone.bat dirkjanm/adidnsdump
:: Require impacket && ldap3
cd adidnsdump
CALL build-py.bat dnsdump , dnsdump , 0

CALL clone.bat mssalvatore/powershell-pth
set hiddenimports= --hidden-import cffi
CALL build-py.bat powershell-pth , powershell-pth , 2

:: CrackMapExec
%py64% -m pip install git+https://github.com/skelsec/aardwolf
%py64% -m pip install minidump minikerberos aiowinreg msldap winsspi winacl pycryptodome
%py64% -m pip install git+https://github.com/skelsec/unicrypto
CALL clone.bat mpgn/CrackMapExec
type %scriptpath%\CrackMapExec\CrackMapExec.spec > CrackMapExec.spec
CALL build-py.bat CrackMapExec , CrackMapExec , 0

:: aardwolfgui
CALL clone.bat skelsec/aardwolfgui
set hiddenimports= --hidden-import aardwolf --hidden-import cryptography --hidden-import cffi --hidden-import cryptography.hazmat.backends.openssl --hidden-import cryptography.hazmat.bindings._openssl --hidden-import unicrypto --hidden-import unicrypto.backends.pycryptodome.DES --hidden-import  unicrypto.backends.pycryptodome.TDES --hidden-import unicrypto.backends.pycryptodome.AES --hidden-import unicrypto.backends.pycryptodome.RC4 --hidden-import unicrypto.backends.pure.DES --hidden-import  unicrypto.backends.pure.TDES --hidden-import unicrypto.backends.pure.AES --hidden-import unicrypto.backends.pure.RC4 --hidden-import unicrypto.backends.cryptography.DES --hidden-import  unicrypto.backends.cryptography.TDES --hidden-import unicrypto.backends.cryptography.AES --hidden-import unicrypto.backends.cryptography.RC4 --hidden-import unicrypto.backends.pycryptodomex.DES --hidden-import  unicrypto.backends.pycryptodomex.TDES --hidden-import unicrypto.backends.pycryptodomex.AES --hidden-import unicrypto.backends.pycryptodomex.RC4
cd aardwolfgui
CALL build-py.bat aardpclient , aardpclient , 0


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
