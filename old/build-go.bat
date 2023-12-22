CALL config.bat
CALL pre-install.bat
:: #############################################################################
:: @brief Build bin in amd64 and in 386
:: @param prefix for the exe name
:: @param Error code expected
:: @param OS: linux / windows
:: @param Arch: amd64 / 386
SET _outTarget=%~1
SET _errorExpected=%~2
SET _OS=%~3
SET _arch=%~4

IF "%_OS%" NEQ "" (
	GOTO :Build_arch_main
	EXIT /B 0
)

IF "%BUILDER_THREADING%" == "1" (
	CALL sync-thread.bat
	IF "%ENABLE_BUILD_X86%" == "1" (
		CALL log.bat "Running thread for %_outTarget% for windows 386"
		start "%BUILDER_THREADING_TITLE% - Building %_outTarget% for windows 386" /D "%CD%" cmd /c "CALL build-go.bat %_outTarget% , %_errorExpected% , windows , 386 > %_outTarget%_windows_386.log 2>&1"
		CALL sync-thread.bat
	)
	CALL log.bat "Running thread for %_outTarget% for windows amd64"
	start "%BUILDER_THREADING_TITLE% - Building %_outTarget% for windows amd64" /D "%CD%" cmd /c "CALL build-go.bat %_outTarget% , %_errorExpected% , windows , amd64 > %_outTarget%_windows_amd64.log 2>&1"
	CALL sync-thread.bat
	IF "%ENABLE_BUILD_X86%" == "1" (
		CALL log.bat "Running thread for %_outTarget% for linux 386"
		start "%BUILDER_THREADING_TITLE% - Building %_outTarget% for linux 386" /D "%CD%" cmd /c "CALL build-go.bat %_outTarget% , %_errorExpected% , linux , 386 > %_outTarget%_linux_386.log 2>&1"
		CALL sync-thread.bat
	)
	CALL log.bat "Running thread for %_outTarget% for linux amd64"
	start "%BUILDER_THREADING_TITLE% - Building %_outTarget% for linux amd64" /D "%CD%" cmd /c "CALL build-go.bat %_outTarget% , %_errorExpected% , linux , amd64 > %_outTarget%_linux_amd64.log 2>&1"
) ELSE (
	IF "%ENABLE_BUILD_X86%" == "1" (
		CALL :Build_arch %_outTarget% , %_errorExpected% , windows , 386
	)
	CALL :Build_arch %_outTarget% , %_errorExpected% , windows , amd64
	IF "%ENABLE_BUILD_X86%" == "1" (
		CALL :Build_arch %_outTarget% , %_errorExpected% , linux , 386
	)
	CALL :Build_arch %_outTarget% , %_errorExpected% , linux , amd64
)
EXIT /B 0



:: #############################################################################
:: @brief Build bin
:: @param prefix for the exe name
:: @param Error code expected
:: @param OS: linux / windows
:: @param Arch: amd64 / 386
:Build_arch
	echo [105;93m===========================================================================[0m
	SET _outTarget=%~1
	SET _errorExpected=%~2
	SET _OS=%~3
	SET _arch=%~4
:Build_arch_main
	SET _FullnameOutput=%_outTarget%_%_OS%_%_arch%
	SET GOOS=%_OS%
	SET GOARCH=%_arch%
	CALL log.bat "Building %_FullnameOutput%.exe ..."

	IF NOT EXIST %_outTarget%.syso (
		%rsrc% -ico %scriptpath%\pytools.ico -o %_outTarget%.syso
	)
	go build -o %_FullnameOutput%.exe -v
	IF NOT EXIST "%_FullnameOutput%.exe" CALL log.bat ERR "Build %_FullnameOutput%.exe FAIL" 1
	:: Auto kill after 10 seconds
	start "TEST RUNNER %_FullnameOutput%.exe" /D "%CD%" cmd /C "ping -n 10 127.0.0.1 & taskkill /F /IM %_FullnameOutput%.exe & EXIT /B 0"
	%_FullnameOutput%.exe -h
	set _err=%ERRORLEVEL%
	IF "%_err%" == "%_errorExpected%" (
		CALL log.bat "✅ Build %_FullnameOutput%.exe OK" 1
		copy %_FullnameOutput%.exe %scriptpath%\bin\%_FullnameOutput%.exe
		CALL log.bat "Trying to use %_outTarget%.lst7z"
		IF EXIST "%_outTarget%.lst7z" (
			CALL log.bat "Using %_outTarget%.lst7z"
			type %_outTarget%.lst7z > %_FullnameOutput%.lst7z
		)
		echo %scriptpath%\bin\%_FullnameOutput%.exe >> %_FullnameOutput%.lst7z
		CALL log.bat "Create %_FullnameOutput%.7z with required files..."
		7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\%_FullnameOutput%.7z @%_FullnameOutput%.lst7z
		appveyor PushArtifact %_7Z_OUPUT_%\%_FullnameOutput%.7z
	) ELSE (
		IF "%%_FullnameOutput%_retry%" == "1" (
			CALL log.bat ERR "FAIL to build a valid %_FullnameOutput%.exe (This bin return %_err%, expected %_errorExpected%)..." 1
			IF "%BUILDER_THREADING%" == "1" appveyor PushArtifact %_FullnameOutput%.log
			EXIT /B 0
		)
		CALL log.bat WARN "Build %_FullnameOutput%.exe FAIL with %_err%, Retrying..." 1
		SET %_FullnameOutput%_retry=1
		GOTO :Build_arch_main
		EXIT /B 0
	)
	EXIT /B 0

:EOF