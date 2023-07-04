IF "%LOADED_preinstall_bat%" == "1" EXIT /B 0
SET LOADED_preinstall_bat=1
CALL config.bat

git config --global user.email "appveyor@appveyor-vm.com"
git config --global user.name "1mm0rt41PC"

mkdir %scriptpath%\bin

:: Install pyinstaller
%py64% -m pip install -U pip wheel ldap3 pywin32 pypiwin32
%py64% -m pip install -U tinyaes dnspython


::%py64% -m pip install -U git+https://github.com/pyinstaller/pyinstaller
:: The commit https://github.com/pyinstaller/pyinstaller/pull/6999 break the AES encryption ...
cd %tmp%
git clone https://github.com/pyinstaller/pyinstaller
cd pyinstaller
git checkout v5.13.0 .
git checkout develop bootloader
cd bootloader
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
mklink /D "C:\Program Files\Microsoft Visual Studio" "C:\Program Files (x86)\Microsoft Visual Studio"
%py64% waf waf configure distclean all --msvc_targets=x64
cd ..
%py64% -m pip install .

IF "%ENABLE_BUILD_X86%" == "1" (
	%py32% -m pip install -U pip wheel ldap3 pywin32 pypiwin32
	%py32% -m pip install -U tinyaes dnspython
	%py32% -m pip install -U git+https://github.com/pyinstaller/pyinstaller
)

go get -v github.com/akavel/rsrc
SET rsrc=%GOPATH%\bin\rsrc.exe

EXIT /B 0
