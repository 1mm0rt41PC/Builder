SET scriptpath=%~dp0
SET scriptpath=%scriptpath:~0,-1%

C:\Python310-x64\python.exe %scriptpath%\main.py %*
