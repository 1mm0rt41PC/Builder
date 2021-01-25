CALL config.bat
:: #############################################################################
:: @brief Clone repo
:: @param Github repo without the prefix https://github.com/
:: @param Github repo without the prefix https://github.com/
set _git_repo=%~1
set _git_folder=%_git_repo::=_%
set _git_folder=%tmp%\%_git_folder:/=_%
rmdir /s /q %_git_folder%
IF %_git_repo:https://=_% == %_git_repo% (
	git clone https://github.com/%_git_repo% --depth 1 %_git_folder%
) ELSE (
	git clone %_git_repo% --depth 1 %_git_folder%
)
cd %_git_folder%
IF EXIST requirements.txt (
	%py64% -m pip install --no-warn-script-location -r requirements.txt
	%py32% -m pip install --no-warn-script-location -r requirements.txt
)
IF EXIST *.py (
	%py64% -m pip install --no-warn-script-location .
	%py32% -m pip install --no-warn-script-location .
)
IF EXIST *.go (
	go get -v
)
EXIT /B 0