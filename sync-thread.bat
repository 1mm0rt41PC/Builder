SET MAX_THREAD=%~1
IF "%MAX_THREAD%" == "" SET MAX_THREAD=%BUILDER_NB_THREAD%

:: Sync threading
IF "%BUILDER_THREADING%" == "1" (
	CALL log.bat "Waiting thread..."
	powershell -exec bypass -nop -Command "Get-Process -Name cmd | Where-Object { $_.MainWindowTitle -like '*%BUILDER_THREADING_TITLE%*' } | select MainWindowTitle"
	powershell -exec bypass -nop -Command "while ( (Get-Process -Name cmd | Where-Object { $_.MainWindowTitle -like '*%BUILDER_THREADING_TITLE%*' }).Count -gt %MAX_THREAD% ){ Write-Host "Waiting for threads"; Get-Process -Name cmd | Where-Object { $_.MainWindowTitle -like '*%BUILDER_THREADING_TITLE%*' } | select MainWindowTitle; sleep -Seconds 5 }"
)
EXIT /B 0