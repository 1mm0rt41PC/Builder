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
SET _pyExe=%~5

IF "%_arch%" NEQ "" (
	GOTO :Build_arch_main
	EXIT /B 0
)

IF "%BUILDER_THREADING%" == "1" (
	CALL sync-thread.bat
	IF "%ENABLE_BUILD_X86%" == "1" (
		CALL log.bat "Running thread for %_outTarget% x86"
		start "%BUILDER_THREADING_TITLE% - Building %_outTarget% x86" /D "%CD%" cmd /c "CALL build-py.bat %_pyTarget% , %_outTarget% , %_errorExpected% , x86 , %py32% > %scriptpath%\bin\%_outTarget%_x86.log 2>&1"
	)
	CALL sync-thread.bat
	CALL log.bat "Running thread for %_outTarget% x64"
	start "%BUILDER_THREADING_TITLE% - Building %_outTarget% x64" /D "%CD%" cmd /c "CALL build-py.bat %_pyTarget% , %_outTarget% , %_errorExpected% , x64 , %py64% > %scriptpath%\bin\%_outTarget%_x64.log 2>&1"
) ELSE (
	IF "%ENABLE_BUILD_X86%" == "1" (
		CALL :Build_arch %_pyTarget% , %_outTarget% , %_errorExpected% , x86 , %py32%
	)
	CALL :Build_arch %_pyTarget% , %_outTarget% , %_errorExpected% , x64 , %py64%
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
	SET _pyExe=%~5
:Build_arch_main
	CALL log.bat "Building %_outTarget%_%_arch%.exe ..."

	%_pyExe% %PYTHONOPTIMIZE_FLAG% -m PyInstaller --key=%pykey% --icon=%scriptpath%\pytools.ico --onefile %_pyTarget%.py --name %_outTarget%_%_arch% --noupx
	IF NOT EXIST "dist\%_outTarget%_%_arch%.exe" CALL log.bat ERR "Build %_outTarget%_%_arch%.exe FAIL" 1
	dist\%_outTarget%_%_arch%.exe -h
	set _err=%ERRORLEVEL%
	IF "%_err%" == "%_errorExpected%" (
		CALL log.bat "✅ Build %_outTarget%_%_arch%.exe OK" , 1
		copy dist\%_outTarget%_%_arch%.exe %scriptpath%\bin\%_outTarget%_%_arch%.exe
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
		IF "%retry%" == "1" (
			SET retry="0"
			CALL log.bat ERR "FAIL to build a valid %_outTarget%_%_arch%.exe (This bin return %_err%, expected %_errorExpected%)..." , 1
			IF EXIST %scriptpath%\bin\%_outTarget%_%_arch%.log appveyor PushArtifact %scriptpath%\bin\%_outTarget%_%_arch%.log
			EXIT /B 0
		)
		CALL log.bat WARN , "Build %_outTarget%_%_arch%.exe FAIL with %_err%, Retrying..." , 1
		
		SET retry=1
		GOTO :Build_arch_main
		EXIT /B 0
	)
	EXIT /B 0

:EOF