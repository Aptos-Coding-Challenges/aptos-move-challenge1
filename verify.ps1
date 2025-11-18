[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$AptosArgs = @()
)

$TestFile = "tests/my_first_nft_tests.move"
$ExpectedHash = "dd30c64ba905c08ac59666471c4e8da340abebd219ca2a0f8cd337dc9de18302"

if (-not (Test-Path -LiteralPath $TestFile)) {
    Write-Error "Test file '$TestFile' not found"
    exit 1
}

try {
    $ActualHash = (Get-FileHash -Path $TestFile -Algorithm SHA256).Hash.ToLowerInvariant()
} catch {
    Write-Error "Failed to compute file hash: $_"
    exit 1
}

if ($ActualHash -ne $ExpectedHash) {
    Write-Error @"
Test file hash mismatch.
  expected: $ExpectedHash
  actual:   $ActualHash
Please revert changes under $TestFile before running the tests.
"@
    exit 1
}

Write-Host "Test file hash verified ($ActualHash)." -ForegroundColor Green

if (-not (Get-Command aptos -ErrorAction SilentlyContinue)) {
    Write-Error "aptos CLI not found on PATH. Install it before running this script."
    exit 1
}

$arguments = @("move", "test") + $AptosArgs
Write-Host "+ aptos $($arguments -join ' ')" -ForegroundColor Cyan

$process = Start-Process -FilePath aptos -ArgumentList $arguments -NoNewWindow -Wait -PassThru
exit $process.ExitCode
