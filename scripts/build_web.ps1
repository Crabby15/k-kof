param(
    [string]$BaseHref = "/jasa-dekat/"
)

$ErrorActionPreference = "Stop"
$Flutter = Join-Path $PSScriptRoot "..\flutter\bin\flutter.bat"
if (-not (Test-Path $Flutter)) {
    $Flutter = "flutter"
}

& $Flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $Flutter build web --release --base-href $BaseHref
exit $LASTEXITCODE
