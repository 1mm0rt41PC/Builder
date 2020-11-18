IF "%~1" == "ERR" (
	echo [101;93m[%date% %time%] %~2[0m
	IF "%~3" NEQ "" appveyor AddMessage "[%date% %time%] %~2" -Category Error
	EXIT /B 0
)

IF "%~1" == "WARN" (
	echo [101;93m[%date% %time%] %~2[0m
	IF "%~3" NEQ "" appveyor AddMessage "[%date% %time%] %~2" -Category Warning
	EXIT /B 0
)

echo [105;93m[%date% %time%] %~1[0m
IF "%~2" NEQ "" appveyor AddMessage "[%date% %time%] %~1" -Category Information
EXIT /B 0