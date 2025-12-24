# PowerShell Profile Setup Script
# Repository: https://github.com/hetfs/powershell-profile

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

################################################################################################
# SECTION 1: ADMINISTRATOR CHECK
################################################################################################

$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host '❌ Please run this script as Administrator' -ForegroundColor Red
    exit 1
}

################################################################################################
# SECTION 2: INTERNET CONNECTIVITY CHECK
################################################################################################

function Test-InternetConnection {
    Write-Host '🌐 Testing internet connection...' -ForegroundColor Cyan
    try {
        Test-Connection -ComputerName 'www.google.com' -Count 1 -Quiet
    } catch {
        $false
    }
}

################################################################################################
# SECTION 3: NERD FONTS INSTALLATION
################################################################################################

function Install-NerdFonts {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$Version = '3.4.0'
    )

    $Fonts = @(
        'Hack'
        'FiraCode'
        'HeavyData'
        'JetBrainsMono'
        'DejaVuSansMono'
    )

    Write-Host '📝 Checking Nerd Fonts...' -ForegroundColor Cyan

    Add-Type -AssemblyName System.Drawing
    $InstalledFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
    $FontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    $TempRoot = Join-Path $env:TEMP 'nerd-fonts'

    foreach ($Font in $Fonts) {
        if ($InstalledFonts -match $Font) {
            Write-Host "✅ $Font Nerd Font already installed" -ForegroundColor Green
            continue
        }

        $ZipPath = Join-Path $TempRoot "$Font.zip"
        $ExtractPath = Join-Path $TempRoot $Font
        $Url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v$Version/$Font.zip"

        Write-Host "📥 Installing $Font Nerd Font..." -ForegroundColor Yellow

        New-Item -Path $TempRoot -ItemType Directory -Force | Out-Null
        Invoke-WebRequest -Uri $Url -OutFile $ZipPath
        Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

        Get-ChildItem $ExtractPath -Recurse -Include *.ttf, *.otf | ForEach-Object {
            if (-not (Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                if ($PSCmdlet.ShouldProcess($_.Name, 'Install font')) {
                    $FontsFolder.CopyHere($_.FullName, 0x10)
                }
            }
        }

        Remove-Item $ZipPath, $ExtractPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ $Font Nerd Font installed" -ForegroundColor Green
    }

    Remove-Item $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

################################################################################################
# SECTION 4: PROFILE SETUP
################################################################################################

function Setup-PowerShellProfile {
    Write-Host '🔧 Setting up PowerShell profile...' -ForegroundColor Cyan

    $ProfileDir = Split-Path $PROFILE
    if (-not (Test-Path $ProfileDir)) {
        New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
    }

    $ProfileUrl = 'https://raw.githubusercontent.com/hetfs/powershell-profile/main/Microsoft.PowerShell_profile.ps1'

    if (Test-Path $PROFILE) {
        Copy-Item $PROFILE "$PROFILE.bak" -Force
        Write-Host '📦 Existing profile backed up' -ForegroundColor Yellow
    }

    Invoke-RestMethod $ProfileUrl -OutFile $PROFILE
    Write-Host "✅ Profile installed at $PROFILE" -ForegroundColor Green
}

################################################################################################
# SECTION 5: TOOLS INSTALLATION (WINGET ONLY, SILENT)
################################################################################################

$Tools = @{
    'fzf'      = @{ Id = 'Junegunn.Fzf' }
    'bat'      = @{ Id = 'SharkDP.Bat' }
    'fd'       = @{ Id = 'sharkdp.fd' }
    'rg'       = @{ Id = 'BurntSushi.ripgrep.MSVC' }
    'delta'    = @{ Id = 'dandavison.delta' }
    'eza'      = @{ Id = 'eza-community.eza' }
    'zoxide'   = @{ Id = 'ajeetdsouza.zoxide' }
    'starship' = @{ Id = 'Starship.Starship' }
    'neovim'   = @{ Id = 'Neovim.Neovim' }
    'wezterm'  = @{ Id = 'wez.wezterm' }
}

function Install-Tools {
    Write-Host '📦 Installing tools via Winget...' -ForegroundColor Cyan

    foreach ($Tool in $Tools.GetEnumerator()) {
        if (-not (Get-Command $Tool.Key -ErrorAction SilentlyContinue)) {
            Write-Host "🚀 Installing $($Tool.Key)..." -ForegroundColor Yellow
            winget install `
                --id $Tool.Value.Id `
                --exact `
                --silent `
                --accept-package-agreements `
                --accept-source-agreements
            Write-Host "✅ $($Tool.Key) installed" -ForegroundColor Green
        }
        else {
            Write-Host "✅ $($Tool.Key) already installed" -ForegroundColor Green
        }
    }
}

################################################################################################
# SECTION 6: PROFILE RELOAD
################################################################################################

function Reload-Profile {
    try {
        if (Test-Path $PROFILE) {
            $Error.Clear()
            . $PROFILE
            Write-Host '✅ Profile reloaded successfully' -ForegroundColor Green
        }
    }
    catch {
        Write-Host '⚠️ Restart PowerShell to apply changes' -ForegroundColor Yellow
    }
}

################################################################################################
# SECTION 7: VERIFICATION
################################################################################################

function Verify-Installation {
    Write-Host '🔍 Verifying installation...' -ForegroundColor Cyan

    foreach ($Tool in $Tools.Keys) {
        if (Get-Command $Tool -ErrorAction SilentlyContinue) {
            Write-Host "✅ $Tool available" -ForegroundColor Green
        }
        else {
            Write-Host "❌ $Tool missing" -ForegroundColor Red
        }
    }
}

################################################################################################
# SECTION 8: MAIN EXECUTION
################################################################################################

Write-Host '=========================================' -ForegroundColor Cyan
Write-Host ' PowerShell Profile Setup Script ' -ForegroundColor Cyan
Write-Host ' Repository: hetfs/powershell-profile' -ForegroundColor Cyan
Write-Host '=========================================' -ForegroundColor Cyan

if (-not (Test-InternetConnection)) {
    Write-Host '❌ Internet connection required' -ForegroundColor Red
    exit 1
}

Install-NerdFonts
Setup-PowerShellProfile
Install-Tools
Reload-Profile
Verify-Installation

Write-Host '🎯 Setup completed. Restart PowerShell if needed.' -ForegroundColor Cyan
