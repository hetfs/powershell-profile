# ====================================================================
# Setup-Modular.ps1 - Complete Modular PowerShell Profile Installer
# ====================================================================
# Run this script to automatically download and configure everything

param(
    [switch]$Force,      # Force overwrite existing files
    [switch]$NoProgress  # Disable progress bars
)

# Set error and progress preferences
$ErrorActionPreference = 'Stop'
if ($NoProgress) { $ProgressPreference = 'SilentlyContinue' }

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "🚀  MODULAR POWERSHELL PROFILE - COMPLETE SETUP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Configuration
$ProfileBase = "$HOME\Documents\PowerShell"
$ModulesDir = "$ProfileBase\Modules"
$ScriptsDir = "$ProfileBase\Scripts"
$RepoBase = "https://raw.githubusercontent.com/hetfs/powershell-profile/main"

# List of ALL required files
$RequiredFiles = @{
    # Main profile
    "MainProfile" = @{
        Url = "$RepoBase/Microsoft.PowerShell_profile.ps1"
        Dest = "$ProfileBase\Microsoft.PowerShell_profile.ps1"
    }
    
    # All 16 modules
    "Modules" = @(
        @{File = "ProfileConfig.ps1"; Desc = "Configuration Settings"},
        @{File = "CoreFunctions.ps1"; Desc = "Core Utility Functions"},
        @{File = "DebugModule.ps1"; Desc = "Debug Mode Handler"},
        @{File = "UpdateModule.ps1"; Desc = "Update Functions"},
        @{File = "AdminModule.ps1"; Desc = "Admin Tools & Prompt"},
        @{File = "EditorModule.ps1"; Desc = "Editor Configuration"},
        @{File = "NetworkModule.ps1"; Desc = "Network Utilities"},
        @{File = "SystemModule.ps1"; Desc = "System Information"},
        @{File = "GitModule.ps1"; Desc = "Git Shortcuts"},
        @{File = "NavigationModule.ps1"; Desc = "Directory Navigation"},
        @{File = "UtilityModule.ps1"; Desc = "General Utilities"},
        @{File = "PSReadLineModule.ps1"; Desc = "Command Line Enhancements"},
        @{File = "CompletionModule.ps1"; Desc = "Auto-Completion"},
        @{File = "ThemeModule.ps1"; Desc = "Prompt Theming"},
        @{File = "ZoxideModule.ps1"; Desc = "Smart Directory Navigation"},
        @{File = "HelpModule.ps1"; Desc = "Help System"}
    )
    
    # Support files
    "Support" = @(
        @{File = "verify-installation.ps1"; Dest = "$ScriptsDir\verify-installation.ps1"; Desc = "Verification Script"}
    )
}

# Function: Create directory if it doesn't exist
function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Host "  Creating directory: $Path" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# Function: Download file with retry logic
function Get-WebFile {
    param(
        [string]$Url,
        [string]$Destination,
        [int]$Retries = 3
    )
    
    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Write-Host "  Downloading attempt $i/$Retries..." -ForegroundColor Gray
            Invoke-WebRequest -Uri $Url -OutFile $Destination -ErrorAction Stop
            return $true
        }
        catch {
            if ($i -eq $Retries) {
                Write-Host "    ❌ Download failed: $_" -ForegroundColor Red
                return $false
            }
            Start-Sleep -Seconds 2
        }
    }
    return $false
}

# ==================== MAIN SETUP ROUTINE ====================

Write-Host "`n📁 STEP 1: Creating directory structure..." -ForegroundColor Yellow
Ensure-Directory -Path $ProfileBase
Ensure-Directory -Path $ModulesDir
Ensure-Directory -Path $ScriptsDir

# Track results
$Results = @{
    Total = 0
    Success = 0
    Failed = 0
    Skipped = 0
}

Write-Host "`n📥 STEP 2: Downloading modules..." -ForegroundColor Yellow
foreach ($module in $RequiredFiles.Modules) {
    $Results.Total++
    $filename = $module.File
    $destPath = Join-Path $ModulesDir $filename
    
    # Check if file already exists
    if (Test-Path $destPath -and -not $Force) {
        Write-Host "  ⚠️  Skipping (exists): $filename" -ForegroundColor Gray
        $Results.Skipped++
        continue
    }
    
    Write-Host "  📄 Downloading: $($module.Desc)..." -ForegroundColor Cyan -NoNewline
    
    $url = "$RepoBase/Modules/$filename"
    if (Get-WebFile -Url $url -Destination $destPath) {
        Write-Host " ✅" -ForegroundColor Green
        $Results.Success++
    } else {
        Write-Host " ❌" -ForegroundColor Red
        $Results.Failed++
    }
}

Write-Host "`n📋 STEP 3: Downloading main profile..." -ForegroundColor Yellow
$Results.Total++
$mainProfile = $RequiredFiles.MainProfile
if (Test-Path $mainProfile.Dest -and -not $Force) {
    Write-Host "  ⚠️  Skipping (exists): Main profile" -ForegroundColor Gray
    $Results.Skipped++
} else {
    Write-Host "  📝 Downloading main profile..." -ForegroundColor Cyan -NoNewline
    if (Get-WebFile -Url $mainProfile.Url -Destination $mainProfile.Dest) {
        Write-Host " ✅" -ForegroundColor Green
        $Results.Success++
    } else {
        Write-Host " ❌" -ForegroundColor Red
        $Results.Failed++
    }
}

Write-Host "`n🔧 STEP 4: Downloading support files..." -ForegroundColor Yellow
foreach ($file in $RequiredFiles.Support) {
    $Results.Total++
    if (Test-Path $file.Dest -and -not $Force) {
        Write-Host "  ⚠️  Skipping (exists): $($file.Desc)" -ForegroundColor Gray
        $Results.Skipped++
    } else {
        Write-Host "  🔧 Downloading: $($file.Desc)..." -ForegroundColor Cyan -NoNewline
        $url = "$RepoBase/Scripts/$($file.File)"
        if (Get-WebFile -Url $url -Destination $file.Dest) {
            Write-Host " ✅" -ForegroundColor Green
            $Results.Success++
        } else {
            Write-Host " ❌" -ForegroundColor Red
            $Results.Failed++
        }
    }
}

Write-Host "`n🎨 STEP 5: Creating customization file..." -ForegroundColor Yellow
$customFile = "$ProfileBase\HFCustom.ps1"
if (-not (Test-Path $customFile)) {
    $customContent = @'
# ====================================================================
# HFCustom.ps1 - Personal Customizations
# ====================================================================
# This file loads AFTER all modules, allowing you to override anything
# Changes here WON'T be overwritten by profile updates

# ----- VARIABLE OVERRIDES -----
# Uncomment and modify as needed:

# $debug_Override = $true              # Enable debug mode
# $EDITOR_Override = "code"            # Change default editor
# $updateInterval_Override = 14        # Check updates every 2 weeks
# $repo_root_Override = "https://github.com/hetfs/powershell-profile" # Your repository

# ----- CUSTOM FUNCTIONS -----
function proj {
    # Quick navigation to projects folder
    $projectsDir = "$HOME\Projects"
    if (-not (Test-Path $projectsDir)) {
        New-Item -ItemType Directory -Path $projectsDir -Force | Out-Null
    }
    Set-Location $projectsDir
    Write-Host "📁 Projects directory" -ForegroundColor Green
}

function sysinfo-enhanced {
    # Enhanced system information
    Write-Host "🖥️  SYSTEM INFORMATION" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    $info = Get-ComputerInfo
    $info | Select-Object WindowsProductName, WindowsVersion, OsArchitecture, 
                          CsNumberOfProcessors, CsTotalPhysicalMemory | Format-List
}

# ----- CUSTOM ALIASES -----
Set-Alias -Name home -Value { Set-Location $HOME }
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name ll -Value Get-ChildItem

# ----- ENVIRONMENT VARIABLES -----
# $env:EDITOR = "nvim"
# $env:PAGER = "less"

# ----- LOAD MACHINE-SPECIFIC SETTINGS -----
$machineFile = "$PSScriptRoot\HFCustom-$($env:COMPUTERNAME).ps1"
if (Test-Path $machineFile) {
    . $machineFile
}

Write-Host "✨ Custom profile loaded!" -ForegroundColor Green
'@
    
    $customContent | Out-File -FilePath $customFile -Encoding UTF8
    Write-Host "  ✅ Created: HFCustom.ps1" -ForegroundColor Green
    $Results.Success++
} else {
    Write-Host "  ⚠️  Already exists: HFCustom.ps1" -ForegroundColor Gray
}

# ==================== FINALIZATION ====================

Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "📊 SETUP COMPLETE - SUMMARY" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

Write-Host "✅ Successfully installed: $($Results.Success) files" -ForegroundColor Green
if ($Results.Failed -gt 0) {
    Write-Host "❌ Failed downloads: $($Results.Failed) files" -ForegroundColor Red
}
if ($Results.Skipped -gt 0) {
    Write-Host "⚠️  Skipped (already exist): $($Results.Skipped) files" -ForegroundColor Yellow
}

Write-Host "`n📁 PROFILE STRUCTURE:" -ForegroundColor White
Write-Host "  $ProfileBase\" -ForegroundColor Gray
Write-Host "  ├── Microsoft.PowerShell_profile.ps1" -ForegroundColor Gray
Write-Host "  ├── HFCustom.ps1 (Your customizations)" -ForegroundColor Gray
Write-Host "  ├── Modules\ (16 organized modules)" -ForegroundColor Gray
Write-Host "  └── Scripts\" -ForegroundColor Gray

Write-Host "`n🚀 IMMEDIATE ACTIONS:" -ForegroundColor Yellow
Write-Host "  1. Reload profile: . `$PROFILE" -ForegroundColor White
Write-Host "  2. Verify installation: .\Scripts\verify-installation.ps1" -ForegroundColor White
Write-Host "  3. Get help: Show-Help" -ForegroundColor White

Write-Host "`n🔧 NEXT STEPS FOR CUSTOMIZATION:" -ForegroundColor Cyan
Write-Host "  • Edit HFCustom.ps1 to add personal settings" -ForegroundColor White
Write-Host "  • Add functions to UtilityModule.ps1 for shared utilities" -ForegroundColor White
Write-Host "  • Use module overrides for advanced customization" -ForegroundColor White

Write-Host "`n💡 TIPS:" -ForegroundColor Magenta
Write-Host "  • Run with -Force to redownload all files" -ForegroundColor Gray
Write-Host "  • Check for updates: Update-Profile" -ForegroundColor Gray
Write-Host "  • Debug issues: Set `$debug_Override = `$true in HFCustom.ps1" -ForegroundColor Gray

Write-Host "`n📌 USING YOUR REPOSITORY:" -ForegroundColor Cyan
Write-Host "  • Profile sourced from: https://github.com/hetfs/powershell-profile" -ForegroundColor White
Write-Host "  • Update the `$repo_root_Override in HFCustom.ps1 if you fork this" -ForegroundColor White

Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "✨ MODULAR POWERSHELL PROFILE READY!" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Cyan
