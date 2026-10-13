@echo off
setlocal
for %%I in ("%~dp0.") do set "PROJECT_DIR=%%~fI"
set "GODOT_EXE=%GODOT_EXE%"
if not defined GODOT_EXE if exist "%PROJECT_DIR%\tools\godot\Godot.exe" set "GODOT_EXE=%PROJECT_DIR%\tools\godot\Godot.exe"
if not defined GODOT_EXE if exist "%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64.exe" set "GODOT_EXE=%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64.exe"
if not defined GODOT_EXE if exist "%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64_console.exe" set "GODOT_EXE=%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64_console.exe"
if not defined GODOT_EXE if exist "D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe" set "GODOT_EXE=D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe"
if not defined GODOT_EXE for /f "delims=" %%G in ('where godot 2^>nul') do if not defined GODOT_EXE set "GODOT_EXE=%%G"
set "MAP_SCENE=res://scenes/world/apocalypse_shelter.tscn"
set "MAP_FILE=%PROJECT_DIR%\scenes\world\apocalypse_shelter.tscn"
set "LAYOUT_FILE=%PROJECT_DIR%\.godot\editor\editor_layout.cfg"

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
    echo Cannot find the editable apocalypse shelter scene:
    echo %MAP_FILE%
    pause
    exit /b 1
)

rem Erase any editor session memory that would reopen the old home_region tabs.
rem If the layout file exists, rewrite its EditorNode section so the current + open
rem scenes always point at the apocalypse shelter instead of the old ranch.
if exist "%LAYOUT_FILE%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "$p = '%LAYOUT_FILE%';" ^
      "$t = Get-Content -LiteralPath $p -Raw;" ^
      "$t = [regex]::Replace($t, '(?m)^open_scenes=PackedStringArray\([^)]*\)', 'open_scenes=PackedStringArray(\"res://scenes/world/apocalypse_shelter.tscn\")');" ^
      "$t = [regex]::Replace($t, '(?m)^current_scene=.*$', 'current_scene=\"res://scenes/world/apocalypse_shelter.tscn\"');" ^
      "[System.IO.File]::WriteAllText($p, $t, [System.Text.UTF8Encoding]::new(`$false));"
)

start "Project X - Apocalypse Shelter Editor" "%GODOT_EXE%" --editor --path "%PROJECT_DIR%" --scene "%MAP_SCENE%"
endlocal
