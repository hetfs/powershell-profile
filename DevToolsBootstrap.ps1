# ------------------------------------------------------------
# DevTools Bootstrap (Minimal Inline Version)
# ------------------------------------------------------------

#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
$REPO_URL = "https://github.com/hetfs/powershell-profile"
$RAW_BASE_URL = "https://raw.githubusercontent.com/hetfs/powershell-profile/main"
$ONLINE_SCRIPT_URL = "$RAW_BASE_URL/DevTools/DevTools.ps1"

# ------------------------------------------------------------
# Resolve Local DevTools
# ------------------------------------------------------------
function Get-LocalDevTools {
    # Check relative to bootstrap script
    if ($PSScriptRoot) {
        $localPath = Join-Path $PSScriptRoot 'DevTools\DevTools.ps1'
        if (Test-Path $localPath) {
            return $localPath
        }
    }

    # Check in current directory
    $currentPath = Join-Path (Get-Location) 'DevTools\DevTools.ps1'
    if (Test-Path $currentPath) {
        return $currentPath
    }

    # Check in user's powershell-profile directory
    $profilePath = Join-Path $env:USERPROFILE 'powershell-profile\DevTools\DevTools.ps1'
    if (Test-Path $profilePath) {
        return $profilePath
    }

    return $null
}

# ------------------------------------------------------------
# Execute Local Script
# ------------------------------------------------------------
function Invoke-LocalDevTools {
    param([string]$Path)

    Write-Host "🚀 Running local DevTools..." -ForegroundColor Green
    Write-Host "   Source: $Path" -ForegroundColor Gray

    # Set environment variable for context
    $env:DEVTOOLS_SOURCE = "LOCAL"
    $env:DEVTOOLS_ROOT = Split-Path $Path -Parent

    try {
        & $Path
    } catch {
        Write-Host "❌ Error running local script: $_" -ForegroundColor Red
        throw
    }
}

# ------------------------------------------------------------
# Execute Online Script
# ------------------------------------------------------------
function Invoke-OnlineDevTools {
    Write-Host "🌐 Running online DevTools from GitHub..." -ForegroundColor Cyan
    Write-Host "   URL: $ONLINE_SCRIPT_URL" -ForegroundColor Gray

    # Set environment variable for context
    $env:DEVTOOLS_SOURCE = "ONLINE"
    $env:DEVTOOLS_ROOT = "$REPO_URL/tree/main/DevTools"

    try {
        # Download and execute in memory
        $scriptContent = Invoke-RestMethod -Uri $ONLINE_SCRIPT_URL -ErrorAction Stop

        # Create a temporary script block and execute it
        $scriptBlock = [ScriptBlock]::Create($scriptContent)
        & $scriptBlock

    } catch {
        Write-Host "❌ Failed to run online script: $_" -ForegroundColor Red

        # Try to fallback to local if available
        $localPath = Get-LocalDevTools
        if ($localPath) {
            Write-Host "🔄 Falling back to local version..." -ForegroundColor Yellow
            Invoke-LocalDevTools -Path $localPath
        } else {
            throw "No local version available. Please check your internet connection or clone the repository."
        }
    }
}

# ------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------
function Start-DevTools {
    Write-Host "🔍 Looking for DevTools..." -ForegroundColor Gray

    # Try to find local script first
    $localPath = Get-LocalDevTools

    if ($localPath) {
        Invoke-LocalDevTools -Path $localPath
    } else {
        Invoke-OnlineDevTools
    }
}

# ------------------------------------------------------------
# Auto-execute when invoked directly
# ------------------------------------------------------------
# Check if script was invoked directly (not sourced/dotted)
if ($MyInvocation.InvocationName -ne '.') {
    # This runs when script is executed with .\DevToolsBootstrap.ps1
    # or via iex (irm ...)
    Start-DevTools
} else {
    # If script was sourced/dotted, just define the function
    Write-Host "✅ DevToolsBootstrap loaded. Use Start-DevTools to run." -ForegroundColor Green
}
