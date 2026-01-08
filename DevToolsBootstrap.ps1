# ------------------------------------------------------------
# DevTools Bootstrap
# Supports:
#   - irm | iex
#   - Local execution
#   - CI / GitHub Actions
# ------------------------------------------------------------

#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

param(
    [string[]] $Tools,
    [string]   $Category,
    [switch]   $WinGetOnly,
    [switch]   $ExportWinGetList,
    [switch]   $Plan
)

function Resolve-DevToolsRoot {
    # Local execution (repo already cloned)
    if ($PSScriptRoot -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'DevTools'))) {
        return Join-Path $PSScriptRoot 'DevTools'
    }

    # Inline execution fallback
    $Root = Join-Path $env:TEMP 'powershell-profile\DevTools'

    if (-not (Test-Path -LiteralPath $Root)) {
        Write-Host '→ Bootstrapping DevTools…' -ForegroundColor Cyan

        $ZipUrl  = 'https://github.com/hetfs/powershell-profile/archive/refs/heads/main.zip'
        $ZipPath = Join-Path $env:TEMP 'powershell-profile.zip'

        Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath
        Expand-Archive -Path $ZipPath -DestinationPath $env:TEMP -Force
        Remove-Item -Path $ZipPath -Force
    }

    return $Root
}

$DevToolsRoot = Resolve-DevToolsRoot
$DevToolsEntrypoint = Join-Path $DevToolsRoot 'DevTools.ps1'

if (-not (Test-Path -LiteralPath $DevToolsEntrypoint)) {
    throw "DevTools.ps1 not found at $DevToolsEntrypoint"
}

Write-Host "→ Running DevTools from $DevToolsRoot" -ForegroundColor Cyan

& $DevToolsEntrypoint `
    -Tools $Tools `
    -Category $Category `
    -WinGetOnly:$WinGetOnly `
    -ExportWinGetList:$ExportWinGetList `
    -Plan:$Plan `
    -WhatIf:$WhatIfPreference
