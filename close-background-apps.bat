@echo off
setlocal

set "SCRIPT=%~dp0close-background-apps.ps1"

if not exist "%SCRIPT%" (
    echo Missing script: "%SCRIPT%"
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" (
    echo Finished with errors. Exit code: %EXIT_CODE%
) else (
    echo Finished.
)

pause
exit /b %EXIT_CODE%
