CALL config.bat
CALL pre-install.bat
:: #############################################################################
:: @brief Build bin in x64 and in x86
:: @param python script to build
:: @param prefix for the exe name
:: @param Error code expected
SET _pyTarget=%~1
SET _outTarget=%~2
SET _errorExpected=%~3
SET _arch=%~4
SET _pyinstaller=%~5

IF "%_arch%" NEQ "" (
	GOTO :Build_arch_main
	EXIT /B 0
)

IF "%BUILDER_THREADING%" == "1" (
	start "%BUILDER_THREADING_TITLE% - Building %_outTarget% x86" /D "%CD%" cmd /c "CALL build.bat %_pyTarget% , %_outTarget% , %_errorExpected% , x86 , %py32%\Scripts\pyinstaller.exe > %_outTarget%_%_arch%.log 2>&1"
	start "%BUILDER_THREADING_TITLE% - Building %_outTarget% x64" /D "%CD%" cmd /c "CALL build.bat %_pyTarget% , %_outTarget% , %_errorExpected% , x64 , %py64%\Scripts\pyinstaller.exe > %_outTarget%_%_arch%.log 2>&1"
) ELSE (
	CALL :Build_arch %_pyTarget% , %_outTarget% , %_errorExpected% , x86 , %py32%\Scripts\pyinstaller.exe
	CALL :Build_arch %_pyTarget% , %_outTarget% , %_errorExpected% , x64 , %py64%\Scripts\pyinstaller.exe
)
EXIT /B 0


:: #############################################################################
:: @brief Build bin
:: @param python script to build
:: @param prefix for the exe name
:: @param arch: x64 / x86
:: @param pyinstaller to use
:: @param Error code expected
:Build_arch
	echo [105;93m===========================================================================[0m
	SET _pyTarget=%~1
	SET _outTarget=%~2
	SET _errorExpected=%~3
	SET _arch=%~4
	SET _pyinstaller=%~5
:Build_arch_main
	CALL log.bat "Building %_outTarget%_%_arch%.exe"

	%_pyinstaller% --key=%pykey% --icon=%scriptpath%\pytools.ico --onefile %_pyTarget%.py
	IF NOT EXIST "dist\%_pyTarget%.exe" appveyor AddMessage "[%date% %time%] Build %_outTarget%_%_arch%.exe FAIL" -Category Error
	dist\%_pyTarget%.exe -h
	IF "%ERRORLEVEL%" == "%_errorExpected%" (
		appveyor AddMessage "[%date% %time%] Build %_outTarget%_%_arch%.exe OK" -Category Information
		CALL log.bat "✅ Build %_outTarget%_%_arch%.exe OK"
		copy dist\%_pyTarget%.exe %scriptpath%\bin\%_outTarget%_%_arch%.exe
		CALL log.bat "Trying to use %_outTarget%.lst7z"
		IF EXIST "%_outTarget%.lst7z" (
			CALL log.bat "Using %_outTarget%.lst7z"
			type %_outTarget%.lst7z > %_outTarget%_%_arch%.lst7z
		)
		echo %scriptpath%\bin\%_outTarget%_%_arch%.exe >> %_outTarget%_%_arch%.lst7z
		CALL log.bat "Create %_outTarget%_%_arch%.7z with required files..."
		7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\%_outTarget%_%_arch%.7z @%_outTarget%_%_arch%.lst7z
		appveyor PushArtifact %_7Z_OUPUT_%\%_outTarget%_%_arch%.7z
	) ELSE (
		CALL log.bat ERR "Build %_outTarget%_%_arch%.exe FAIL with %ERRORLEVEL%"
		appveyor AddMessage "[%date% %time%] Running %_outTarget%_%_arch%.exe FAIL with %ERRORLEVEL%" -Category Error
		IF "%%_outTarget%_%_arch%_retry%" == "1" (
			appveyor PushArtifact %_outTarget%_%_arch%.log
			EXIT /B 0
		)
		SET %_outTarget%_%_arch%_retry=1
		GOTO :Build_arch_main
	)
	EXIT /B 0

:EOF