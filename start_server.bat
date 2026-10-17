@echo off
setlocal
echo ===================================================
echo     INTERNSHIP MANAGEMENT SYSTEM - AUTO START
echo ===================================================

if "%PROJECT_DIR%"=="" set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

cd /d "%PROJECT_DIR%"

:: 0. Kiem tra file cau hinh db.properties
if not exist "src\main\resources\db.properties" (
    if exist "src\main\resources\db.properties.example" (
        echo [INFO] Tao src\main\resources\db.properties tu db.properties.example...
        copy "src\main\resources\db.properties.example" "src\main\resources\db.properties" >nul
    )
)

:: 1. Tu dong tim JAVA_HOME
if "%JAVA_HOME%"=="" (
    if exist "C:\Program Files\Java\jdk-24" set "JAVA_HOME=C:\Program Files\Java\jdk-24"
    if exist "C:\Program Files\Java\jdk-21" set "JAVA_HOME=C:\Program Files\Java\jdk-21"
    if exist "C:\Program Files\Java\jdk-17" set "JAVA_HOME=C:\Program Files\Java\jdk-17"
)

:: 2. Tu dong tim TOMCAT_HOME
if "%TOMCAT_HOME%"=="" (
    if exist "E:\tools\apache-tomcat-10.1.60" set "TOMCAT_HOME=E:\tools\apache-tomcat-10.1.60"
    if exist "C:\tools\apache-tomcat-10.1.60" set "TOMCAT_HOME=C:\tools\apache-tomcat-10.1.60"
    if exist "C:\apache-tomcat-10.1.60" set "TOMCAT_HOME=C:\apache-tomcat-10.1.60"
)

:: 3. Tu dong tim MAVEN_BIN
if "%MAVEN_BIN%"=="" (
    if exist "E:\tools\apache-maven-3.9.9\bin\mvn.cmd" set "MAVEN_BIN=E:\tools\apache-maven-3.9.9\bin\mvn.cmd"
    if exist "C:\tools\apache-maven-3.9.9\bin\mvn.cmd" set "MAVEN_BIN=C:\tools\apache-maven-3.9.9\bin\mvn.cmd"
    if "%MAVEN_BIN%"=="" set "MAVEN_BIN=mvn"
)

echo [1/4] Kiem tra MySQL...
netstat -ano | findstr :3306 >nul
if errorlevel 1 (
    echo Dang khoi dong MySQL (XAMPP)...
    if exist "C:\xampp\mysql\bin\mysqld.exe" (
        start /B "" "C:\xampp\mysql\bin\mysqld.exe" --defaults-file="C:\xampp\mysql\bin\my.ini" --standalone
        timeout /t 2 >nul
    ) else (
        echo [CANH BAO] Khong tim thay mysqld.exe tai C:\xampp. Vui long khoi dong MySQL qua XAMPP Control Panel.
    )
) else (
    echo MySQL dang hoat dong (port 3306).
)

echo [2/4] Build & Package du an bang Maven...
call "%MAVEN_BIN%" package -DskipTests
if errorlevel 1 (
    echo [LOI] Maven package that bai. Vui long kiem tra JDK hoac loi code.
    pause
    exit /b %errorlevel%
)

echo [3/4] Deploy file WAR vao Tomcat...
if not "%TOMCAT_HOME%"=="" (
    copy /Y "%PROJECT_DIR%\target\internship-management-system.war" "%TOMCAT_HOME%\webapps\" >nul
    echo [4/4] Khoi dong Apache Tomcat...
    echo -------------------------------------------------------------------
    echo HE THONG SAN SANG TAI:
    echo http://localhost:8080/internship-management-system/
    echo -------------------------------------------------------------------
    call "%TOMCAT_HOME%\bin\catalina.bat" run
) else (
    echo File WAR da duoc dong goi tai: %PROJECT_DIR%\target\internship-management-system.war
    echo [HUONG DAN] Copy file WAR nay vao thu muc webapps cua Tomcat va khoi dong.
)

endlocal
