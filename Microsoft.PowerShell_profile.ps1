### PowerShell Profile Refactor
### Version 2.0 - Modular Structure

# Load Configuration
. $PSScriptRoot\Modules\ProfileConfig.ps1

# Import Modules in Load Order
$modulesToLoad = @(
    "CoreFunctions",
    "DebugModule",
    "UpdateModule", 
    "AdminModule",
    "EditorModule",
    "NetworkModule",
    "SystemModule",
    "GitModule",
    "NavigationModule",
    "UtilityModule",
    "PSReadLineModule",
    "CompletionModule",
    "ThemeModule",
    "ZoxideModule",
    "HelpModule"
)

# Load each module
foreach ($module in $modulesToLoad) {
    try {
        $modulePath = Join-Path $PSScriptRoot "Modules\$module.psm1"
        if (Test-Path $modulePath) {
            . $modulePath
            Write-Verbose "Loaded module: $module" -Verbose:$global:debug
        } else {
            Write-Warning "Module not found: $module"
        }
    }
    catch {
        Write-Error "Failed to load module $($module): $_"
    }
}

# Load Custom Overrides (if any)
if (Test-Path "$PSScriptRoot\CTTcustom.ps1") {
    . "$PSScriptRoot\CTTcustom.ps1"
}

# Final message
if (-not $global:debug) {
    Write-Host "$($PSStyle.Foreground.Yellow)Use 'Show-Help' to display help$($PSStyle.Reset)"
}
