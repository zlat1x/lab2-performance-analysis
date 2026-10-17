# PowerShell 5.1+ / Windows host battery analysis.
# Usage from the repository root:
#   powershell -NoProfile -File scripts/analyze_energy.ps1
# Or supply an explicit path:
#   powershell -NoProfile -File scripts/analyze_energy.ps1 -CsvPath D:\\Downloads\\Lab2Transfer\\energy_final_20261017_175644.csv
#
# The battery DischargeRate describes the complete laptop, including the Kali
# virtual machine. The "program" value is a baseline-subtracted estimate,
# NOT a direct per-process measurement.

param(
    [string]$CsvPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'data/energy_final_20261017_175644.csv')
)

$ErrorActionPreference = 'Stop'
$rows = Import-Csv -LiteralPath $CsvPath

function Get-MeanPowerW([string]$From, [string]$To) {
    $samples = @($rows | Where-Object {
        $t = $_.timestamp_utc.Substring(0, 19)
        $t -ge $From -and $t -lt $To
    })
    if ($samples.Count -eq 0) {
        throw "No battery samples between $From and $To"
    }
    return (($samples | Measure-Object -Property discharge_mw -Average).Average / 1000)
}

# Two settled minutes of idle power after the O3 program finishes.
$idle = Get-MeanPowerW '2026-10-17T15:04:43' '2026-10-17T15:06:43'

# Durations are from the actual Linux benchmark timing.
$tests = @(
    [pscustomobject]@{ Mode = 'O0'; Start = '2026-10-17T14:56:52'; End = '2026-10-17T15:02:40'; Seconds = 347.89 }
    [pscustomobject]@{ Mode = 'O3'; Start = '2026-10-17T15:02:40'; End = '2026-10-17T15:03:35'; Seconds = 55.16 }
)

Write-Host "Idle power: $([math]::Round($idle, 2)) W"

$tests | ForEach-Object {
    $p = Get-MeanPowerW $_.Start $_.End
    [pscustomobject]@{
        Mode = $_.Mode
        Time_s = $_.Seconds
        System_W = [math]::Round($p, 2)
        System_J = [math]::Round($p * $_.Seconds, 1)
        ProgramEstimate_J = [math]::Round(($p - $idle) * $_.Seconds, 1)
    }
} | Format-Table -AutoSize
