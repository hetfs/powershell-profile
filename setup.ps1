# PowerShell Profile Setup Script (Hardened & Idempotent)
# Repository: https://github.com/hetfs/powershell-profile

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

################################################################################################
# SECTION 1: PLATFORM + ADMIN CHECK
################################################################################################

if ($PSVersionTable.Platform -ne 'Win32NT') {
    throw 'This script supports Windows only.'
}

$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    throw 'Please run this script as Administrator.'
}

################################################################################################
# SECTION 2: INTERNET CONNECTIVITY CHECK
################################################################################################

function Test-InternetConnection {
    Write-Host '🌐 Testing internet connection...' -ForegroundColor Cyan
    try {
        return (Test-Connection -ComputerName 'www.google.com' -Count 1 -Quiet)
    } catch {
        return $false
    }
}

################################################################################################
# SECTION 3: NERD FONTS INSTALLATION (IDEMPOTENT & CI-FRIENDLY)
################################################################################################

function Install-NerdFonts {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$Version = '3.4.0'
    )

    $Fonts = @(
        'Hack'
        'FiraCode'
        'JetBrainsMono'
        'DejaVuSansMono'
        'CascadiaCode'
    )

    Write-Host '📝 Verifying Nerd Fonts installation...' -ForegroundColor Cyan

    Add-Type -AssemblyName System.Drawing
    $InstalledFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name

    $TempRoot = Join-Path $env:TEMP "nerd-fonts-$Version"
    New-Item -Path $TempRoot -ItemType Directory -Force | Out-Null

    foreach ($Font in $Fonts) {
        if ($InstalledFonts -contains "$Font Nerd Font") {
            Write-Host "✅ $Font Nerd Font already installed" -ForegroundColor Green
            continue
        }

        $ZipPath     = Join-Path $TempRoot "$Font.zip"
        $ExtractPath = Join-Path $TempRoot $Font
        $Url         = "https://github.com/ryanoasis/nerd-fonts/releases/download/v$Version/$Font.zip"

        Write-Host "📥 Installing $Font Nerd Font..." -ForegroundColor Yellow

        try {
            Invoke-WebRequest -Uri $Url -OutFile $ZipPath
            Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

            Get-ChildItem $ExtractPath -Recurse -Include *.ttf, *.otf | Where-Object {
                $_.Name -match "^$Font"
            } | ForEach-Object {
                $Dest = Join-Path "$env:WINDIR\Fonts" $_.Name
                if (-not (Test-Path $Dest)) {
                    Copy-Item $_.FullName $Dest -Force

                    $FontName = $_.BaseName
                    if (-not (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$FontName (TrueType)" -ErrorAction SilentlyContinue)) {
                        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
                                         -Name "$FontName (TrueType)" `
                                         -PropertyType String `
                                         -Value $_.Name `
                                         -Force | Out-Null
                    }

                    Write-Host "✅ Installed font: $($_.Name)" -ForegroundColor Green
                }
            }

        } catch {
            Write-Warning ("⚠️ Failed to install {0}: {1}" -f $Font, $_)
        } finally {
            Remove-Item $ZipPath, $ExtractPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    if (Test-Path $TempRoot) {
        Remove-Item $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

################################################################################################
# SECTION 4: TOOL INSTALLATION (WINGET PINNED)
################################################################################################

$Tools = @(
    @{ Name='git';      Cmd='git';      Id='Git.Git' }
    @{ Name='lazygit';  Cmd='lazygit';  Id='JesseDuffield.lazygit' }
    @{ Name='wget';     Cmd='wget';     Id='JernejSimoncic.Wget'}
    @{ Name='cURL';     Cmd='curl';     Id='cURL.cURL'}
    @{ Name='fzf';      Cmd='fzf';      Id='fzf' }
    @{ Name='bat';      Cmd='bat';      Id='sharkdp.bat' }
    @{ Name='fd';       Cmd='fd';       Id='sharkdp.fd' }
    @{ Name='rg';       Cmd='rg';       Id='BurntSushi.ripgrep.MSVC' }
    @{ Name='delta';    Cmd='delta';    Id='dandavison.delta' }
    @{ Name='eza';      Cmd='eza';      Id='eza-community.eza' }
    @{ Name='zoxide';   Cmd='zoxide';   Id='ajeetdsouza.zoxide' }
    @{ Name='starship'; Cmd='starship'; Id='Starship.Starship' }
    @{ Name='nvim';     Cmd='nvim';     Id='Neovim.Neovim' }
)

function Install-Tools {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Winget is required but not available.'
    }

    Write-Host '📦 Installing tools via Winget (source pinned)...' -ForegroundColor Cyan

    foreach ($Tool in $Tools) {
        if (-not (Get-Command $Tool.Cmd -ErrorAction SilentlyContinue)) {
            Write-Host "🚀 Installing $($Tool.Name)..." -ForegroundColor Yellow

            winget install `
                --id $Tool.Id `
                --exact `
                --source winget `
                --silent `
                --accept-package-agreements `
                --accept-source-agreements

            Write-Host "✅ $($Tool.Name) installed" -ForegroundColor Green
        }
        else {
            Write-Host "✅ $($Tool.Name) already installed" -ForegroundColor Green
        }
    }
}

################################################################################################
# SECTION 5: TERMINAL ICONS MODULE
################################################################################################

function Install-TerminalIcons {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope AllUsers
        Write-Host '✅ Terminal-Icons module installed' -ForegroundColor Green
    }
    catch {
        Write-Warning "Terminal-Icons installation failed: $_"
    }
}

################################################################################################
# SECTION 6: VERIFICATION
################################################################################################

function Verify-Installation {
    Write-Host '🔍 Verifying installed tools...' -ForegroundColor Cyan

    foreach ($Tool in $Tools) {
        if (Get-Command $Tool.Cmd -ErrorAction SilentlyContinue) {
            Write-Host "✅ $($Tool.Name) OK" -ForegroundColor Green
        }
        else {
            Write-Host "❌ $($Tool.Name) missing" -ForegroundColor Red
        }
    }
}

################################################################################################
# SECTION 7: PROFILE SETUP
################################################################################################

function Setup-PowerShellProfile {
    Write-Host '🔧 Configuring PowerShell profile...' -ForegroundColor Cyan

    $ProfileDir = Split-Path $PROFILE
    if (-not (Test-Path $ProfileDir)) {
        New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
    }

    $ProfileUrl = 'https://raw.githubusercontent.com/hetfs/powershell-profile/main/Microsoft.PowerShell_profile.ps1'

    if (Test-Path $PROFILE) {
        $Backup = "$PROFILE.bak.$(Get-Date -Format yyyyMMddHHmmss)"
        Copy-Item $PROFILE $Backup -Force
        Write-Host "📦 Existing profile backed up → $Backup" -ForegroundColor Yellow
    }

    Invoke-WebRequest -Uri $ProfileUrl -OutFile $PROFILE
    Write-Host "✅ Profile installed → $PROFILE" -ForegroundColor Green
}

################################################################################################
# SECTION 8: MAIN EXECUTION
################################################################################################

Write-Host '=========================================' -ForegroundColor Cyan
Write-Host ' PowerShell Profile Setup ' -ForegroundColor Cyan
Write-Host ' https://github.com/hetfs/powershell-profile' -ForegroundColor Cyan
Write-Host '=========================================' -ForegroundColor Cyan

if (-not (Test-InternetConnection)) {
    throw 'Active internet connection is required.'
}

# Install fonts, tools, terminal icons, verify before profile setup
Install-NerdFonts
Install-Tools
Install-TerminalIcons
Verify-Installation
Setup-PowerShellProfile

Write-Host '🎯 Setup completed successfully.' -ForegroundColor Cyan
