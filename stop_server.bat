@echo off
setlocal
echo ===================================================
echo     INTERNSHIP MANAGEMENT SYSTEM - STOP SCRIPT
echo ===================================================

if "%JAVA_HOME%"=="" (
    if exist "C:\Program Files\Java\jdk-24" set "JAVA_HOME=C:\Program Files\Java\jdk-24"
    if exist "C:\Program Files\Java\jdk-21" set "JAVA_HOME=C:\Program Files\Java\jdk-21"
    if exist "C:\Program Files\Java\jdk-17" set "JAVA_HOME=C:\Program Files\Java\jdk-17"
)

if "%TOMCAT_HOME%"=="" (
    if exist "E:\tools\apache-tomcat-10.1.60" set "TOMCAT_HOME=E:\tools\apache-tomcat-10.1.60"
    if exist "C:\tools\apache-tomcat-10.1.60" set "TOMCAT_HOME=C:\tools\apache-tomcat-10.1.60"
    if exist "C:\apache-tomcat-10.1.60" set "TOMCAT_HOME=C:\apache-tomcat-10.1.60"
)

if not "%TOMCAT_HOME%"=="" (
    echo Dang dung Apache Tomcat...
    call "%TOMCAT_HOME%\bin\catalina.bat" stop
    echo Apache Tomcat da dung.
) else (
    echo [THONG BAO] Chua tim thay TOMCAT_HOME. Ban co the dong cua so console Tomcat.
)

endlocal
