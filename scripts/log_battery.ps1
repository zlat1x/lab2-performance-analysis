# Windows PowerShell 5.1+; run on a laptop's Windows host while on battery.
# Records the WMI BatteryStatus class once a second (approximately).
# Example:
#   powershell -NoProfile -File scripts/log_battery.ps1 -DurationSeconds 600

param(
    [ValidateRange(1, 86400)]
    [int]$DurationSeconds = 600,
    [string]$OutputDirectory = (Join-Path (Split-Path -Parent $PSScriptRoot) 'data')
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$path = Join-Path $OutputDirectory "energy_$stamp.csv"
if (Test-Path -LiteralPath $path) {
    throw "Output already exists: $path"
}

Write-Host "Battery recording started: $path"
$timer = [System.Diagnostics.Stopwatch]::StartNew()
$first = $true

try {
    while ($timer.Elapsed.TotalSeconds -lt $DurationSeconds) {
        $battery = Get-CimInstance -Namespace 'root\wmi' -ClassName 'BatteryStatus' |
            Select-Object -First 1
        if ($null -eq $battery) {
            throw 'BatteryStatus is unavailable on this machine.'
        }
        $sample = [pscustomobject]@{
            timestamp_utc = [datetime]::UtcNow.ToString('o')
            remaining_mwh = $battery.RemainingCapacity
            discharge_mw = $battery.DischargeRate
            online = $battery.PowerOnline
        }
        if ($first) {
            $sample | Export-Csv -LiteralPath $path -NoTypeInformation
            $first = $false
        }
        else {
            $sample | Export-Csv -LiteralPath $path -NoTypeInformation -Append
        }
        Start-Sleep -Seconds 1
    }
}
finally {
    $timer.Stop()
    Write-Host "Battery recording finished: $path"
}
