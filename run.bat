@echo off
setlocal

rem Usage: run.bat "C:\path\to\MyApp.exe" [application arguments...]
rem Requires CDB (Debugging Tools for Windows) on PATH and matching PDB files.

if "%~1"=="" (
    echo Usage: %~nx0 "C:\path\to\MyApp.exe" [application arguments...]
    exit /b 2
)

where cdb.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: cdb.exe was not found on PATH. Install Debugging Tools for Windows or add its directory to PATH.
    exit /b 3
)

pushd "%~dp0"
cdb.exe -logo "%~dp0debug.log" -cf "%~dp0capture.dbg" %*
set "debuggerExitCode=%ERRORLEVEL%"
popd

exit /b %debuggerExitCode%