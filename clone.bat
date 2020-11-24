CALL config.bat
:: #############################################################################
:: @brief Clone repo
:: @param Github repo without the prefix https://github.com/
:: @param Github repo without the prefix https://github.com/
set _git_repo=%~1
set _git_folder=%tmp%\%_git_repo:/=_%
rmdir /s /q %_git_folder%
git clone https://github.com/%_git_repo% --depth 1 %_git_folder%
cd %_git_folder%
IF EXIST requirements.txt (
	%py64%\python.exe -m pip install -r requirements.txt
	%py32%\python.exe -m pip install -r requirements.txt
)
IF EXIST *.py (
	%py64%\python.exe -m pip install -r .
	%py32%\python.exe -m pip install -r .
)
IF EXIST *.go (
	go get
)
EXIT /B 0