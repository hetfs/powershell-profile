#region Initialization Functions

function Initialize-DeveTools {
    <#
    .SYNOPSIS
        Initializes the DevTools installation environment.
    .DESCRIPTION
        Sets up logging, installation paths, checks for PowerShell version and admin rights,
        and logs system details for auditing.
    .PARAMETER LogPath
        Optional path to log file. Defaults to $env:TEMP\DeveTools-{timestamp}.log
    .PARAMETER InstallPath
        Base directory for installations. Defaults to $env:LocalAppData\Programs
    #>
    param(
        [string]$LogPath,
        [string]$InstallPath = "$env:LocalAppData\Programs"
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Continue'
    $ProgressPreference = 'SilentlyContinue'
    $script:scriptStartTime = Get-Date

    # Store installation path in script scope
    $script:InstallPath = $InstallPath

    # Setup log file
    if ([string]::IsNullOrEmpty($LogPath)) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $LogPath = Join-Path $env:TEMP "DeveTools-$timestamp.log"
    }

    $logDir = Split-Path $LogPath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $script:LogPath = $LogPath

    # Create installation directory if missing
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-Log "Created installation directory: $InstallPath" -Level INFO
    }

    # PowerShell version check
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Log "PowerShell 7.0+ is required. Current version: $($PSVersionTable.PSVersion)" -Level ERROR
        exit 1
    }

    # Administrator check
    $script:IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $script:IsAdmin) {
        Write-Log "Running without admin privileges. Some tools may require elevation." -Level WARN
    }

    # Log environment details
    Write-Log "================================================" -Level INFO
    Write-Log "Dev Tools Installation Started" -Level INFO
    Write-Log "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level INFO
    Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)" -Level INFO
    Write-Log "Windows Version: $([Environment]::OSVersion.Version)" -Level INFO
    Write-Log "Running as Admin: $script:IsAdmin" -Level INFO
    Write-Log "Installation Base Path: $InstallPath" -Level INFO
    Write-Log "Log File: $LogPath" -Level INFO
    Write-Log "================================================" -Level INFO
}

function Write-Log {
    <#
    .SYNOPSIS
        Writes a log message to console and optional log file.
    .DESCRIPTION
        Logs messages with timestamp and severity. If LogPath is not yet set, logs to console only.
    .PARAMETER Message
        The message text to log.
    .PARAMETER Level
        Severity level. Valid values: INFO, WARN, ERROR, DEBUG, SUCCESS, SKIP
    #>
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG','SUCCESS','SKIP')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "$timestamp [$Level] $Message"

    # Write to log file if available
    if (-not [string]::IsNullOrEmpty($script:LogPath)) {
        try {
            Add-Content -Path $script:LogPath -Value $logMessage -ErrorAction SilentlyContinue
        } catch {
            Write-Host "⚠️ Failed to write to log file: $_" -ForegroundColor Red
        }
    }

    # Console output with color coding
    switch ($Level) {
        'ERROR'   { Write-Host $logMessage -ForegroundColor Red }
        'WARN'    { Write-Host $logMessage -ForegroundColor Yellow }
        'INFO'    { Write-Host $logMessage -ForegroundColor Cyan }
        'SUCCESS' { Write-Host $logMessage -ForegroundColor Green }
        'SKIP'    { Write-Host $logMessage -ForegroundColor Gray }
        'DEBUG'   { Write-Verbose $logMessage }
    }
}

#endregion
