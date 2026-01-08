<#
.SYNOPSIS
    Default global configuration for DevTools.

.DESCRIPTION
    Provides global defaults for logging, installation paths, package managers,
    shell/editor settings, dependency management, and update preferences.
#>

#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Default Paths
# ------------------------------------------------------------
$UserProfile        = $env:USERPROFILE
$DefaultLogPath     = Join-Path -Path $UserProfile -ChildPath 'DevToolsLogs'
$DefaultOutputPath  = Join-Path -Path $UserProfile -ChildPath 'DevToolsOutput'
$DefaultInstallPath = Join-Path -Path $UserProfile -ChildPath 'DevToolsInstall'

# ------------------------------------------------------------
# Global Defaults
# ------------------------------------------------------------
$Global:DevToolsDefaults = [PSCustomObject]@{
    # General
    DevToolsVersion       = '1.0.0'
    EnableLogging         = $true
    LogLevel              = 'Info'  # Debug, Info, Warning, Error
    LogPath               = $DefaultLogPath
    OutputPath            = $DefaultOutputPath
    InstallationsPath     = $DefaultInstallPath

    # Package Manager Preferences
    DefaultPackageManager = 'WinGet'
    PackageManagerTimeout = 300  # seconds

    # Dependency Management
    EnableDependencyCheck = $true
    DependencyResolver    = 'Resolve-ToolDependencies'

    # Tool Validation
    ToolValidatorEnabled  = $true

    # Default Shell & Editor
    DefaultShell          = 'PowerShell'
    DefaultEditor         = 'neovim'
    DefaultEditorPath     = 'C:\Program Files\Neovim\bin\nvim.exe'
    DefaultTerminal       = 'Windows Terminal'

    # Installation & Updates
    AutoUpdateTools       = $true
    UpdateCheckInterval   = 7  # days

    # WinGet Specific
    WinGetSilentInstall   = $true
    WinGetAutoAccept      = $true

    # Chocolatey Specific
    ChocolateySilent      = $true
    ChocolateySource      = 'https://community.chocolatey.org/api/v2/'

    # GitHub Release
    GitHubReleasePath     = 'https://api.github.com/repos/{Repo}/releases/latest'
    GitHubToken           = $null

    # Timeout Settings
    DefaultTimeout        = 60
    NetworkTimeout        = 120
}

# ------------------------------------------------------------
# Ensure Required Directories Exist
# ------------------------------------------------------------
foreach ($Path in @(
    $Global:DevToolsDefaults.LogPath,
    $Global:DevToolsDefaults.OutputPath,
    $Global:DevToolsDefaults.InstallationsPath
)) {
    if (-not (Test-Path -Path $Path)) {
        try {
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
        } catch {
            Write-Warning "Failed to create directory '$Path': $_"
        }
    }
}

# ------------------------------------------------------------
# Export Environment Variables
# ------------------------------------------------------------
$env:DEVTOOLS_LOG_PATH     = $Global:DevToolsDefaults.LogPath
$env:DEVTOOLS_OUTPUT_PATH  = $Global:DevToolsDefaults.OutputPath
$env:DEVTOOLS_INSTALL_PATH = $Global:DevToolsDefaults.InstallationsPath
$env:EDITOR                = $Global:DevToolsDefaults.DefaultEditor
