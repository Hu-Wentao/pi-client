param(
  [Parameter(Mandatory = $true)]
  [string[]] $Path
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($env:WINDOWS_SIGNING_CERTIFICATE_BASE64) -or
    [string]::IsNullOrWhiteSpace($env:WINDOWS_SIGNING_CERTIFICATE_PASSWORD)) {
  throw 'Windows signing credentials are required.'
}

$temporary = Join-Path $env:RUNNER_TEMP "pi-client-signing-$PID.pfx"
try {
  [IO.File]::WriteAllBytes($temporary, [Convert]::FromBase64String($env:WINDOWS_SIGNING_CERTIFICATE_BASE64))
  $signtoolCommand = Get-Command signtool.exe -ErrorAction SilentlyContinue
  if ($signtoolCommand) {
    $signtool = $signtoolCommand.Source
  } else {
    $kitsRoot = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
    $signtool = Get-ChildItem -LiteralPath $kitsRoot -Filter signtool.exe -File -Recurse |
      Where-Object { $_.DirectoryName -match '\\x64$' } |
      Sort-Object FullName -Descending |
      Select-Object -First 1 -ExpandProperty FullName
    if (-not $signtool) { throw 'signtool.exe is unavailable.' }
  }
  foreach ($item in $Path) {
    & $signtool sign /fd SHA256 /td SHA256 /tr https://timestamp.digicert.com /f $temporary /p $env:WINDOWS_SIGNING_CERTIFICATE_PASSWORD $item
    if ($LASTEXITCODE -ne 0) { throw "signtool sign failed for $item" }
    & $signtool verify /pa /all $item
    if ($LASTEXITCODE -ne 0) { throw "signtool verify failed for $item" }
  }
} finally {
  Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue
}
