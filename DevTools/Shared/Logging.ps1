# ----------------------------------------
# Logging.ps1 - DevTools logging module
# ----------------------------------------
# PowerShell 7+
# Text-only logging, CI-safe, WhatIf-safe
# ----------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Initialize logging configuration
# ------------------------------------------------------------
function Initialize-DevToolsLogging {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LogPath,

        [ValidateSet('DEBUG','INFO','SUCCESS','WARNING','ERROR')]
        [string]$MinimumLevel = 'INFO'
    )

    $logDir = Split-Path -LiteralPath $LogPath
    if (-not (Test-Path -LiteralPath $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    [pscustomobject]@{
        LogPath      = $LogPath
        MinimumLevel = $MinimumLevel
        SessionId    = [guid]::NewGuid()
        StartTime    = Get-Date
    }
}

# ------------------------------------------------------------
# Start logging session
# ------------------------------------------------------------
function Start-LoggingSession {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Config
    )

    if (-not $Config.LogPath) {
        throw 'Invalid logging configuration: LogPath is missing'
    }

    $header = @"
========================================
DevTools Logging Session
Session ID: $($Config.SessionId)
Start Time: $($Config.StartTime)
PowerShell: $($PSVersionTable.PSVersion)
User: $([Environment]::UserName)
Computer: $([Environment]::MachineName)
========================================
"@

    Add-Content -LiteralPath $Config.LogPath -Value $header
    Write-Host $header
}

# ------------------------------------------------------------
# Stop logging session
# ------------------------------------------------------------
function Stop-LoggingSession {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Config
    )

    $endTime  = Get-Date
    $duration = [math]::Round(($endTime - $Config.StartTime).TotalSeconds, 2)

    $footer = @"
========================================
End of DevTools Logging Session
End Time: $endTime
Duration: ${duration}s
========================================
"@

    Add-Content -LiteralPath $Config.LogPath -Value $footer
    Write-Host $footer
}

# ------------------------------------------------------------
# Core logger
# ------------------------------------------------------------
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('DEBUG','INFO','SUCCESS','WARNING','ERROR')]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter(Mandatory)]
        [pscustomobject]$Config
    )

    if (-not $Config) { return }

    $levelOrder = @{
        DEBUG   = 1
        INFO    = 2
        SUCCESS = 3
        WARNING = 4
        ERROR   = 5
    }

    if ($levelOrder[$Level] -lt $levelOrder[$Config.MinimumLevel]) {
        return
    }

    $timestamp = Get-Date
    $line = "[{0:yyyy-MM-dd HH:mm:ss.fff}][{1}] {2}" -f $timestamp, $Level, $Message

    switch ($Level) {
        'DEBUG'   { Write-Host $line -ForegroundColor DarkGray }
        'INFO'    { Write-Host $line -ForegroundColor White }
        'SUCCESS' { Write-Host $line -ForegroundColor Green }
        'WARNING' { Write-Host $line -ForegroundColor Yellow }
        'ERROR'   { Write-Host $line -ForegroundColor Red }
    }

    Add-Content -LiteralPath $Config.LogPath -Value $line
}
