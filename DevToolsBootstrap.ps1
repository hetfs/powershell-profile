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

.EXAMPLE
    .\DevToolsBootstrap.ps1

.EXAMPLE
    iex (irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/DevToolsBootstrap.ps1)
#>

# ------------------------------------------------------------
# Requirements & configuration
# ------------------------------------------------------------

#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SCRIPT_VERSION = '1.0.1'
$REPO_URL       = 'https://github.com/hetfs/powershell-profile'
$RAW_BASE_URL   = 'https://raw.githubusercontent.com/hetfs/powershell-profile/main'
$ONLINE_SCRIPT_URL = "$RAW_BASE_URL/DevTools/DevTools.ps1"

$LOCAL_PATHS = @(
    { if ($PSScriptRoot) { Join-Path $PSScriptRoot 'DevTools\DevTools.ps1' } },
    { Join-Path (Get-Location) 'DevTools\DevTools.ps1' },
    { Join-Path $env:USERPROFILE 'powershell-profile\DevTools\DevTools.ps1' },
    {
        if ($PSScriptRoot) {
            Join-Path (Split-Path $PSScriptRoot -Parent) 'DevTools\DevTools.ps1'
        }
    }
)

# ------------------------------------------------------------
# Core helpers
# ------------------------------------------------------------

function Show-Banner {
    $line = '═' * 62
    Write-Host ''
    Write-Host "╔$line╗" -ForegroundColor Cyan
    Write-Host ("║ DevTools Bootstrap v{0,-46} ║" -f $SCRIPT_VERSION) -ForegroundColor Cyan
    Write-Host "╠$line╣" -ForegroundColor Cyan
    Write-Host ("║ Repository: {0,-48} ║" -f $REPO_URL) -ForegroundColor Cyan
    Write-Host "╚$line╝" -ForegroundColor Cyan
    Write-Host ''
}

function Get-LocalDevToolsPath {
    Write-Verbose 'Searching for local DevTools.ps1...'

    foreach ($generator in $LOCAL_PATHS) {
        try {
            $path = & $generator
            if ($path -and (Test-Path -LiteralPath $path)) {
                Write-Verbose "Found local DevTools at $path"
                return $path
            }
        } catch {
            Write-Verbose "Path check failed: $($_.Exception.Message)"
        }
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

    try {
        $content = Invoke-RestMethod -Uri $ONLINE_SCRIPT_URL -ErrorAction Stop

        $tempFile = Join-Path ([IO.Path]::GetTempPath()) (
            'DevTools-{0}.ps1' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
        )

        $content | Out-File -FilePath $tempFile -Encoding UTF8 -Force

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
    $result = [PSCustomObject]@{
        LocalAvailable  = $false
        LocalPath       = $null
        OnlineAvailable = $false
        TestTime        = Get-Date
    }

    $localPath = Get-LocalDevToolsPath
    if ($localPath) {
        $result.LocalAvailable = $true
        $result.LocalPath = $localPath
    }

    try {
        $head = Invoke-WebRequest -Uri $ONLINE_SCRIPT_URL -Method Head -TimeoutSec 5
        $result.OnlineAvailable = $head.StatusCode -eq 200
    } catch {
        $result.OnlineAvailable = $false
    }

    $result
}

# ------------------------------------------------------------
# Main execution
# ------------------------------------------------------------

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Start-DevTools
        exit 0
    } catch {
        Write-Host ''
        Write-Host 'Fatal error in DevTools Bootstrap:' -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ''
        Write-Host "Report issues at: $REPO_URL/issues" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "DevTools Bootstrap v$SCRIPT_VERSION loaded." -ForegroundColor Green
    Write-Host 'Available commands:' -ForegroundColor Gray
    Write-Host '  Start-DevTools' -ForegroundColor Cyan
    Write-Host '  Test-DevToolsAvailability' -ForegroundColor Cyan
}
