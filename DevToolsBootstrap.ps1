# ============================================================
# DevTools Bootstrap v1.0.2
# Minimal, reliable bootstrap for local/online execution
# ============================================================

<#
.SYNOPSIS
    Bootstrap script to run DevTools.ps1 locally or from GitHub.

.DESCRIPTION
    Automatically detects and runs DevTools.ps1 from:
    1. Local repository (preferred)
    2. GitHub ZIP archive (fallback, FIXED)

.NOTES
    Version: 1.0.2
    Author: HetFS
    Repository: https://github.com/hetfs/powershell-profile
#>

# ------------------------------------------------------------
# Requirements & configuration
# ------------------------------------------------------------

#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SCRIPT_VERSION = '1.0.2'
$REPO_URL       = 'https://github.com/hetfs/powershell-profile'
$ZIP_URL        = "$REPO_URL/archive/refs/heads/main.zip"

$LOCAL_PATHS = @(
    { if ($PSScriptRoot) { Join-Path $PSScriptRoot 'DevTools\DevTools.ps1' } },
    { Join-Path (Get-Location) 'DevTools\DevTools.ps1' },
    { Join-Path $env:USERPROFILE 'powershell-profile\DevTools\DevTools.ps1' },
    { if ($PSScriptRoot) { Join-Path (Split-Path $PSScriptRoot -Parent) 'DevTools\DevTools.ps1' } }
)

# ------------------------------------------------------------
# Banner
# ------------------------------------------------------------

function Show-Banner {
    $lines = @(
        @("DevTools Bootstrap v$SCRIPT_VERSION", 'Cyan'),
        @("Repository: $REPO_URL", 'Yellow'),
        @("Author: HETFS LTD.", 'Cyan'),
        @("Version: $SCRIPT_VERSION", 'Yellow'),
        @("Windows DevTools Project", 'Cyan')
    )

    $padding = 2
    $maxLen  = ($lines | ForEach-Object { $_[0].Length } | Measure-Object -Maximum).Maximum
    $width   = $maxLen + $padding
    $bar     = '═' * $width

    function Format-Line([string]$Text) {
        $spaces = $width - $Text.Length
        "║ $Text$(' ' * $spaces)║"
    }

    Write-Host ''
    Write-Host "╔$bar╗" -ForegroundColor Cyan
    foreach ($entry in $lines) {
        Write-Host (Format-Line $entry[0]) -ForegroundColor $entry[1]
    }
    Write-Host "╚$bar╝" -ForegroundColor Cyan
    Write-Host ''
}

# ------------------------------------------------------------
# Local execution
# ------------------------------------------------------------

function Get-LocalDevToolsPath {
    foreach ($generator in $LOCAL_PATHS) {
        try {
            $path = & $generator
            if ($path -and (Test-Path -LiteralPath $path)) {
                return $path
            }
        } catch {}
    }
    return $null
}

function Invoke-LocalDevTools {
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
    )

    Write-Host 'Running local DevTools...' -ForegroundColor Green
    Write-Host 'Source   : Local' -ForegroundColor DarkGray
    Write-Host "Location : $(Split-Path $Path -Parent)" -ForegroundColor DarkGray

    $env:DEVTOOLS_SOURCE  = 'Local'
    $env:DEVTOOLS_ROOT    = Split-Path $Path -Parent
    $env:DEVTOOLS_BOOTSTRAP_VERSION = $SCRIPT_VERSION

    & $Path
}

# ------------------------------------------------------------
# Online execution (FIXED)
# ------------------------------------------------------------

function Invoke-OnlineDevTools {
    Write-Host 'Running DevTools from GitHub...' -ForegroundColor Cyan
    Write-Host 'Source   : Online' -ForegroundColor DarkGray

    $env:DEVTOOLS_SOURCE = 'Online'
    $env:DEVTOOLS_BOOTSTRAP_VERSION = $SCRIPT_VERSION

    $tempRoot = Join-Path ([IO.Path]::GetTempPath()) (
        'DevTools-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
    )

    $zipPath = "$tempRoot.zip"

    try {
        Write-Host 'Downloading repository bundle...' -ForegroundColor Gray
        Invoke-WebRequest -Uri $ZIP_URL -OutFile $zipPath -UseBasicParsing

        Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

        $repoRoot = Get-ChildItem $tempRoot |
            Where-Object { $_.PSIsContainer } |
            Select-Object -First 1

        $devToolsDir = Join-Path $repoRoot.FullName 'DevTools'
        $entryScript = Join-Path $devToolsDir 'DevTools.ps1'

        if (-not (Test-Path $entryScript)) {
            throw 'DevTools.ps1 not found in downloaded repository'
        }

        $env:DEVTOOLS_ROOT = $devToolsDir

        Write-Host "Location : $devToolsDir" -ForegroundColor DarkGray
        & $entryScript
    }
    finally {
        if (Test-Path $zipPath) {
            Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        }
    }
}

# ------------------------------------------------------------
# Entry point
# ------------------------------------------------------------

function Start-DevTools {
    Show-Banner

    Write-Host 'Detecting DevTools source...' -ForegroundColor Gray
    $localPath = Get-LocalDevToolsPath

    if ($localPath) {
        Invoke-LocalDevTools -Path $localPath
    } else {
        Write-Host 'Local DevTools not found. Falling back to GitHub.' -ForegroundColor Yellow
        Invoke-OnlineDevTools
    }

    Write-Host ''
    Write-Host '🎉 DevTools execution completed.' -ForegroundColor Green
}

function Test-DevToolsAvailability {
    [PSCustomObject]@{
        LocalAvailable  = [bool](Get-LocalDevToolsPath)
        LocalPath       = Get-LocalDevToolsPath
        OnlineAvailable = $true
        TestTime        = Get-Date
    }
}

# ------------------------------------------------------------
# Script execution
# ------------------------------------------------------------

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Start-DevTools
    } catch {
        Write-Host ''
        Write-Host 'Fatal error in DevTools Bootstrap:' -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ''
        Write-Host "Report issues at: $REPO_URL/issues" -ForegroundColor Yellow
        throw
    }
} else {
    Write-Host "DevTools Bootstrap v$SCRIPT_VERSION loaded." -ForegroundColor Green
    Write-Host 'Available commands:' -ForegroundColor Gray
    Write-Host '  Start-DevTools' -ForegroundColor Cyan
    Write-Host '  Test-DevToolsAvailability' -ForegroundColor Cyan
}
