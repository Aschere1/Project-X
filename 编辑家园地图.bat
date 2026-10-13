@echo off
setlocal
for %%I in ("%~dp0.") do set "PROJECT_DIR=%%~fI"
set "GODOT_EXE=%GODOT_EXE%"
if not defined GODOT_EXE if exist "%PROJECT_DIR%\tools\godot\Godot.exe" set "GODOT_EXE=%PROJECT_DIR%\tools\godot\Godot.exe"
if not defined GODOT_EXE if exist "%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64.exe" set "GODOT_EXE=%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64.exe"
if not defined GODOT_EXE if exist "%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64_console.exe" set "GODOT_EXE=%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64_console.exe"
if not defined GODOT_EXE if exist "D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe" set "GODOT_EXE=D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe"
if not defined GODOT_EXE for /f "delims=" %%G in ('where godot 2^>nul') do if not defined GODOT_EXE set "GODOT_EXE=%%G"
set "MAP_SCENE=res://scenes/world/home_region.tscn"
set "MAP_FILE=%PROJECT_DIR%\scenes\world\home_region.tscn"

if not defined GODOT_EXE (
    echo Cannot find Godot 4.7.1. Keep Godot.exe in tools\godot\ or set GODOT_EXE.
    pause
    exit /b 1
)

if not exist "%GODOT_EXE%" (
    echo Cannot find Godot: "%GODOT_EXE%"
    pause
    exit /b 1
)

if not exist "%MAP_FILE%" (
    echo Cannot find the complete editable home scene:
    echo %MAP_FILE%
    pause
    exit /b 1
)

start "Project X - Home Map Editor" "%GODOT_EXE%" --editor --path "%PROJECT_DIR%" "%MAP_SCENE%"
endlocal
