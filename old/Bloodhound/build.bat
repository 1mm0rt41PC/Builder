CALL log.bat "Building Bloodhound"
git clone https://github.com/1mm0rt41PC/BloodHound --depth 1
cd BloodHound

CALL log.bat "Building Bloodhound: Adjust Collectors"
:: Adjust Collectors
rmdir /q /s Collectors\DebugBuilds
mv Collectors ..\
:: Copy Collectors
xcopy %scriptpath%\bin\certipy_x64.exe ..\Collectors\
xcopy %scriptpath%\bin\bloodhound_x64.exe ..\Collectors\
xcopy %scriptpath%\bin\Certify.exe ..\Collectors\
xcopy %scriptpath%\bin\rusthound.exe ..\Collectors\

CALL log.bat "Building Bloodhound: Packaging"
CALL npm config set audit false --location=global
CALL npm config set fund false --location=global
CALL npm install -g electron-packager
CALL npm install
SET NODE_OPTIONS=--openssl-legacy-provider
setx NODE_OPTIONS --openssl-legacy-provider
setx /M NODE_OPTIONS --openssl-legacy-provider
::npm run build:win32 --arch=x64
CALL npm run compile
CALL npm run package -- --platform=linux,win32 --arch=x64 --icon=src/img/icon.ico

:: Download custom queries
curl -L -k https://github.com/1mm0rt41PC/BloodHoundQueries/raw/master/customqueries.json --output customqueries.json

CALL log.bat "Building Bloodhound: Neo4j"
:: Download Neo4J with preconfiguration
curl.exe -k -L https://neo4j.com/artifact.php?name=neo4j-community-5.9.0-windows.zip --output neo4j.zip
7z x neo4j.zip
powershell -exec bypass -nop -Command "$neo4j = cat .\neo4j-community-*\conf\neo4j.conf ; if( $neo4j.Contains('#dbms.security.auth_enabled=false') ){ $neo4j.replace('#dbms.security.auth_enabled=false','dbms.security.auth_enabled=false') | Out-File -Encoding ASCII .\neo4j-community-*\conf\neo4j.conf ; }; mv neo4j-community-* neo4j-community"

type %scriptpath%\Bloodhound\run.bat > run.bat

CALL log.bat "Building Bloodhound: JDK"
curl.exe -k -L https://download.java.net/java/GA/jdk20.0.1/b4887098932d415489976708ad6d1a4b/9/GPL/openjdk-20.0.1_windows-x64_bin.zip --output jdk.zip
7z x jdk.zip
powershell -exec bypass -nop -Command "mv jdk-20.0.1 jdk"

CALL log.bat "Building Bloodhound: 7z"
7z a -t7z -mhe -p%_7Z_PASSWORD_% %_7Z_OUPUT_%\BloodHound-UI.7z BloodHound-win32-x64 BloodHound-linux-x64 customqueries.json ..\Collectors neo4j-community jdk run.bat
appveyor PushArtifact %_7Z_OUPUT_%\BloodHound-UI.7z
