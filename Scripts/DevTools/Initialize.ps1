#region Initialization Functions
function Initialize-DeveTools {
    param(
        [string]$LogPath,
        [string]$InstallPath
    )
    
    $ErrorActionPreference = 'Continue'
    $ProgressPreference = 'SilentlyContinue'
    $script:scriptStartTime = Get-Date
    
    # Store parameters in script scope
    $script:InstallPath = $InstallPath
    
    # Set up logging
    if ([string]::IsNullOrEmpty($LogPath)) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $LogPath = Join-Path $env:TEMP "DeveTools-$timestamp.log"
    }
    
    $logDir = Split-Path $LogPath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    # Store LogPath in script scope for Write-Log function
    $script:LogPath = $LogPath
    
    # Create installation directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-Log "Created installation directory: $InstallPath" -Level INFO
    }
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Log "PowerShell 7.0 or higher is required. Current version: $($PSVersionTable.PSVersion)" -Level ERROR
        exit 1
    }
    
    # Check for admin rights
    $script:isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $script:isAdmin) {
        Write-Log "Running without administrator privileges. Some installations may require elevation." -Level WARN
    }
    
    Write-Log "================================================" -Level Info -LogPath $LogPath
    Write-Log "Dev Tools Installation Started" -Level Info -LogPath $LogPath
    Write-Log "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level Info -LogPath $LogPath
    Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)" -Level Info -LogPath $LogPath
    Write-Log "Windows Version: $([Environment]::OSVersion.Version)" -Level Info -LogPath $LogPath
    Write-Log "Running as Admin: $script:IsAdmin" -Level Info -LogPath $LogPath
    Write-Log "Installation base path: $InstallPath" -Level INFO
    Write-Log "Log file: $LogPath" -Level INFO
    Write-Log "================================================" -Level Info -LogPath $LogPath
}

function Write-Log {
    param(
        [string]$Message, 
        [ValidateSet('INFO','WARN','ERROR','DEBUG','SUCCESS','SKIP')]$Level = 'INFO'
    )
    
    # If LogPath is not set yet, write to console only
    if ([string]::IsNullOrEmpty($script:LogPath)) {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $logMessage = "$timestamp [$Level] $Message"
        
        switch ($Level) {
            'ERROR'   { Write-Host $logMessage -ForegroundColor Red }
            'WARN'    { Write-Host $logMessage -ForegroundColor Yellow }
            'INFO'    { Write-Host $logMessage -ForegroundColor Cyan }
            'SUCCESS' { Write-Host $logMessage -ForegroundColor Green }
            'SKIP'    { Write-Host $logMessage -ForegroundColor Gray }
            'DEBUG'   { Write-Verbose $logMessage }
        }
        return
    }
    
    # Normal logging with file output
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "$timestamp [$Level] $Message"
    
    try {
        Add-Content -Path $script:LogPath -Value $logMessage -ErrorAction SilentlyContinue
    } catch {
        # If file writing fails, just write to console
        Write-Host "Failed to write to log file: $_" -ForegroundColor Red
    }
    
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
