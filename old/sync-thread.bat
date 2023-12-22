SET MAX_THREAD=%~1
IF "%MAX_THREAD%" == "" SET MAX_THREAD=%BUILDER_NB_THREAD%

:: Sync threading
IF "%BUILDER_THREADING%" == "1" (
	CALL log.bat "Sync thread..."
	powershell -exec bypass -nop -Command "function th { Get-Process -Name cmd | Where-Object { $_.MainWindowTitle -like '*%BUILDER_THREADING_TITLE%*' } }; while ( (th).Count -gt %MAX_THREAD% ){ Write-Host -BackgroundColor Magenta "Waiting for threads"; th | select MainWindowTitle; sleep -Seconds 5 }"
)
EXIT /B 0