# Scripts/verify-installation.ps1
# Post-installation verification script for Modular PowerShell Profile

param(
    [switch]$Fix,
    [switch]$SummaryOnly,
    [switch]$SkipTools
)

Write-Host "🔍 PowerShell Modular Profile Verification" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Configuration
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

$requiredModules = @(
    @{Name = "Terminal-Icons"; Display = "Terminal-Icons"; InstallCommand = "Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser"},
    @{Name = "PSReadLine"; Display = "PSReadLine"; InstallCommand = "Install-Module -Name PSReadLine -Repository PSGallery -Force -Scope CurrentUser"}
)

# Results tracking
$results = @{
    Tools = @()
    Modules = @()
    Fonts = $null
    Profile = $null
    Structure = $null
    ModularFiles = $null
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CoreTools {
    Write-Host "`n📦 Core Tools:" -ForegroundColor Yellow
    
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
        
        $results.Tools += @{Name = $tool.Display; Status = $status; Message = $message; InstallCommand = $tool.InstallCommand}
        
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
                        Write-Host "    ✓ $($tool.Display) installed successfully" -ForegroundColor Green
                    } else {
                        Write-Host "    ✗ Failed to verify $($tool.Display) installation" -ForegroundColor Red
                    }
                }
                catch {
                    Write-Host "    ✗ Failed to install $($tool.Display): $_" -ForegroundColor Red
                }
            } else {
                Write-Host "    ⚠️  Admin rights required to install $($tool.Display)" -ForegroundColor Yellow
            }
        }
    }
}

function Test-PowerShellModules {
    Write-Host "`n🔌 PowerShell Modules:" -ForegroundColor Yellow
    
    foreach ($module in $requiredModules) {
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
        
        $results.Modules += @{Name = $module.Display; Status = $status; Message = $message; InstallCommand = $module.InstallCommand}
        
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
                    $results.Modules[-1].Status = $true
                    $results.Modules[-1].Message = "v$($moduleInfo.Version)"
                    Write-Host "    ✓ $($module.Display) installed successfully" -ForegroundColor Green
                } else {
                    Write-Host "    ✗ Failed to verify $($module.Display) installation" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "    ✗ Failed to install $($module.Display): $_" -ForegroundColor Red
            }
        }
    }
}

function Test-FontInstallation {
    Write-Host "`n🔤 Fonts:" -ForegroundColor Yellow
    
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

function Test-ModularFiles {
    Write-Host "`n📄 Modular Profile Files:" -ForegroundColor Yellow
    
    $expectedModules = @(
        "ProfileConfig.ps1",
        "CoreFunctions.psm1",
        "DebugModule.psm1",
        "UpdateModule.psm1",
        "AdminModule.psm1",
        "EditorModule.psm1",
        "NetworkModule.psm1",
        "SystemModule.psm1",
        "GitModule.psm1",
        "NavigationModule.psm1",
        "UtilityModule.psm1",
        "PSReadLineModule.psm1",
        "CompletionModule.psm1",
        "ThemeModule.psm1",
        "ZoxideModule.psm1",
        "HelpModule.psm1"
    )
    
    $missingFiles = @()
    $existingFiles = @()
    $modulesPath = "$env:USERPROFILE\Documents\PowerShell\Modules"
    
    if (-not (Test-Path $modulesPath)) {
        $message = "Modules directory not found"
        if ($Fix) {
            try {
                New-Item -ItemType Directory -Path $modulesPath -Force | Out-Null
                Write-Host "  Created Modules directory" -ForegroundColor Green
            }
            catch {
                Write-Host "  ✗ Failed to create Modules directory" -ForegroundColor Red
            }
        }
    }
    
    foreach ($file in $expectedModules) {
        $filePath = Join-Path $modulesPath $file
        if (Test-Path $filePath) {
            $existingFiles += $file
            if (-not $SummaryOnly) {
                Write-Host "  ✓ $file" -ForegroundColor Green
            }
        }
        else {
            $missingFiles += $file
            if (-not $SummaryOnly) {
                Write-Host "  ✗ $file" -ForegroundColor Red
            }
        }
    }
    
    $results.ModularFiles = @{
        Status = ($missingFiles.Count -eq 0)
        Existing = $existingFiles.Count
        Total = $expectedModules.Count
        MissingFiles = $missingFiles
    }
}

function Test-ProfileStructure {
    Write-Host "`n📁 Profile Structure:" -ForegroundColor Yellow
    
    $expectedPaths = @(
        "$env:USERPROFILE\Documents\PowerShell",
        "$env:USERPROFILE\Documents\PowerShell\Modules"
    )
    
    $missingPaths = @()
    $existingPaths = @()
    
    foreach ($path in $expectedPaths) {
        if (Test-Path $path) {
            $existingPaths += $path
            if (-not $SummaryOnly) {
                Write-Host "  ✓ $path" -ForegroundColor Green
            }
        }
        else {
            $missingPaths += $path
            if (-not $SummaryOnly) {
                Write-Host "  ✗ $path" -ForegroundColor Red
            }
            # Auto-create if -Fix is specified
            if ($Fix) {
                try {
                    New-Item -ItemType Directory -Path $path -Force | Out-Null
                    Write-Host "    Created: $path" -ForegroundColor Green
                    $missingPaths = $missingPaths | Where-Object { $_ -ne $path }
                    $existingPaths += $path
                }
                catch {
                    Write-Host "    Failed to create: $path" -ForegroundColor Red
                }
            }
        }
    }
    
    # Check for main profile
    $mainProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
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

function Test-ProfileLoading {
    Write-Host "`n⚡ Profile Loading:" -ForegroundColor Yellow
    
    $mainProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    
    if (-not (Test-Path $mainProfile)) {
        $results.Profile = @{Status = $false; Message = "Main profile not found"}
        if (-not $SummaryOnly) {
            Write-Host "  ✗ Main profile not found at: $mainProfile" -ForegroundColor Red
        }
        return
    }
    
    try {
        # Test loading in a temporary scope to avoid polluting current session
        $script = Get-Content $mainProfile -Raw
        
        # Check for critical components
        $hasModules = $script -match '\$modulesToLoad'
        $hasProfileConfig = $script -match '\. \$PSScriptRoot\\Modules\\ProfileConfig\.ps1'
        
        $status = $true
        $message = "Loads successfully"
        
        if (-not $SummaryOnly) {
            Write-Host "  ✓ Main profile structure valid" -ForegroundColor Green
            if ($hasModules) {
                Write-Host "  ✓ Contains module loading system" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  Missing module loading system" -ForegroundColor Yellow
            }
            if ($hasProfileConfig) {
                Write-Host "  ✓ References ProfileConfig.ps1" -ForegroundColor Green
            }
        }
        
        $results.Profile = @{
            Status = $status
            Message = $message
            HasModules = $hasModules
            HasProfileConfig = $hasProfileConfig
        }
    }
    catch {
        $results.Profile = @{Status = $false; Message = "Error: $_"}
        if (-not $SummaryOnly) {
            Write-Host "  ✗ Profile error: $_" -ForegroundColor Red
        }
    }
}

function Show-Summary {
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "📊 VERIFICATION SUMMARY" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    
    # Tools
    $toolsInstalled = ($results.Tools | Where-Object { $_.Status }).Count
    $toolsTotal = $results.Tools.Count
    $toolsColor = if ($toolsInstalled -eq $toolsTotal) { "Green" } elseif ($toolsInstalled -gt $toolsTotal/2) { "Yellow" } else { "Red" }
    Write-Host "Tools: $toolsInstalled/$toolsTotal" -ForegroundColor $toolsColor
    
    # Modules
    $modulesInstalled = ($results.Modules | Where-Object { $_.Status }).Count
    $modulesTotal = $results.Modules.Count
    $modulesColor = if ($modulesInstalled -eq $modulesTotal) { "Green" } else { "Red" }
    Write-Host "Modules: $modulesInstalled/$modulesTotal" -ForegroundColor $modulesColor
    
    # Modular Files
    $modularFilesExist = if ($results.ModularFiles) { $results.ModularFiles.Existing } else { 0 }
    $modularFilesTotal = if ($results.ModularFiles) { $results.ModularFiles.Total } else { 0 }
    $filesColor = if ($modularFilesExist -eq $modularFilesTotal) { "Green" } elseif ($modularFilesExist -gt $modularFilesTotal/2) { "Yellow" } else { "Red" }
    Write-Host "Modular Files: $modularFilesExist/$modularFilesTotal" -ForegroundColor $filesColor
    
    # Fonts
    $fontsColor = if ($results.Fonts.Status) { "Green" } else { "Red" }
    $fontSymbol = if ($results.Fonts.Status) { "✓" } else { "✗" }
    Write-Host "Font: $fontSymbol $($results.Fonts.Message)" -ForegroundColor $fontsColor
    
    # Profile
    $profileColor = if ($results.Profile.Status) { "Green" } else { "Red" }
    Write-Host "Profile: $(if($results.Profile.Status){'✓ Loads'} else {'✗ Error'})" -ForegroundColor $profileColor
    
    # Structure
    $structureColor = if ($results.Structure.Status) { "Green" } else { "Red" }
    Write-Host "Structure: $(if($results.Structure.ProfileExists){'✓'} else {'✗'}) Main profile, $($results.Structure.ExistingPaths)/$($results.Structure.TotalPaths) paths" -ForegroundColor $structureColor
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    
    # Overall assessment
    $overall = ($toolsInstalled -eq $toolsTotal -or $SkipTools) -and 
               $modulesInstalled -eq $modulesTotal -and 
               $results.Fonts.Status -and 
               $results.Profile.Status -and 
               $results.Structure.Status -and
               ($modularFilesExist -gt 0)
    
    if ($overall) {
        Write-Host "✅ MODULAR PROFILE READY!" -ForegroundColor Green
        Write-Host "All components installed successfully." -ForegroundColor Green
        Write-Host "`n🚀 Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Restart PowerShell/Terminal" -ForegroundColor White
        Write-Host "  2. Run 'starship preset pastel-powerline > ~/.config/starship.toml'" -ForegroundColor White
        Write-Host "  3. Customize modules in $env:USERPROFILE\Documents\PowerShell\Modules\" -ForegroundColor White
        return 0
    } else {
        Write-Host "⚠️  ENVIRONMENT INCOMPLETE" -ForegroundColor Yellow
        
        # Missing tools
        if (-not $SkipTools) {
            $missingTools = $results.Tools | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
            if ($missingTools) {
                Write-Host "`nMissing tools:" -ForegroundColor Yellow
                foreach ($tool in $missingTools) {
                    $installCmd = ($results.Tools | Where-Object { $_.Name -eq $tool }).InstallCommand
                    Write-Host "  - $tool" -ForegroundColor White
                    if ($installCmd) {
                        Write-Host "    Install: $installCmd" -ForegroundColor Gray
                    }
                }
                if (-not $Fix) {
                    Write-Host "  Run with -Fix to install missing tools (admin required)" -ForegroundColor Gray
                }
            }
        }
        
        # Missing modules
        $missingModules = $results.Modules | Where-Object { -not $_.Status } | ForEach-Object { $_.Name }
        if ($missingModules) {
            Write-Host "`nMissing PowerShell modules:" -ForegroundColor Yellow
            foreach ($module in $missingModules) {
                Write-Host "  - $module" -ForegroundColor White
            }
            if (-not $Fix) {
                Write-Host "  Run with -Fix to install missing modules" -Foreground
