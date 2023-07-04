git clone https://github.com/1mm0rt41PC/BloodHound --depth 1
cd BloodHound

:: Adjust Collectors
rmdir /q /s Collectors\DebugBuilds
mv Collectors ..\
:: Copy Collectors
xcopy %scriptpath%\bin\certipy_x64.exe ..\Collectors\
xcopy %scriptpath%\bin\bloodhound_x64.exe ..\Collectors\
xcopy %scriptpath%\bin\Certify.exe ..\Collectors\
xcopy %scriptpath%\bin\rusthound.exe ..\Collectors\

npm install -g electron-packager
npm install
SET NODE_OPTIONS=--openssl-legacy-provider
setx NODE_OPTIONS --openssl-legacy-provider
setx /M NODE_OPTIONS --openssl-legacy-provider
::npm run build:win32 --arch=x64
npm run compile
npm run package -- --platform=linux,win32 --arch=x64 --icon=src/img/icon.ico

:: Download custom queries
curl -L -k https://github.com/1mm0rt41PC/BloodHoundQueries/raw/master/customqueries.json --output customqueries.json

:: Download Neo4J with preconfiguration
curl.exe -k -L https://neo4j.com/artifact.php?name=neo4j-community-5.9.0-windows.zip --output neo4j.zip
7z x neo4j.zip
powershell -exec bypass -nop -Command "$neo4j = cat .\neo4j-community-*\conf\neo4j.conf ; if( $neo4j.Contains('#dbms.security.auth_enabled=false') ){ $neo4j.replace('#dbms.security.auth_enabled=false','dbms.security.auth_enabled=false') | Out-File -Encoding ASCII .\neo4j-community-*\conf\neo4j.conf ; }; mv neo4j-community-* neo4j-community"

type %scriptpath%\Bloodhound\run.bat > run.bat

7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\BloodHound-UI.7z BloodHound-win32-x64 BloodHound-linux-x64 customqueries.json ..\Collectors neo4j-community run.bat
appveyor PushArtifact %_7Z_OUPUT_%\BloodHound-UI.7z
