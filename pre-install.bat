IF "%LOADED_preinstall_bat%" == "1" EXIT /B 0
SET LOADED_preinstall_bat=1
CALL config.bat

git config --global user.email "appveyor@appveyor-vm.com"
git config --global user.name "1mm0rt41PC"

mkdir %scriptpath%\bin

:: Install pyinstaller
%py64% -m pip install -U pip wheel ldap3 pywin32 pypiwin32
%py64% -m pip install -U tinyaes dnspython
%py64% -m pip install -U git+https://github.com/pyinstaller/pyinstaller

IF "%ENABLE_BUILD_X86%" == "1" (
	%py32% -m pip install -U pip wheel ldap3 pywin32 pypiwin32
	%py32% -m pip install -U tinyaes dnspython
	%py32% -m pip install -U git+https://github.com/pyinstaller/pyinstaller
)

go get -v github.com/akavel/rsrc
SET rsrc=%GOPATH%\bin\rsrc.exe

EXIT /B 0