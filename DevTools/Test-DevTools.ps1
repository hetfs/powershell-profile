<#
.SYNOPSIS
    DevTools End-to-End Test Harness (Dry-Run)
.DESCRIPTION
    - Loads helpers, logging, and environment modules
    - Loads categories and tool registry files
    - Runs Install-Tools.ps1 in DryRun mode
    - Validates all tools, installers, and package managers
#>

# ----------------------------------------------------
# Strict mode and error handling
# ----------------------------------------------------
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ----------------------------------------------------
# Resolve paths
# ----------------------------------------------------
$RootPath        = $PSScriptRoot
$SharedPath      = Join-Path $RootPath 'Shared'
$ConfigPath      = Join-Path $RootPath 'Config'
$ToolsRegistryPath = Join-Path $RootPath 'ToolsRegistry'
$InstallersPath  = Join-Path $RootPath 'Installers'
$OutputPath      = Join-Path $RootPath 'Output'

# Ensure Output directory exists
if (-not (Test-Path -LiteralPath $OutputPath)) { 
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

# ----------------------------------------------------
# Load core modules
# ----------------------------------------------------
$ModulesToLoad = @('Helpers.ps1','Logging.ps1','Environment.ps1')

foreach ($module in $ModulesToLoad) {
    $modulePath = Join-Path $SharedPath $module
    if (-not (Test-Path -LiteralPath $modulePath)) { 
        throw "Module missing: $modulePath" 
    }
    . $modulePath
    Write-Host "✔ Loaded module $module"
}

# ----------------------------------------------------
# Initialize logging
# ----------------------------------------------------
$LogFile   = Join-Path $OutputPath 'Test-DevTools.log'
$LogConfig = Initialize-DevToolsLogging -LogPath $LogFile -MinimumLevel 'DEBUG'
Start-LoggingSession -Config $LogConfig
Write-Log -Config $LogConfig -Level INFO -Message "DevTools Test Harness started"

# ----------------------------------------------------
# Initialize environment context
# ----------------------------------------------------
$EnvContext = Initialize-DevToolsEnvironment `
    -RootPath $RootPath `
    -InstallersPath $InstallersPath `
    -ConfigPath $ConfigPath `
    -OutputPath $OutputPath `
    -ToolsRegistryPath $ToolsRegistryPath

Write-Log -Config $LogConfig -Level INFO -Message "Environment initialized successfully"

# ----------------------------------------------------
# Load categories
# ----------------------------------------------------
$CategoriesFile = Join-Path $ConfigPath 'categories.ps1'
if (-not (Test-Path -LiteralPath $CategoriesFile)) { throw "Categories config not found: $CategoriesFile" }

$Categories = & $CategoriesFile
if ($Categories -isnot [PSCustomObject]) { 
    throw "categories.ps1 must return a PSCustomObject" 
}
Write-Log -Config $LogConfig -Level SUCCESS -Message ("Loaded categories: " + ($Categories.PSObject.Properties.Name -join ', '))

# ----------------------------------------------------
# Load and validate all tool registry files
# ----------------------------------------------------
if (-not (Test-Path -LiteralPath $ToolsRegistryPath)) { throw "ToolsRegistry path not found: $ToolsRegistryPath" }

$AllTools = @()
$ToolFiles = Get-ChildItem -Path $ToolsRegistryPath -Filter '*.ps1' -File

if (-not $ToolFiles) { throw "No tool files found in ToolsRegistry" }

foreach ($file in $ToolFiles) {
    try {
        $toolsFromFile = & $file.FullName

        if ($toolsFromFile -is [PSCustomObject]) { 
            $toolsFromFile = @($toolsFromFile) 
        }

        if ($toolsFromFile -is [System.Collections.IEnumerable]) {
            $validTools = $toolsFromFile | Where-Object { $_ -is [PSCustomObject] -and $_.PSObject.Properties.Name -contains 'Name' }
            if ($validTools.Count -eq 0) {
                Write-Log -Config $LogConfig -Level WARNING -Message "Invalid tool object in $($file.Name)"
            } else {
                $AllTools += $validTools
                Write-Log -Config $LogConfig -Level DEBUG -Message "Loaded $($validTools.Count) tools from $($file.Name)"
            }
        }
        else {
            Write-Log -Config $LogConfig -Level WARNING -Message "Invalid tool object in $($file.Name)"
        }
    }
    catch {
        Write-Log -Config $LogConfig -Level ERROR -Message "Failed to load $($file.Name): $_"
    }
}

if (-not $AllTools.Count) {
    Write-Log -Config $LogConfig -Level ERROR -Message "No valid tools found in ToolsRegistry"
    Stop-LoggingSession -Config $LogConfig
    throw "Test aborted: no tools to test"
}

Write-Log -Config $LogConfig -Level SUCCESS -Message ("Total tools loaded: $($AllTools.Count)")

# ----------------------------------------------------
# Optional category filter for test
# ----------------------------------------------------
$CategoryFilter = @('Editors','CoreShell')  # example, adjust as needed
$FilteredTools = $AllTools
if ($CategoryFilter) {
    $FilteredTools = $AllTools | Where-Object { $_.Category -in $CategoryFilter }
    Write-Log -Config $LogConfig -Level INFO -Message ("Filtered tools by category: " + ($CategoryFilter -join ', '))
}

if (-not $FilteredTools.Count) {
    Write-Log -Config $LogConfig -Level ERROR -Message "No tools remain after filtering"
    Stop-LoggingSession -Config $LogConfig
    throw "Test aborted: no tools remain after filtering"
}

# ----------------------------------------------------
# Run Install-Tools.ps1 in DryRun mode
# ----------------------------------------------------
$InstallerPath = Join-Path $InstallersPath 'Install-Tools.ps1'
if (-not (Test-Path -LiteralPath $InstallerPath)) { throw "Install engine not found: $InstallerPath" }

Write-Log -Config $LogConfig -Level INFO -Message "Running Install-Tools.ps1 in DryRun mode"

$Results = & $InstallerPath `
    -Tools $FilteredTools `
    -Category $CategoryFilter `
    -Context @{ RootPath = $RootPath; Categories = $Categories } `
    -EnvContext $EnvContext `
    -DryRun

# ----------------------------------------------------
# Validate DryRun results
# ----------------------------------------------------
$ValidationPassed = $true

foreach ($toolGroup in $Results | Group-Object Name) {
    Write-Host "`n🔹 Tool: $($toolGroup.Name)" -ForegroundColor Cyan
    foreach ($entry in $toolGroup.Group) {
        $status = $entry.Status
        $installer = $entry.Installer

        if ($status -notin @('DryRun','AlreadyInstalled')) {
            Write-Log -Config $LogConfig -Level ERROR -Message "Tool '$($entry.Name)' failed dry-run: Installer='$installer' Status='$status'"
            $ValidationPassed = $false
        } else {
            Write-Log -Config $LogConfig -Level SUCCESS -Message "Tool '$($entry.Name)' DryRun OK: Installer='$installer' Status='$status'"
        }
    }
}

# ----------------------------------------------------
# Summary
# ----------------------------------------------------
Write-Host "`n🔹 DevTools Dry-Run Validation Report"
$Results | Format-Table Name, Installer, Status, Category, ToolType -AutoSize

if ($ValidationPassed) {
    Write-Log -Config $LogConfig -Level SUCCESS -Message "All tools validated successfully in dry-run mode"
} else {
    Write-Log -Config $LogConfig -Level ERROR -Message "Some tools failed dry-run validation; check logs"
}

Stop-LoggingSession -Config $LogConfig
Write-Host "`n✅ DevTools dry-run execution completed."
