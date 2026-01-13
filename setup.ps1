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

            Get-ChildItem $ExtractPath -Recurse -Include *.ttf, *.otf |
                Where-Object { $_.Name -match "^$Font" } |
                ForEach-Object {
                    $Dest = Join-Path "$env:WINDIR\Fonts" $_.Name
                    if (-not (Test-Path $Dest)) {
                        Copy-Item $_.FullName $Dest -Force

                        $FontName = $_.BaseName
                        if (-not (Get-ItemProperty `
                            -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
                            -Name "$FontName (TrueType)" `
                            -ErrorAction SilentlyContinue)) {

                            New-ItemProperty `
                                -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
                                -Name "$FontName (TrueType)" `
                                -PropertyType String `
                                -Value $_.Name `
                                -Force | Out-Null
                        }

                        Write-Host "✅ Installed font: $($_.Name)" -ForegroundColor Green
                    }
                }
        }
        catch {
            Write-Warning ("⚠️ Failed to install {0}: {1}" -f $Font, $_)
        }
        finally {
            Remove-Item $ZipPath, $ExtractPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Remove-Item $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

################################################################################################
# SECTION 4: TOOL INSTALLATION
################################################################################################

$Tools = @(
    @{ Name='gsudo';    Cmd='gsudo';    Id='gerardog.gsudo' }
    @{ Name='git';      Cmd='git';      Id='Git.Git' }
    @{ Name='lazygit';  Cmd='lazygit';  Id='JesseDuffield.lazygit' }
    @{ Name='Wget2';    Cmd='wget2';    Id='GNU.Wget2' }
    @{ Name='curl';     Cmd='curl';     Id='cURL.cURL' }
    @{ Name='tar';      Cmd='tar';      Id='GnuWin32.Tar' }
    @{ Name='unzip';    Cmd='unzip';    Id='GnuWin32.UnZip' }
    @{ Name='fzf';      Cmd='fzf';      Id='junegunn.fzf' }
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
    Write-Host '📦 Installing tools via Winget (source pinned)...' -ForegroundColor Cyan

    foreach ($Tool in $Tools) {
        if (Get-Command $Tool.Cmd -ErrorAction SilentlyContinue) {
            Write-Host "✅ $($Tool.Name) already installed" -ForegroundColor Green
            continue
        }

        Write-Host "🚀 Installing $($Tool.Name)..." -ForegroundColor Yellow
        winget install --id $Tool.Id --exact --source winget --silent `
            --accept-package-agreements --accept-source-agreements

        Write-Host "✅ $($Tool.Name) installed" -ForegroundColor Green
    }
}

################################################################################################
# SECTION 5: PROFILE SETUP (WRAPPED — LOGIC UNCHANGED)
################################################################################################

function Setup-PowerShellProfile {
    Write-Host '🔧 Configuring PowerShell profile...' -ForegroundColor Cyan

    $ProfileRoot = if ($PSVersionTable.PSEdition -eq 'Core') {
        Join-Path $env:USERPROFILE 'Documents\PowerShell'
    } else {
        Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell'
    }

    if (-not (Test-Path $ProfileRoot)) {
        New-Item -Path $ProfileRoot -ItemType Directory -Force | Out-Null
    }

    if (Test-Path $PROFILE) {
        $BackupPath = Join-Path (Split-Path $PROFILE) 'oldprofile.ps1'
        Move-Item $PROFILE $BackupPath -Force
        Write-Host "📦 Existing profile backed up → $BackupPath" -ForegroundColor Yellow
    }

    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/hetfs/powershell-profile/main/Microsoft.PowerShell_profile.ps1' `
        -OutFile $PROFILE

    Write-Host "✅ PowerShell profile installed → $PROFILE" -ForegroundColor Green
    Write-Host "⚠️ NOTE:" -ForegroundColor Yellow
    Write-Host "   Put personal customizations in:" -ForegroundColor Gray
    Write-Host "   $ProfileRoot\Profile.ps1" -ForegroundColor Gray
    Write-Host "   This file is not touched by the updater." -ForegroundColor Gray
}

################################################################################################
# SECTION 6: TERMINAL ICONS
################################################################################################

function Install-TerminalIcons {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force
    Write-Host '✅ Terminal-Icons module installed' -ForegroundColor Green
}

################################################################################################
# SECTION 7: VERIFICATION
################################################################################################

function Verify-Installation {
    Write-Host '🔍 Verifying installed tools...' -ForegroundColor Cyan
    foreach ($Tool in $Tools) {
        if (Get-Command $Tool.Cmd -ErrorAction SilentlyContinue) {
            Write-Host "✅ $($Tool.Name) OK" -ForegroundColor Green
        } else {
            Write-Host "❌ $($Tool.Name) missing" -ForegroundColor Red
        }
    }
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

Install-NerdFonts
Install-Tools
Install-TerminalIcons
Verify-Installation
Setup-PowerShellProfile

Write-Host '🎯 Setup completed successfully.' -ForegroundColor Cyan
