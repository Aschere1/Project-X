@echo off
setlocal
cd /d "%~dp0"

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run_godot.ps1" --path "%~dp0." %*
set "launch_exit=%ERRORLEVEL%"

if not "%launch_exit%"=="0" (
    echo.
    echo Game could not start. Install Godot 4.7.1, set GODOT_EXE, or place it in tools\godot\.
    pause
)

exit /b %launch_exit%
