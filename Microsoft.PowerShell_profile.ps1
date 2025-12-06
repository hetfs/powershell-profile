# ====================================================================
# Microsoft.PowerShell_profile.ps1 - Modular Profile Loader
# ====================================================================
# Version 2.2 - Fixed Module Loading & Tracking
# This is the main entry point that loads all modules in correct order

# Enable strict error handling for debugging
Set-StrictMode -Version Latest

try {
    # ----- 1. SETUP PATHS -----
    $ProfileDir = Split-Path $PROFILE -Parent
    $ModulesDir = Join-Path $ProfileDir "Modules"
    
    # ----- 2. VERIFY STRUCTURE -----
    if (-not (Test-Path $ModulesDir)) {
        Write-Warning "❌ Modules directory not found at: $ModulesDir"
        Write-Host "   Please run Setup-Modular.ps1 to install the profile" -ForegroundColor Yellow
        return
    }
    
    # ----- 3. DEFINE COMPLETE MODULE LOAD ORDER (ALL 16 MODULES) -----
    # All 16 modules in exact dependency order - ProfileConfig MUST be first
    $AllModules = @(
        "ProfileConfig.ps1",      # MUST BE FIRST: Configuration & globals
        "CoreFunctions.ps1",      # Basic utilities needed by other modules
        "DebugModule.ps1",        # Debug functionality
        "UpdateModule.ps1",       # Update checks
        "AdminModule.ps1",        # Admin functions & prompt
        "EditorModule.ps1",       # Editor configuration
        "NetworkModule.ps1",      # Network tools
        "SystemModule.ps1",       # System information
        "GitModule.ps1",         # Git integration
        "NavigationModule.ps1",   # Directory navigation
        "UtilityModule.ps1",      # General utilities
        "PSReadLineModule.ps1",   # Command line enhancements
        "CompletionModule.ps1",   # Auto-completion
        "ThemeModule.ps1",        # Prompt theming
        "ZoxideModule.ps1",       # Smart directory (z)
        "HelpModule.ps1"         # Help system
    )
    
    # ----- 4. LOAD ALL MODULES IN ORDER WITH PROPER TRACKING -----
    $global:loadedModules = @()
    $global:failedModules = @()
    $criticalError = $false
    
    foreach ($moduleFile in $AllModules) {
        $modulePath = Join-Path $ModulesDir $moduleFile
        
        # Special handling for ProfileConfig - it's critical
        if ($moduleFile -eq "ProfileConfig.ps1") {
            if (Test-Path $modulePath) {
                try {
                    . $modulePath
                    $global:loadedModules += $moduleFile
                    
                    # Debug message only after debug variable is set
                    if ($global:debug) { 
                        Write-Host "✓ Loaded (CRITICAL): $moduleFile" -ForegroundColor DarkGray 
                    }
                }
                catch {
                    Write-Error "❌ CRITICAL: Failed to load $moduleFile`: $_"
                    $global:failedModules += @{File = $moduleFile; Error = $_; Critical = $true}
                    $criticalError = $true
                }
            } else {
                Write-Error "❌ CRITICAL: Missing $moduleFile - Profile cannot load"
                $global:failedModules += @{File = $moduleFile; Error = "File not found"; Critical = $true}
                $criticalError = $true
            }
            
            # If ProfileConfig failed, stop loading other modules
            if ($criticalError) {
                Write-Host "   Profile loading aborted due to critical error." -ForegroundColor Red
                return
            }
            continue
        }
        
        # Load all other modules
        if (Test-Path $modulePath) {
            try {
                . $modulePath
                $global:loadedModules += $moduleFile
                
                if ($global:debug) {
                    Write-Host "✓ Loaded: $moduleFile" -ForegroundColor DarkGray
                }
            }
            catch {
                $errorMsg = "Failed to load $moduleFile`: $_"
                $global:failedModules += @{File = $moduleFile; Error = $_; Critical = $false}
                Write-Warning $errorMsg
            }
        } else {
            $global:failedModules += @{File = $moduleFile; Error = "File not found"; Critical = $false}
            Write-Warning "Missing module: $moduleFile"
        }
    }
    
    # ----- 5. LOAD CUSTOM OVERRIDES -----
    $CustomPath = Join-Path $ProfileDir "HFcustom.ps1"
    if (Test-Path $CustomPath) {
        try {
            . $CustomPath
            if ($global:debug) { Write-Host "✓ Loaded: HFcustom.ps1" -ForegroundColor DarkGray }
        }
        catch {
            Write-Warning "Failed to load customizations: $_"
        }
    }
    
    # ----- 6. INITIALIZE EXTERNAL TOOLS -----
    # Initialize Starship prompt if installed
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        try {
            Invoke-Expression (&starship init powershell)
            if ($global:debug) { Write-Host "✓ Initialized: Starship" -ForegroundColor DarkGray }
        }
        catch {
            Write-Warning "Starship initialization failed: $_"
        }
    }
    
    # Initialize zoxide if installed
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        try {
            Invoke-Expression (& { (zoxide init powershell | Out-String) })
            if ($global:debug) { Write-Host "✓ Initialized: zoxide" -ForegroundColor DarkGray }
        }
        catch {
            Write-Warning "zoxide initialization failed: $_"
        }
    }
    
    # ----- 7. LOAD MACHINE-SPECIFIC CONFIG -----
    $MachineConfig = Join-Path $ProfileDir "CTTcustom-$($env:COMPUTERNAME).ps1"
    if (Test-Path $MachineConfig) {
        . $MachineConfig
        if ($global:debug) { Write-Host "✓ Loaded: Machine-specific config" -ForegroundColor DarkGray }
    }
    
    # ----- 8. FINAL STATUS WITH ACCURATE COUNTING -----
    if ($global:debug) {
        Write-Host "`n📊 PROFILE LOAD REPORT:" -ForegroundColor Cyan
        Write-Host "   Expected modules: $($AllModules.Count)" -ForegroundColor White
        Write-Host "   Successfully loaded: $($global:loadedModules.Count)" -ForegroundColor Green
        
        if ($global:failedModules.Count -gt 0) {
            Write-Host "   Failed to load: $($global:failedModules.Count)" -ForegroundColor Yellow
            foreach ($failed in $global:failedModules) {
                $criticalFlag = if ($failed.Critical) { "[CRITICAL]" } else { "" }
                Write-Host "     $criticalFlag $($failed.File): $($failed.Error)" -ForegroundColor Red
            }
        }
        
        # List all loaded modules in order
        Write-Host "`n   Loaded modules (in order):" -ForegroundColor White
        $global:loadedModules | ForEach-Object { Write-Host "     • $_" -ForegroundColor Gray }
    } elseif ($global:failedModules.Count -eq 0) {
        Write-Host "✨ Modular PowerShell Profile loaded successfully!" -ForegroundColor Green
        Write-Host "   ($($global:loadedModules.Count)/$($AllModules.Count) modules loaded)" -ForegroundColor Gray
        Write-Host "ℹ️  Use 'Show-Help' to see available commands" -ForegroundColor Yellow
    } else {
        $nonCriticalFailures = $global:failedModules | Where-Object { -not $_.Critical }
        if ($nonCriticalFailures.Count -gt 0) {
            Write-Host "⚠️  Profile loaded with $($nonCriticalFailures.Count) non-critical module failures" -ForegroundColor Yellow
            Write-Host "   ($($global:loadedModules.Count)/$($AllModules.Count) modules loaded successfully)" -ForegroundColor Gray
        }
    }
    
}
catch {
    Write-Error "❌ CRITICAL ERROR loading profile: $_"
    Write-Host "   Please run verification: .\Scripts\verify-installation.ps1" -ForegroundColor Red
}
