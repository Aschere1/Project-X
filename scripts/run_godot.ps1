param(
	[string] $GodotPath = '',
	[Parameter(ValueFromRemainingArguments = $true)]
	[string[]] $GodotArguments
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$logRoot = Join-Path $projectRoot 'tmp\godot_logs'
$profileRoot = Join-Path $projectRoot 'tmp\godot_profile'

$godotCandidates = @()
if (-not [string]::IsNullOrWhiteSpace($GodotPath)) {
	$godotCandidates += $GodotPath
}
if (-not [string]::IsNullOrWhiteSpace($env:GODOT_EXE)) {
	$godotCandidates += $env:GODOT_EXE
}
$godotCandidates += @(
	(Join-Path $projectRoot 'tools\godot\Godot.exe'),
	(Join-Path $projectRoot 'tools\godot\Godot_v4.7.1-stable_win64.exe'),
	(Join-Path $projectRoot 'tools\godot\Godot_v4.7.1-stable_win64_console.exe'),
	(Join-Path $projectRoot 'Godot.exe'),
	(Join-Path $projectRoot 'Godot_v4.7.1-stable_win64.exe'),
	'D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe'
)

$godotExe = $null
foreach ($candidate in $godotCandidates) {
	if (-not [string]::IsNullOrWhiteSpace($candidate) -and (Test-Path -LiteralPath $candidate)) {
		$godotExe = (Resolve-Path -LiteralPath $candidate).Path
		break
	}
}
if ($null -eq $godotExe) {
	$godotCommand = Get-Command godot -ErrorAction SilentlyContinue
	if ($null -ne $godotCommand) {
		$godotExe = $godotCommand.Source
	}
}

if ($null -eq $godotExe) {
	throw "Godot 4.7.1 executable not found. Set GODOT_EXE or pass -GodotPath, or place Godot at tools\godot\Godot.exe (recommended) or tools\godot\Godot_v4.7.1-stable_win64.exe."
}

$env:APPDATA = Join-Path $profileRoot 'AppData\Roaming'
$env:LOCALAPPDATA = Join-Path $profileRoot 'AppData\Local'
$env:TEMP = Join-Path $profileRoot 'Temp'
$env:TMP = $env:TEMP

foreach ($directory in @($env:APPDATA, $env:LOCALAPPDATA, $env:TEMP)) {
	if (-not (Test-Path -LiteralPath $directory)) {
		New-Item -ItemType Directory -Path $directory -Force | Out-Null
	}
}

if (-not (Test-Path -LiteralPath $logRoot)) {
	New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
}

# Godot 4.7.1 can crash while rotating the shared user://logs file when more
# than one editor/game process uses the same portable profile. Give each launch
# its own log file unless the caller explicitly supplied --log-file.
if ($GodotArguments -notcontains '--log-file') {
	$launchLog = Join-Path $logRoot ("godot_" + [Guid]::NewGuid().ToString('N') + '.log')
	$GodotArguments += @('--log-file', $launchLog)
}

& $godotExe @GodotArguments
exit $LASTEXITCODE
