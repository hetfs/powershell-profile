# ============================================================
# DevTools Bootstrap v1.0.1
# Minimal, reliable bootstrap for local/online execution
# ============================================================

<#
.SYNOPSIS
    Bootstrap script to run DevTools.ps1 locally or from GitHub.

.DESCRIPTION
    Automatically detects and runs DevTools.ps1 from:
    1. Local repository (preferred)
    2. GitHub raw content (fallback)

.NOTES
    Version: 1.0.1
    Author: HetFS
    Repository: https://github.com/hetfs/powershell-profile
#>

# ------------------------------------------------------------
# Requirements & configuration
# ------------------------------------------------------------

#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SCRIPT_VERSION      = '1.0.1'
$REPO_URL            = 'https://github.com/hetfs/powershell-profile'
$RAW_BASE_URL        = 'https://raw.githubusercontent.com/hetfs/powershell-profile/main'
$ONLINE_SCRIPT_URL   = "$RAW_BASE_URL/DevTools/DevTools.ps1"

$LOCAL_PATHS = @(
    { if ($PSScriptRoot) { Join-Path $PSScriptRoot 'DevTools\DevTools.ps1' } },
    { Join-Path (Get-Location) 'DevTools\DevTools.ps1' },
    { Join-Path $env:USERPROFILE 'powershell-profile\DevTools\DevTools.ps1' },
    { if ($PSScriptRoot) { Join-Path (Split-Path $PSScriptRoot -Parent) 'DevTools\DevTools.ps1' } }
)

# ------------------------------------------------------------
# Core helpers
# ------------------------------------------------------------

function Show-Banner {
    # ------------------------------------------------------------
    # Define banner lines and colors
    # Each element: [Text, ForegroundColor]
    # ------------------------------------------------------------
    $lines = @(
        @("DevTools Bootstrap v$SCRIPT_VERSION", 'Cyan'),
        @("Repository: $REPO_URL", 'Yellow'),
        @("Author: HETFS LTD.", 'Cyan'),
        @("Version: $SCRIPT_VERSION", 'Yellow'),
        @("Windows DevTools Project", 'Cyan')
    )

    # ------------------------------------------------------------
    # Calculate dynamic inner width
    # ------------------------------------------------------------
    $padding = 2
    $maxTextLength = ($lines | ForEach-Object { $_[0].Length } | Measure-Object -Maximum).Maximum
    $innerWidth = $maxTextLength + $padding
    $line = '═' * $innerWidth

    # ------------------------------------------------------------
    # Helper function to format each line
    # ------------------------------------------------------------
    function Format-Line($text) {
        $spaces = $innerWidth - $text.Length
        return "║ $text" + (' ' * $spaces) + "║"
    }

    # ------------------------------------------------------------
    # Draw banner
    # ------------------------------------------------------------
    Write-Host ''
    Write-Host "╔$line╗" -ForegroundColor Cyan
    foreach ($entry in $lines) {
        $text  = $entry[0]
        $color = $entry[1]
        Write-Host (Format-Line $text) -ForegroundColor $color
    }
    Write-Host "╚$line╝" -ForegroundColor Cyan
    Write-Host ''
}

function Get-LocalDevToolsPath {
    Write-Verbose 'Searching for local DevTools.ps1...'

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
    Write-Host "Source   : Local" -ForegroundColor DarkGray
    Write-Host "Location : $(Split-Path $Path -Parent)" -ForegroundColor DarkGray

    $env:DEVTOOLS_SOURCE = 'Local'
    $env:DEVTOOLS_ROOT   = Split-Path $Path -Parent
    $env:DEVTOOLS_BOOTSTRAP_VERSION = $SCRIPT_VERSION

    & $Path
}

function Invoke-OnlineDevTools {
    Write-Host 'Running DevTools from GitHub...' -ForegroundColor Cyan
    Write-Host "Source   : Online" -ForegroundColor DarkGray
    Write-Host "URL      : $ONLINE_SCRIPT_URL" -ForegroundColor DarkGray

    $env:DEVTOOLS_SOURCE = 'Online'
    $env:DEVTOOLS_ROOT   = "$REPO_URL/tree/main/DevTools"
    $env:DEVTOOLS_BOOTSTRAP_VERSION = $SCRIPT_VERSION

    $tempFile = Join-Path ([IO.Path]::GetTempPath()) (
        'DevTools-{0}.ps1' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
    )

    try {
        Invoke-RestMethod -Uri $ONLINE_SCRIPT_URL -ErrorAction Stop |
            Out-File -FilePath $tempFile -Encoding UTF8 -Force

        & $tempFile
    }
    finally {
        if (Test-Path $tempFile) {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}

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
    Write-Host 'DevTools execution completed.' -ForegroundColor Green
}

function Test-DevToolsAvailability {
    [PSCustomObject]@{
        LocalAvailable  = [bool](Get-LocalDevToolsPath)
        LocalPath       = Get-LocalDevToolsPath
        OnlineAvailable = (Invoke-WebRequest -Uri $ONLINE_SCRIPT_URL -Method Head -TimeoutSec 5 -ErrorAction SilentlyContinue).StatusCode -eq 200
        TestTime        = Get-Date
    }
}

# ------------------------------------------------------------
# Main execution
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
