<#
.SYNOPSIS
    Comprehensive Windows terminal utilities installer with intelligent multi-method fallback strategies.

.DESCRIPTION
    Installs all development tools from the specified registry using WinGet as primary,
    GitHub Releases as secondary, and Chocolatey as tertiary method.
    Features automatic PATH management, verification, and detailed logging.

.PARAMETER Method
    Specifies the primary installation method chain. Options: 'All', 'WinGet', 'GitHub', 'Chocolatey'

.PARAMETER SkipWinget
    Skips WinGet entirely and uses fallback methods only.

.PARAMETER FallbackOnly
    Alias for SkipWinget. Skips WinGet entirely.

.PARAMETER Force
    Forces reinstallation even if tool is already present.

.PARAMETER Categories
    Array of specific categories to install. If not specified, installs all.

.PARAMETER Tools
    Array of specific tools to install. If not specified, installs all in selected categories.

.PARAMETER LogPath
    Path to log file. Default: $env:TEMP\DevTools-{timestamp}.log

.PARAMETER InstallPath
    Base installation directory. Default: $env:LocalAppData\Programs

.PARAMETER MaxRetries
    Maximum number of retry attempts per tool. Default: 2

.EXAMPLE
    .\DeveTools.ps1
    # Installs all tools using default method chain

.EXAMPLE
    .\DeveTools.ps1 -Categories "CoreShell", "VersionControl"
    # Installs tools for CoreShell and VersionControl categories

.EXAMPLE
    .\DeveTools.ps1 -Tools "git", "neovim" -SkipWinget
    # Installs only git and neovim using fallback methods only

.EXAMPLE
    .\DeveTools.ps1 -Method Chocolatey -Force
    # Force reinstall all tools using Chocolatey only

.NOTES
    Author: Windows Development Environment Setup
    Requires: PowerShell 7.0+, Administrative privileges recommended
    Version: 3.0.0 - Modular structure with progress bars
    License: MIT
#>

[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Default')]
param(
    [Parameter(Position = 0)]
    [ValidateSet('All', 'WinGet', 'GitHub', 'Chocolatey')]
    [string]$Method = 'All',

    [Parameter(ParameterSetName = 'SkipWinget')]
    [switch]$SkipWinget,

    [Parameter(ParameterSetName = 'SkipWinget')]
    [Alias('FallbackOnly')]
    [switch]$NoWinget,

    [switch]$Force,

    [ValidateSet('CoreShell', 'VersionControl', 'ShellProductivity', 'PromptUI', 
                 'Languages', 'SystemUtils', 'Network', 'Terminals', 
                 'Editors', 'DataTools', 'Multimedia')]
    [string[]]$Categories,

    [string[]]$Tools,

    [string]$LogPath,

    [string]$InstallPath = "$env:LocalAppData\Programs",

    [int]$MaxRetries = 1
)

# Dot source all module files
$scriptRoot = $PSScriptRoot

# Store parameters in script scope for later use
$script:LogPath = $LogPath
$script:InstallPath = $InstallPath
$script:WhatIfPreference = $WhatIfPreference

# Import all modules
. "$scriptRoot\Initialize.ps1"
. "$scriptRoot\PackageManagers.ps1"
. "$scriptRoot\Helpers.ps1"
. "$scriptRoot\Installers\WinGet.ps1"
. "$scriptRoot\Installers\Chocolatey.ps1"
. "$scriptRoot\Installers\GitHub.ps1"
. "$scriptRoot\Installers\PowerShell.ps1"
. "$scriptRoot\Orchestrator.ps1"
. "$scriptRoot\Summary.ps1"

# Main execution
try {
    # Initialize - pass parameters directly
    Initialize-DeveTools -LogPath $LogPath -InstallPath $InstallPath
    
    # Detect package managers
    $availableMethods = Detect-PackageManagers
    
    # Determine installation methods
    $methodsOrder = Determine-MethodOrder -Method $Method -SkipWinget ($SkipWinget -or $NoWinget) -AvailableMethods $availableMethods
    
    # Import selected category files
    $toolRegistry = @{}
    if ($Categories) {
        foreach ($category in $Categories) {
            $categoryFile = "$scriptRoot\ToolRegistry\$category.ps1"
            if (Test-Path $categoryFile) {
                . $categoryFile
                $toolRegistry[$category] = $categoryTools
            } else {
                Write-Log "Category file not found: $categoryFile" -Level WARN
            }
        }
    } else {
        # Import all categories
        Get-ChildItem "$scriptRoot\ToolRegistry\*.ps1" | ForEach-Object {
            . $_
            $categoryName = $_.BaseName
            $toolRegistry[$categoryName] = $categoryTools
        }
    }
    
    # Get tools to install
    $toolsToInstall = Get-ToolsToInstall -ToolRegistry $toolRegistry -Categories $Categories -Tools $Tools
    
    # Install tools with progress bar
    $installationResults = Install-Tools -ToolsToInstall $toolsToInstall `
        -MethodsOrder $methodsOrder `
        -AvailableMethods $availableMethods `
        -Force:$Force `
        -MaxRetries $MaxRetries `
        -InstallPath $InstallPath
    
    # Show summary
    Show-Summary -InstallationResults $installationResults -ToolsToInstall $toolsToInstall
    
} catch {
    Write-Log "Script failed with error: $_" -Level ERROR
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level DEBUG
    exit 1
}


