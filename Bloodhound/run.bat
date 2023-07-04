SET mypath=%~dp0
SET mypath=%mypath:~0,-1%
start BloodHound-win32-x64\BloodHound.exe
set JAVA_HOME=%mypath%\jdk
.\neo4j-community\bin\neo4j.bat console
