param([switch] $PublicReview)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$godotCandidates = @(
	$env:GODOT_EXE,
	(Join-Path $projectRoot 'tools\godot\Godot.exe'),
	(Join-Path $projectRoot 'tools\godot\godot.exe'),
	(Join-Path $projectRoot 'Godot.exe'),
	'D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe'
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
$godotExe = $godotCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
$profileRoot = Join-Path $projectRoot 'tmp\godot_profile'

if ([string]::IsNullOrWhiteSpace($godotExe)) {
	throw "Godot executable not found. Checked: $($godotCandidates -join '; ')"
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

$testRunnerPath = Join-Path $projectRoot 'tests\test_runner.gd'
if ($PublicReview) {
	$testRunnerPath = Join-Path $projectRoot 'tests\test_public_review_runner.gd'
}
$logRoot = Join-Path $projectRoot 'tmp\godot_logs'
if (-not (Test-Path -LiteralPath $logRoot)) {
	New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
}
$runId = [Guid]::NewGuid().ToString('N')
$stdoutPath = Join-Path $logRoot ("tests_" + $runId + '.stdout.log')
$stderrPath = Join-Path $logRoot ("tests_" + $runId + '.stderr.log')
$testArguments = @('--headless', '--path', ('"{0}"' -f $projectRoot), '--script', ('"{0}"' -f $testRunnerPath))
$startInfo = [System.Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = $godotExe
$startInfo.WorkingDirectory = $projectRoot
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$startInfo.Arguments = $testArguments -join ' '
$testRun = [System.Diagnostics.Process]::new()
$testRun.StartInfo = $startInfo
[void]$testRun.Start()
$stdoutTask = $testRun.StandardOutput.ReadToEndAsync()
$stderrTask = $testRun.StandardError.ReadToEndAsync()
$testRun.WaitForExit()
$testOutput = $stdoutTask.GetAwaiter().GetResult()
$testError = $stderrTask.GetAwaiter().GetResult()
$testRunExitCode = $testRun.ExitCode
Set-Content -LiteralPath $stdoutPath -Value $testOutput -Encoding utf8
Set-Content -LiteralPath $stderrPath -Value $testError -Encoding utf8
$testOutput += "`n" + $testError
Write-Output $testOutput

if ($testOutput -match 'TESTS_PASSED' -and $testOutput -notmatch 'TESTS_FAILED') {
	exit 0
}

if ([string]::IsNullOrWhiteSpace($testOutput)) {
	throw "Godot test run produced no output (exit code $testRunExitCode)."
}

exit 1
