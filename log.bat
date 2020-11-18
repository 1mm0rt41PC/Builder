IF "%~1" == "ERR" (
	echo [101;93m[%date% %time%] %~2[0m
) ELSE (
	echo [105;93m[%date% %time%] %~1[0m
)
EXIT /B 0