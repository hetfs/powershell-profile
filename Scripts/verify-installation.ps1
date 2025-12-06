# Scripts/verify-installation.ps1
# Post-installation verification for Modular PowerShell Profile
# Updated to check for ALL 16 modules with .ps1 extension

param(
    [switch]$Fix,
    [switch]$SummaryOnly,
    [switch]$SkipTools
)

Write-Host "🔍 MODULAR POWERSHELL PROFILE VERIFICATION" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Configuration
$ProfileBase = "$env:USERPROFILE\Documents\PowerShell"
$ModulesDir = "$ProfileBase\Modules"
$ScriptsDir = "$ProfileBase\Scripts"

# Your repository configuration
$RepoBase = "https://raw.githubusercontent.com/hetfs/powershell-profile/main"

# List of ALL 16 module files (with .ps1 extension)
$AllModules = @(
    "ProfileConfig.ps1",
    "CoreFunctions.ps1",
    "DebugModule.ps1", 
    "UpdateModule.ps1",
    "AdminModule.ps1",
    "EditorModule.ps1",
    "NetworkModule.ps1",
    "SystemModule.ps1",
    "GitModule.ps1",
    "NavigationModule.ps1",
    "UtilityModule.ps1",
    "PSReadLineModule.ps1",
    "CompletionModule.ps1",
    "ThemeModule.ps1",
    "ZoxideModule.ps1",
    "HelpModule.ps1"
)

# External tools list
$requiredTools = @(
    @{Name = "git"; Display = "Git"; InstallCommand = "winget install Git.Git --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "starship"; Display = "Starship"; InstallCommand = "winget install starship.starship --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "zoxide"; Display = "zoxide"; InstallCommand = "winget install ajeetdsouza.zoxide --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "rg"; Display = "ripgrep"; InstallCommand = "winget install BurntSushi.ripgrep.MSVC --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "bat"; Display = "bat"; InstallCommand = "winget install sharkdp.bat --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "fd"; Display = "fd"; InstallCommand = "winget install sharkdp.fd --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "eza"; Display = "eza"; InstallCommand = "winget install eza.eza --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "delta"; Display = "delta"; InstallCommand = "winget install dandavison.delta --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "gsudo"; Display = "gsudo"; InstallCommand = "winget install gerardog.gsudo --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "gh"; Display = "GitHub CLI"; InstallCommand = "winget install GitHub.cli --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "lazygit"; Display = "lazygit"; InstallCommand = "winget install JesseDuffield.lazygit --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "nvim"; Display = "Neovim"; InstallCommand = "winget install neovim.neovim --silent --accept-source-agreements --accept-package-agreements"},
    @{Name = "tldr"; Display = "tldr"; InstallCommand = "winget install tealdeer.tealdeer --silent --accept-source-agreements --accept-package-agreements"}
)

# PowerShell modules list
$requiredPowerShellModules = @(
    @{Name = "Terminal-Icons"; Display = "Terminal-Icons"; InstallCommand = "Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser"},
    @{Name = "PSReadLine"; Display = "PSReadLine"; InstallCommand = "Install-Module -Name PSReadLine -Repository PSGallery -Force -Scope CurrentUser"}
)

# Results tracking
$results = @{
    Tools = @()
    PowerShellModules = @()
    ModularFiles = $null
    Fonts = $null
    Profile = $null
    Structure = $null
}

# Function: Test if running as admin
function Test-Admin {
    $currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function: Test for modular profile files (16 modules)
function Test-ModularFiles {
    Write-Host "`n📄 MODULAR FILES (16 required):" -ForegroundColor Yellow
    
    # Check Modules directory
    if (-not (Test-Path $ModulesDir)) {
        if (-not $SummaryOnly) {
            Write-Host "  ❌ Modules directory not found" -ForegroundColor Red
        }
        
        if ($Fix) {
            try {
                New-Item -ItemType Directory -Path $ModulesDir -Force | Out-Null
                Write-Host "    ✅ Created Modules directory" -ForegroundColor Green
            }
            catch {
                Write-Host "    ❌ Failed to create Modules directory" -ForegroundColor Red
            }
        }
        
        $results.ModularFiles = @{
            Status = $false
            Existing = 0
            Total = $AllModules.Count
            MissingFiles = $AllModules
        }
        return
    }
    
    # Check each module file
    $missingFiles = @()
    $existingFiles = @()
    
    foreach ($module in $AllModules) {
        $filePath = Join-Path $ModulesDir $module
        
        if (Test-Path $filePath) {
            $existingFiles += $module
            if (-not $SummaryOnly) {
                Write-Host "  ✅ $module" -ForegroundColor Green
            }
        }
        else {
            $missingFiles += $module
            if (-not $SummaryOnly) {
                Write-Host "  ❌ $module" -ForegroundColor Red
            }
            
            # Auto-fix: Download missing module from YOUR repository
            if ($Fix) {
                Write-Host "    ⬇️  Downloading $module..." -ForegroundColor Yellow
                try {
                    $url = "$RepoBase/Modules/$module"
                    Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop
                    
                    if (Test-Path $filePath) {
                        Write-Host "      ✅ Downloaded successfully from your repository" -ForegroundColor Green
                        $existingFiles += $module
                        $missingFiles = $missingFiles | Where-Object { $_ -ne $module }
                    }
                }
                catch {
                    Write-Host "      ❌ Download failed: $_" -ForegroundColor Red
                    Write-Host "      Trying alternative URL..." -ForegroundColor Yellow
                    
                    # Try alternative URL format if needed
                    try {
                        $altUrl = "https://github.com/hetfs/powershell-profile/raw/main/Modules/$module"
                        Invoke-WebRequest -Uri $altUrl -OutFile $filePath -ErrorAction Stop
                        
                        if (Test-Path $filePath) {
                            Write-Host "      ✅ Downloaded successfully from alternative URL" -ForegroundColor Green
                            $existingFiles += $module
                            $missingFiles = $missingFiles | Where-Object { $_ -ne $module }
                        }
                    }
                    catch {
                        Write-Host "      ❌ Alternative download also failed" -ForegroundColor Red
                    }
                }
            }
        }
    }
    
    $results.ModularFiles = @{
        Status = ($missingFiles.Count -eq 0)
        Existing = $existingFiles.Count
        Total = $AllModules.Count
        MissingFiles = $missingFiles
    }
    
    # Show summary
    if (-not $SummaryOnly) {
        $color = if ($results.ModularFiles.Status) { "Green" } else { "Red" }
        Write-Host "  📊 Found: $($results.ModularFiles.Existing)/$($results.ModularFiles.Total) modules" -ForegroundColor $color
    }
}

# Function: Test for external tools
function Test-CoreTools {
    Write-Host "`n📦 EXTERNAL TOOLS:" -ForegroundColor Yellow
    
    foreach ($tool in $requiredTools) {
        $status = $false
        $message = ""
        
        try {
            $cmd = Get-Command $tool.Name -ErrorAction Stop
            if ($tool.Name -eq "git") {
                $version = & $tool.Name --version 2>$null | Select-Object -First 1
            } else {
                $version = & $tool.Name --version 2>$null | Select-Object -First 1
                if (-not $version) { $version = "Found" }
            }
            $status = $true
            $message = if ($version -match '(\d+\.\d+\.\d+)') { "v$($matches[1])" } else { $version }
        }
        catch {
            $message = "Not found"
        }
        
        $results.Tools += @{
            Name = $tool.Display
            Status = $status
            Message = $message
            InstallCommand = $tool.InstallCommand
        }
        
        if (-not $SummaryOnly) {
            $color = if ($status) { "Green" } else { "Red" }
            $symbol = if ($status) { "✓" } else { "✗" }
            Write-Host "  $symbol $($tool.Display): $message" -ForegroundColor $color
        }
        
        # Auto-fix if requested
        if (-not $status -and $Fix -and -not $SkipTools) {
            if (Test-Admin) {
                Write-Host "    Installing $($tool.Display)..." -ForegroundColor Yellow
                try {
                    Invoke-Expression $tool.InstallCommand
                    Start-Sleep -Seconds 2
                    
                    # Verify installation
                    if (Get-Command $tool.Name -ErrorAction SilentlyContinue) {
                        $results.Tools[-1].Status = $true
                        $results.Tools[-1].Message = "Installed"
                        Write-Host "      ✅ $($tool.Display) installed" -ForegroundColor Green
                    } else {
                        Write-Host "      ❌ Failed to verify installation" -ForegroundColor Red
                    }
                }
                catch {
                    Write-Host "      ❌ Installation failed: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "    ⚠️  Admin rights required to install $($tool.Display)" -ForegroundColor Yellow
            }
        }
    }
}

# Function: Test PowerShell modules
function Test-PowerShellModules {
    Write-Host "`n🔌 POWERSHELL MODULES:" -ForegroundColor Yellow
    
    foreach ($module in $requiredPowerShellModules) {
        $status = $false
        $message = ""
        
        try {
            $moduleInfo = Get-Module -Name $module.Name -ListAvailable -ErrorAction Stop | Select-Object -First 1
            if ($moduleInfo) {
                $status = $true
                $message = "v$($moduleInfo.Version)"
            }
        }
        catch {
            $message = "Not installed"
        }
        
        $results.PowerShellModules += @{
            Name = $module.Display
            Status = $status
            Message = $message
            InstallCommand = $module.InstallCommand
        }
        
        if (-not $SummaryOnly) {
            $color = if ($status) { "Green" } else { "Red" }
            $symbol = if ($status) { "✓" } else { "✗" }
            Write-Host "  $symbol $($module.Display): $message" -ForegroundColor $color
        }
        
        # Auto-fix if requested
        if (-not $status -and $Fix) {
            Write-Host "    Installing $($module.Display)..." -ForegroundColor Yellow
            try {
                Invoke-Expression $module.InstallCommand
                
                # Verify installation
                $moduleInfo = Get-Module -Name $module.Name -ListAvailable -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($moduleInfo) {
                    $results.PowerShellModules[-1].Status = $true
                    $results.PowerShellModules[-1].Message = "v$($moduleInfo.Version)"
                    Write-Host "      ✅ $($module.Display) installed" -ForegroundColor Green
                } else {
                    Write-Host "      ❌ Failed to verify installation" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "      ❌ Installation failed: $_" -ForegroundColor Red
            }
        }
    }
}

# Function: Test font installation
function Test-FontInstallation {
    Write-Host "`n🔤 FONTS:" -ForegroundColor Yellow
    
    $status = $false
    $message = ""
    
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        
        if ($fontFamilies -contains "CaskaydiaCove NF") {
            $status = $true
            $message = "Installed"
        } else {
            $message = "Not found - required for icons"
        }
    }
    catch {
        $message = "Check failed - System.Drawing not available"
    }
    
    $results.Fonts = @{Status = $status; Message = $message}
    
    if (-not $SummaryOnly) {
        $color = if ($status) { "Green" } else { "Red" }
        $symbol = if ($status) { "✓" } else { "✗" }
        Write-Host "  $symbol CaskaydiaCove NF: $message" -ForegroundColor $color
    }
}

# Function: Test profile structure
function Test-ProfileStructure {
    Write-Host "`n📁 PROFILE STRUCTURE:" -ForegroundColor Yellow
    
    $expectedPaths = @(
        $ProfileBase,
        $ModulesDir,
        $ScriptsDir
    )
    
    $missingPaths = @()
    $existingPaths = @()
    
    foreach ($path in $expectedPaths) {
        if (Test-Path $path) {
            $existingPaths += $path
            if (-not $SummaryOnly) {
                Write-Host "  ✅ $path" -ForegroundColor Green
            }
        }
        else {
            $missingPaths += $path
            if (-not $SummaryOnly) {
                Write-Host "  ❌ $path" -ForegroundColor Red
            }
            
            # Auto-create if -Fix is specified
            if ($Fix) {
                try {
                    New-Item -ItemType Directory -Path $path -Force | Out-Null
                    Write-Host "    ✅ Created directory" -ForegroundColor Green
                    $missingPaths = $missingPaths | Where-Object { $_ -ne $path }
                    $existingPaths += $path
                }
                catch {
                    Write-Host "    ❌ Failed to create directory" -ForegroundColor Red
                }
            }
        }
    }
    
    # Check for main profile
    $mainProfile = "$ProfileBase\Microsoft.PowerShell_profile.ps1"
    $profileExists = Test-Path $mainProfile
    
    if (-not $SummaryOnly) {
        $color = if ($profileExists) { "Green" } else { "Red" }
        $symbol = if ($profileExists) { "✓" } else { "✗" }
        Write-Host "  $symbol Microsoft.PowerShell_profile.ps1" -ForegroundColor $color
    }
    
    $results.Structure = @{
        Status = ($missingPaths.Count -eq 0) -and $profileExists
        ExistingPaths = $existingPaths.Count
        TotalPaths = $expectedPaths.Count
        ProfileExists = $profileExists
        MissingPaths = $missingPaths
    }
}

# Function: Test profile loading
function Test-ProfileLoading {
    Write-Host "`n⚡ PROFILE LOADING:" -ForegroundColor Yellow
    
    $mainProfile = "$ProfileBase\Microsoft.PowerShell_profile.ps1"
    
    if (-not (Test-Path $mainProfile)) {
        $results.Profile = @{Status = $false; Message = "Main profile not found"}
        if (-not $SummaryOnly) {
            Write-Host "  ❌ Main profile not found at: $mainProfile" -ForegroundColor Red
        }
        return
    }
    
    try {
        # Read profile content
        $profileContent = Get-Content $mainProfile -Raw
        
        # Check for critical components
        $hasAllModules = $profileContent -match '\$AllModules\s*=\s*@\('
        $hasProfileConfig = $profileContent -match 'ProfileConfig\.ps1'
        $hasSixteenModules = $profileContent -match '16.*modules'
        
        $status = $true
        $message = "Valid structure"
        
        if (-not $SummaryOnly) {
            Write-Host "  ✅ Main profile exists" -ForegroundColor Green
            
            if ($hasAllModules) {
                Write-Host "  ✅ Contains module loading system" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  Missing module loading variable" -ForegroundColor Yellow
            }
            
            if ($hasProfileConfig) {
                Write-Host "  ✅ References ProfileConfig.ps1" -ForegroundColor Green
            }
            
            if ($hasSixteenModules) {
                Write-Host "  ✅ Configured for 16 modules" -ForegroundColor Green
            }
        }
        
        # Try loading the profile
        try {
            . $mainProfile -ErrorAction Stop
            Write-Host "  ✅ Profile loads successfully" -ForegroundColor Green
            
            # Check if modules loaded
            if (Get-Variable -Name loadedModules -Scope Global -ErrorAction SilentlyContinue) {
                $loadedCount = $global:loadedModules.Count
                Write-Host "  ✅ $loadedCount modules loaded" -ForegroundColor Green
                $message = "Loads successfully ($loadedCount modules)"
            }
        }
        catch {
            Write-Host "  ❌ Profile load error: $_" -ForegroundColor Red
            $status = $false
            $message = "Load error: $_"
        }
        
        $results.Profile = @{
            Status = $status
            Message = $message
            HasAllModules = $hasAllModules
            HasProfileConfig = $hasProfileConfig
            HasSixteenModules = $hasSixteenModules
        }
    }
    catch {
        $results.Profile = @{Status = $false; Message = "Error: $_"}
        if (-not $SummaryOnly) {
            Write-Host "  ❌ Profile error: $_" -ForegroundColor Red
        }
    }
}

# Function: Download main profile from your repository
function Repair-MainProfile {
    param(
        [string]$ProfilePath
    )
    
    Write-Host "    ⬇️  Downloading main profile from your repository..." -ForegroundColor Yellow
    try {
        $url = "$RepoBase/Microsoft.PowerShell_profile.ps1"
        Invoke-WebRequest -Uri $url -OutFile $ProfilePath -ErrorAction Stop
        
        if (Test-Path $ProfilePath) {
            Write-Host "      ✅ Main profile downloaded successfully" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "      ❌ Download failed: $_" -ForegroundColor Red
    }
    return $false
}

# Function: Show summary
function Show-Summary {
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "📊 VERIFICATION SUMMARY" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    
    # Modular Files (16 modules)
    $modulesFound = if ($results.ModularFiles) { $results.ModularFiles.Existing } else { 0 }
    $modulesTotal = if ($results.ModularFiles) { $results.ModularFiles.Total } else { 0 }
    $modulesColor = if ($modulesFound -eq 16) { "Green" } elseif ($modulesFound -ge 12) { "Yellow" } else { "Red" }
    Write-Host "Modular Files: $modulesFound/16" -ForegroundColor $modulesColor
    
    # External Tools
    $toolsInstalled = ($results.Tools | Where-Object { $_.Status }).Count
    $toolsTotal = $results.Tools.Count
    $toolsColor = if ($toolsInstalled -eq $toolsTotal) { "Green" } elseif ($toolsInstalled -gt $toolsTotal/2) { "Yellow" } else { "Red" }
    Write-Host "External Tools: $toolsInstalled/$toolsTotal" -ForegroundColor $toolsColor
    
    # PowerShell Modules
    $psModulesInstalled = ($results.PowerShellModules | Where-Object { $_.Status }).Count
    $psModulesTotal = $results.PowerShellModules.Count
    $psModulesColor = if ($psModulesInstalled -eq $psModulesTotal) { "Green" } else { "Red" }
    Write-Host "PowerShell Modules: $psModulesInstalled/$psModulesTotal" -ForegroundColor $psModulesColor
    
    # Fonts
    $fontsColor = if ($results.Fonts.Status) { "Green" } else { "Red" }
    $fontSymbol = if ($results.Fonts.Status) { "✓" } else { "✗" }
    Write-Host "Font: $fontSymbol $($results.Fonts.Message)" -ForegroundColor $fontsColor
    
    # Profile
    $profileColor = if ($results.Profile.Status) { "Green" } else { "Red" }
    Write-Host "Profile: $(if($results.Profile.Status){'✓ Loads'} else {'✗ Error'})" -ForegroundColor $profileColor
    
    # Structure
    $structureColor = if ($results.Structure.Status) { "Green" } else { "Red" }
    Write-Host "Structure: $(if($results.Structure.ProfileExists){'✓'} else {'✗'}) Main profile, $($results.Structure.ExistingPaths)/$($results.Structure.TotalPaths) directories" -ForegroundColor $structureColor
    
    # Repository info
    Write-Host "`n📦 Repository: https://github.com/hetfs/powershell-profile" -ForegroundColor Cyan
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    
    # Overall assessment
    $overall = $modulesFound -eq 16 -and
               ($toolsInstalled -eq $toolsTotal -or $SkipTools) -and 
               $psModulesInstalled -eq $psModulesTotal -and 
               $results.Fonts.Status -and 
               $results.Profile.Status -and 
               $results.Structure.Status
    
    if ($overall) {
        Write-Host "✅ MODULAR PROFILE READY!" -ForegroundColor Green
        Write-Host "All 16 modules and components installed successfully." -ForegroundColor Green
        Write-Host "`n🚀 Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Restart PowerShell/Terminal for best experience" -ForegroundColor White
        Write-Host "  2. Run 'Show-Help' to see available commands" -ForegroundColor White
        Write-Host "  3. Customize modules in $ModulesDir\" -ForegroundColor White
        Write-Host "  4. Edit HFCustom.ps1 for personal settings" -ForegroundColor White
        return 0
    } else {
        Write-Host "⚠️  ENVIRONMENT INCOMPLETE" -ForegroundColor Yellow
        
        # Missing modules
        if ($results.ModularFiles.MissingFiles.Count -gt 0) {
            Write-Host "`nMissing modular files ($($results.ModularFiles.MissingFiles.Count) of 16):" -ForegroundColor Yellow
            foreach ($module in $results.ModularFiles.MissingFiles) {
                Write-Host "  - $module" -ForegroundColor White
            }
            Write-Host "  Run with -Fix to download missing modules from your repository" -ForegroundColor Gray
        }
        
        # Missing main profile
        if (-not $results.Structure.ProfileExists) {
            Write-Host "`nMissing main profile:" -ForegroundColor Yellow
            Write-Host "  - Microsoft.PowerShell_profile.ps1" -ForegroundColor White
            if (-not $Fix) {
                Write-Host "  Run with -Fix to download from your repository" -ForegroundColor Gray
            }
        }
        
        # Missing tools
        if (-not $SkipTools) {
            $missingTools = $results.Tools | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
            if ($missingTools) {
                Write-Host "`nMissing external tools:" -ForegroundColor Yellow
                foreach ($tool in $missingTools) {
                    Write-Host "  - $tool" -ForegroundColor White
                }
                if (-not $Fix) {
                    Write-Host "  Run with -Fix -SkipTools to install tools (admin required)" -ForegroundColor Gray
                }
            }
        }
        
        # Missing PowerShell modules
        $missingPSModules = $results.PowerShellModules | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
        if ($missingPSModules) {
            Write-Host "`nMissing PowerShell modules:" -ForegroundColor Yellow
            foreach ($module in $missingPSModules) {
                Write-Host "  - $module" -ForegroundColor White
            }
            if (-not $Fix) {
                Write-Host "  Run with -Fix to install modules" -ForegroundColor Gray
            }
        }
        
        # Missing directories
        if ($results.Structure.MissingPaths) {
            Write-Host "`nMissing directories:" -ForegroundColor Yellow
            foreach ($path in $results.Structure.MissingPaths) {
                Write-Host "  - $path" -ForegroundColor White
            }
            if (-not $Fix) {
                Write-Host "  Run with -Fix to create directories" -ForegroundColor Gray
            }
        }
        
        Write-Host "`n🔧 RECOMMENDED ACTIONS:" -ForegroundColor Cyan
        if ($Fix) {
            Write-Host "  Run Setup-Modular.ps1 for complete installation" -ForegroundColor White
        } else {
            Write-Host "  Run: .\verify-installation.ps1 -Fix" -ForegroundColor White
        }
        Write-Host "  Or run: .\Setup-Modular.ps1 for fresh install from your repository" -ForegroundColor White
        Write-Host "  Check your repository for updates: https://github.com/hetfs/powershell-profile" -ForegroundColor White
        
        return 1
    }
}

# Main execution
try {
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor DarkGray
    Write-Host "Profile Path: $PROFILE" -ForegroundColor DarkGray
    Write-Host "Using Repository: $RepoBase" -ForegroundColor DarkGray
    
    # Run all tests
    Test-ProfileStructure
    
    # If main profile is missing and -Fix is specified, try to download it
    $mainProfile = "$ProfileBase\Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $mainProfile) -and $Fix) {
        Write-Host "`n🔄 Downloading main profile..." -ForegroundColor Yellow
        if (Repair-MainProfile -ProfilePath $mainProfile) {
            Write-Host "  ✅ Main profile downloaded" -ForegroundColor Green
        }
    }
    
    Test-ModularFiles
    Test-ProfileLoading
    
    if (-not $SkipTools) {
        Test-CoreTools
    }
    
    Test-PowerShellModules
    Test-FontInstallation
    
    # Show summary and exit
    $exitCode = Show-Summary
    exit $exitCode
}
catch {
    Write-Host "❌ Verification failed: $_" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor DarkGray
    exit 1
}
