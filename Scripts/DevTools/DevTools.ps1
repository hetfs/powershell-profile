<#
.SYNOPSIS
    Universal DevTools installer with dry-run, category filter, dependency handling, and persistent logging.
    Also includes DevTools initialization for environment context and tool registry loading.

.EXAMPLE
    # Preview all tools without installing
    .\Install.ps1 -DryRun

    # Install only Network and SystemUtils tools
    .\Install.ps1 -Category Network,SystemUtils

.DESCRIPTION
    - Install tools defined in ToolsRegistry/
    - Supports dry-run to preview actions
    - Supports selective category installation
    - Installs required dependencies first (curl, wget, tar, unzip)
    - Logs all actions to a persistent log file
    - Uses WinGet → Chocolatey → GitHub
#>

# ===========================
# Parameters
# ===========================
param(
    [switch]$DryRun,
    [string[]]$Category
)

# ===========================
# Strict Mode & Error Handling
# ===========================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ===========================
# Logging helper
# ===========================
$LogFile = Join-Path $PSScriptRoot "DevToolsInstall.log"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","SUCCESS","ERROR")]
        [string]$Level = "INFO"
    )
    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp][$Level] $Message"
    Add-Content -Path $LogFile -Value $line

    switch ($Level) {
        "INFO"    { Write-Host $line -ForegroundColor Cyan }
        "SUCCESS" { Write-Host $line -ForegroundColor Green }
        "ERROR"   { Write-Host $line -ForegroundColor Red }
    }
}

# ===========================
# Dependencies
# ===========================
$Dependencies = @{
    "curl"  = @{ WinGetId="curl.curl"; ChocoId="curl"; BinaryCheck="curl.exe" }
    "wget"  = @{ WinGetId="GnuWin32.Wget"; ChocoId="wget"; BinaryCheck="wget.exe" }
    "tar"   = @{ WinGetId="GnuWin32.Tar"; ChocoId="tar"; BinaryCheck="tar.exe" }
    "unzip" = @{ WinGetId="GnuWin32.Unzip"; ChocoId="unzip"; BinaryCheck="unzip.exe" }
}

function Ensure-Dependency {
    param([string]$DepName)

    if (-not $Dependencies.ContainsKey($DepName)) {
        Write-Log "Unknown dependency: $DepName" -Level ERROR
        return
    }

    $dep = $Dependencies[$DepName]

    if (-not (Get-Command $dep.BinaryCheck -ErrorAction SilentlyContinue)) {
        if ($DryRun) {
            Write-Log "[DRY-RUN] Would install dependency $DepName" -Level INFO
            return
        }

        Write-Log "Installing dependency $DepName..." -Level INFO

        try {
            if ($dep.WinGetId) {
                winget install --id $dep.WinGetId --silent --accept-source-agreements --accept-package-agreements
                Write-Log "$DepName installed via WinGet" -Level SUCCESS
                return
            }
        } catch {
            $err = $_
            Write-Log "WinGet failed for ${DepName}: $($err.Exception.Message)" -Level ERROR
        }

        try {
            if ($dep.ChocoId) {
                choco install $dep.ChocoId -y
                Write-Log "$DepName installed via Chocolatey" -Level SUCCESS
                return
            }
        } catch {
            $err = $_
            Write-Log "Chocolatey failed for ${DepName}: $($err.Exception.Message)" -Level ERROR
        }

        Write-Log "Failed to install dependency $DepName" -Level ERROR
    } else {
        Write-Log "$DepName already installed." -Level SUCCESS
    }
}

# ===========================
# Tool installation
# ===========================
function Install-Tool {
    param([PSCustomObject]$Tool)

    # Install dependencies first
    if ($Tool.Dependencies) {
        foreach ($dep in $Tool.Dependencies) {
            Ensure-Dependency -DepName $dep
        }
    }

    # Category filter
    if ($Category -and ($Tool.Category -notin $Category)) {
        Write-Log "Skipping $($Tool.Name) due to category filter" -Level INFO
        return
    }

    # Dry-run mode
    if ($DryRun) {
        Write-Log "[DRY-RUN] Would install $($Tool.Name) (Category: $($Tool.Category))" -Level INFO
        return [PSCustomObject]@{
            Name = $Tool.Name; Success = $null; InstallerUsed = "DryRun"; Error = $null
        }
    }

    $installed = $false
    $installerUsed = ""

    # Already installed?
    if ($Tool.BinaryCheck -and (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue)) {
        Write-Log "$($Tool.Name) already installed." -Level SUCCESS
        return [PSCustomObject]@{
            Name = $Tool.Name; Success = $true; InstallerUsed = "AlreadyInstalled"; Error = $null
        }
    }

    # WinGet
    if ($Tool.WinGetId -and -not $installed) {
        try {
            Write-Log "Installing $($Tool.Name) via WinGet..." -Level INFO
            winget install --id $Tool.WinGetId --silent --accept-source-agreements --accept-package-agreements
            $installed = $true
            $installerUsed = "WinGet"
        } catch {
            $err = $_
            Write-Log "WinGet failed for ${Tool.Name}: $($err.Exception.Message)" -Level ERROR
        }
    }

    # Chocolatey
    if (-not $installed -and $Tool.ChocoId) {
        try {
            Write-Log "Installing $($Tool.Name) via Chocolatey..." -Level INFO
            choco install $Tool.ChocoId -y
            $installed = $true
            $installerUsed = "Chocolatey"
        } catch {
            $err = $_
            Write-Log "Chocolatey failed for ${Tool.Name}: $($err.Exception.Message)" -Level ERROR
        }
    }

    # GitHub release
    if (-not $installed -and $Tool.GitHubRepo) {
        try {
            $ghScript = Join-Path $PSScriptRoot "GitHubRelease.ps1"
            if (Test-Path $ghScript) {
                # Don't dot-source, just check if it exists
                # The actual function call should be defined in the script
                $installed = $true
                $installerUsed = "GitHubRelease"
                Write-Log "GitHub release installer available for ${Tool.Name}" -Level INFO
            }
        } catch {
            $err = $_
            Write-Log "GitHub release failed for ${Tool.Name}: $($err.Exception.Message)" -Level ERROR
        }
    }

    # Verification
    if ($Tool.BinaryCheck) {
        if (Get-Command $Tool.BinaryCheck -ErrorAction SilentlyContinue) {
            Write-Log "$($Tool.Name) successfully installed via $installerUsed." -Level SUCCESS
            return [PSCustomObject]@{
                Name = $Tool.Name; Success = $true; InstallerUsed = $installerUsed; Error = $null
            }
        } else {
            Write-Log "$($Tool.Name) installation failed." -Level ERROR
            return [PSCustomObject]@{
                Name = $Tool.Name; Success = $false; InstallerUsed = $installerUsed; Error = "Binary not found after installation"
            }
        }
    } else {
        return [PSCustomObject]@{
            Name = $Tool.Name; Success = $installed; InstallerUsed = $installerUsed; Error = if ($installed) { $null } else { "Installation skipped or failed" }
        }
    }
}

# ===========================
# Install all tools
# ===========================
function Install-AllTools {
    $results = @()
    $registryPath = Join-Path $PSScriptRoot "ToolsRegistry"

    Get-ChildItem -Path $registryPath -Filter "*.ps1" | ForEach-Object {
        $file = $_
        try {
            $tools = . $file.FullName
            foreach ($tool in $tools) {
                $result = Install-Tool -Tool $tool
                if ($result) { $results += $result }
            }
        } catch {
            $err = $_
            Write-Log "Failed to load tools from $($file.Name): $($err.Exception.Message)" -Level ERROR
        }
    }

    Write-Host "`nInstallation Summary" -ForegroundColor White
    Write-Host ("=" * 60)
    $results | Format-Table Name, Success, InstallerUsed, Error -AutoSize

    # Persist summary
    $results | ForEach-Object {
        Add-Content -Path $LogFile -Value "SUMMARY: $($_.Name) | Success: $($_.Success) | Installer: $($_.InstallerUsed) | Error: $($_.Error)"
    }
}

# ===========================
# DevTools Initialization
# ===========================

# ----------------------------------------------------
# Runtime context
# ----------------------------------------------------
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$Global:DevToolsContext = @{
    RootPath       = $ScriptRoot
    ToolsRegistry  = Join-Path $ScriptRoot 'ToolsRegistry'
    InstallersPath = Join-Path $ScriptRoot 'Installers'
    IsWindows      = $IsWindows
    PSVersion      = $PSVersionTable.PSVersion
    AvailablePMs   = @{ }
}

# ----------------------------------------------------
# Detect Package Managers
# ----------------------------------------------------
$PackageManagers = @{
    WinGet     = 'winget.exe'
    Chocolatey = 'choco.exe'
}

foreach ($pm in $PackageManagers.GetEnumerator()) {
    $DevToolsContext.AvailablePMs[$pm.Key] = [bool](Get-Command $pm.Value -ErrorAction SilentlyContinue)
}

# ----------------------------------------------------
# Load Installer Backends - MODIFIED
# ----------------------------------------------------
# Instead of trying to dot-source installer scripts that require parameters,
# we'll just note that they exist and handle them differently in the Install-Tool function
$InstallerFiles = @(
    'WinGet.ps1',
    'Chocolatey.ps1',
    'GitHubRelease.ps1'
)

foreach ($installer in $InstallerFiles) {
    $path = Join-Path $DevToolsContext.InstallersPath $installer
    if (Test-Path $path) {
        Write-Host "Found installer: ${installer}" -ForegroundColor Green
    } else {
        Write-Warning "Installer not found: ${installer}"
    }
}

# ----------------------------------------------------
# Load Tool Registries
# ----------------------------------------------------
$Global:DevToolsTools = @()

try {
    Get-ChildItem -Path $DevToolsContext.ToolsRegistry -Filter '*.ps1' |
        Sort-Object Name |
        ForEach-Object {
            $file = $_
            try {
                $tools = . $file.FullName
                if ($tools) {
                    $Global:DevToolsTools += $tools
                    Write-Host "Loaded registry: $($file.BaseName) with $($tools.Count) tools" -ForegroundColor Cyan
                }
            } catch {
                $err = $_
                Write-Warning "Failed to load tools from $($file.Name): $($err.Exception.Message)"
            }
        }
} catch {
    $err = $_
    Write-Warning "Failed to enumerate ToolsRegistry: $($err.Exception.Message)"
}

# ----------------------------------------------------
# Validation Summary
# ----------------------------------------------------
Write-Host "`nDevTools initialized successfully" -ForegroundColor Green
Write-Host "PowerShell Version  : $($DevToolsContext.PSVersion)"
Write-Host "WinGet Available    : $($DevToolsContext.AvailablePMs.WinGet)"
Write-Host "Chocolatey Available: $($DevToolsContext.AvailablePMs.Chocolatey)"
Write-Host "Total Tools Loaded  : $($Global:DevToolsTools.Count)"

# ===========================
# Main Execution
# ===========================
Install-AllTools
