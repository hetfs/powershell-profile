# ============================================================
# DevTools Bootstrap v1.0.0
# Minimal, reliable bootstrap for local/online execution
# ============================================================

<#
.SYNOPSIS
    Bootstrap script to run DevTools.ps1 locally or from GitHub

.DESCRIPTION
    This script automatically detects and runs DevTools.ps1 from:
    1. Local repository (if available)
    2. GitHub (as fallback or primary when local not found)

.NOTES
    Version: 1.0.0
    Author: HetFS
    Repository: https://github.com/hetfs/powershell-profile

.EXAMPLE
    # Run locally (if repository is cloned)
    .\DevToolsBootstrap.ps1

.EXAMPLE
    # Run from GitHub (one-liner)
    iex (irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/DevToolsBootstrap.ps1)
#>

#region Requirements & Configuration
# ============================================================
# REQUIREMENTS & CONFIGURATION
# ============================================================

#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Repository Configuration
$SCRIPT_VERSION = "1.0.0"
$REPO_URL = "https://github.com/hetfs/powershell-profile"
$RAW_BASE_URL = "https://raw.githubusercontent.com/hetfs/powershell-profile/main"
$ONLINE_SCRIPT_URL = "$RAW_BASE_URL/DevTools/DevTools.ps1"

# Common Local Paths
$LOCAL_PATHS = @(
    # Relative to script location
    { if ($PSScriptRoot) { Join-Path $PSScriptRoot 'DevTools\DevTools.ps1' } },

    # Current directory
    { Join-Path (Get-Location) 'DevTools\DevTools.ps1' },

    # User's profile directory
    { Join-Path $env:USERPROFILE 'powershell-profile\DevTools\DevTools.ps1' },

    # One level up from script
    { if ($PSScriptRoot) {
        $parentDir = Split-Path $PSScriptRoot -Parent
        Join-Path $parentDir 'DevTools\DevTools.ps1'
    } }
)

# Execution Mode Tracking
enum DevToolsSource {
    Local
    Online
    Unknown
}
#endregion

#region Core Functions
# ============================================================
# CORE FUNCTIONS
# ============================================================

function Show-Banner {
    <#
    .SYNOPSIS
        Displays script banner and version information
    #>

    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                  DevTools Bootstrap v$SCRIPT_VERSION                    ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║  Automatically runs DevTools.ps1 from local or GitHub        ║" -ForegroundColor Cyan
    Write-Host "║  Repository: $REPO_URL  ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Get-LocalDevToolsPath {
    <#
    .SYNOPSIS
        Finds the local DevTools.ps1 script if it exists

    .OUTPUTS
        [string] Path to DevTools.ps1 or $null if not found
    #>

    Write-Verbose "🔍 Searching for local DevTools.ps1..."

    foreach ($pathGenerator in $LOCAL_PATHS) {
        try {
            $path = & $pathGenerator
            if ($path -and (Test-Path -LiteralPath $path)) {
                Write-Verbose "✅ Found at: $path"
                return $path
            }
        } catch {
            Write-Verbose "⚠️  Error checking path: $_"
        }
    }

    Write-Verbose "❌ No local DevTools.ps1 found"
    return $null
}

function Invoke-LocalDevTools {
    <#
    .SYNOPSIS
        Executes the local DevTools.ps1 script

    .PARAMETER Path
        Full path to DevTools.ps1
    #>

    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_})]
        [string]$Path
    )

    Write-Host "📁 Running local DevTools..." -ForegroundColor Green
    Write-Host "   Source: $(Split-Path $Path -Leaf)" -ForegroundColor DarkGray
    Write-Host "   Location: $(Split-Path $Path -Parent)" -ForegroundColor DarkGray

    # Set environment context
    $env:DEVTOOLS_SOURCE = "Local"
    $env:DEVTOOLS_ROOT = Split-Path $Path -Parent
    $env:DEVTOOLS_BOOTSTRAP_VERSION = $SCRIPT_VERSION

    try {
        # Execute the script
        & $Path
        Write-Verbose "✅ Local execution completed successfully"
    } catch {
        Write-Host "❌ Error running local DevTools: $_" -ForegroundColor Red
        throw "Local execution failed"
    }
}

function Invoke-OnlineDevTools {
    <#
    .SYNOPSIS
        Downloads and executes DevTools.ps1 from GitHub
    #>

    Write-Host "🌐 Running DevTools from GitHub..." -ForegroundColor Cyan
    Write-Host "   URL: $ONLINE_SCRIPT_URL" -ForegroundColor DarkGray

    # Set environment context
    $env:DEVTOOLS_SOURCE = "Online"
    $env:DEVTOOLS_ROOT = "$REPO_URL/tree/main/DevTools"
    $env:DEVTOOLS_BOOTSTRAP_VERSION = $SCRIPT_VERSION

    try {
        # Download script content
        Write-Verbose "📥 Downloading script from GitHub..."
        $scriptContent = Invoke-RestMethod -Uri $ONLINE_SCRIPT_URL -ErrorAction Stop

        # Create temporary file for execution
        $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "DevTools-$(Get-Date -Format 'yyyyMMdd-HHmmss').ps1"
        $scriptContent | Out-File -FilePath $tempFile -Encoding UTF8 -Force

        Write-Verbose "📄 Temporary file created: $tempFile"

        # Execute the script
        & $tempFile

        # Cleanup
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        Write-Verbose "🧹 Temporary file cleaned up"

    } catch {
        Write-Host "❌ Failed to run online DevTools: $_" -ForegroundColor Red

        # Attempt local fallback
        Write-Host "🔄 Attempting local fallback..." -ForegroundColor Yellow
        $localPath = Get-LocalDevToolsPath

        if ($localPath) {
            Write-Host "✅ Found local version, falling back..." -ForegroundColor Green
            Invoke-LocalDevTools -Path $localPath
        } else {
            throw @"
Online execution failed and no local version available.

Troubleshooting steps:
1. Check your internet connection
2. Verify the repository exists: $REPO_URL
3. Clone the repository locally:
   git clone $REPO_URL
4. Run the bootstrap script from the cloned directory

Error details: $_
"@
        }
    }
}

function Start-DevTools {
    <#
    .SYNOPSIS
        Main entry point - automatically runs DevTools.ps1
    #>

    # Show banner
    Show-Banner

    # Try to find local script first
    Write-Host "🔄 Detecting available DevTools..." -ForegroundColor Gray
    $localPath = Get-LocalDevToolsPath

    if ($localPath) {
        Invoke-LocalDevTools -Path $localPath
    } else {
        Write-Host "📡 No local DevTools found, switching to online mode" -ForegroundColor Yellow
        Invoke-OnlineDevTools
    }

    Write-Host "`n🎉 DevTools execution completed!" -ForegroundColor Green
}

function Test-DevToolsAvailability {
    <#
    .SYNOPSIS
        Tests if DevTools is available locally or online

    .OUTPUTS
        [PSCustomObject] with availability status
    #>

    $result = [PSCustomObject]@{
        LocalAvailable = $false
        LocalPath = $null
        OnlineAvailable = $false
        TestTime = Get-Date
    }

    # Test local
    $localPath = Get-LocalDevToolsPath
    if ($localPath) {
        $result.LocalAvailable = $true
        $result.LocalPath = $localPath
    }

    # Test online (without full download)
    try {
        $testRequest = Invoke-WebRequest -Uri $ONLINE_SCRIPT_URL -Method Head -TimeoutSec 5 -ErrorAction Stop
        $result.OnlineAvailable = $testRequest.StatusCode -eq 200
    } catch {
        $result.OnlineAvailable = $false
    }

    return $result
}
#endregion

#region Main Execution Logic
# ============================================================
# MAIN EXECUTION LOGIC
# ============================================================

# Auto-execute when script is invoked directly (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    try {
        # Enable verbose mode if -Verbose switch is used
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = 'Continue'
        }

        Start-DevTools

        # Set success exit code
        exit 0

    } catch {
        Write-Host "`n💥 Fatal error in DevTools Bootstrap:" -ForegroundColor Red
        Write-Host "   $($_.Exception.Message)" -ForegroundColor Red

        if ($_.ScriptStackTrace) {
            Write-Host "`n📋 Stack trace:" -ForegroundColor DarkGray
            Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
        }

        Write-Host "`n🛟 Need help? Report issues at: $REPO_URL/issues" -ForegroundColor Yellow
        exit 1
    }
} else {
    # Script was dot-sourced - just define functions
    Write-Host "✅ DevTools Bootstrap v$SCRIPT_VERSION loaded." -ForegroundColor Green
    Write-Host "   Available commands:" -ForegroundColor Gray
    Write-Host "   • Start-DevTools      - Run DevTools (local → online)" -ForegroundColor Cyan
    Write-Host "   • Test-DevToolsAvailability - Check availability" -ForegroundColor Cyan
    Write-Host ""
}
#endregion
