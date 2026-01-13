# ============================================================
# PowerShell Profile Setup Script (Hardened & Idempotent)
# Repository: https://github.com/hetfs/powershell-profile
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

################################################################################################
# SECTION 1: PLATFORM CHECK
################################################################################################

if ($PSVersionTable.Platform -ne 'Win32NT') {
    throw '❌ This script supports Windows only.'
}

################################################################################################
# SECTION 2: INTERNET CONNECTIVITY CHECK
################################################################################################

function Test-InternetConnection {
    Write-Host '🌐 Testing internet connection...' -ForegroundColor Cyan
    try {
        return Test-Connection -ComputerName 'www.google.com' -Count 1 -Quiet
    } catch {
        return $false
    }
}

################################################################################################
# SECTION 3: NERD FONTS INSTALLATION VIA CHOCOLATEY
# source https://github.com/ryanoasis/nerd-fonts
# For run: & ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1')))
################################################################################################

function Install-NerdFontsAuto {
    Write-Host '🔤 Installing Nerd Fonts via Chocolatey...' -ForegroundColor Cyan

    # Ensure TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor
        [Net.SecurityProtocolType]::Tls12

    # Install Chocolatey only if missing
    if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Write-Host '📦 Installing Chocolatey...' -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force

        $installScript = Invoke-WebRequest `
            -Uri 'https://community.chocolatey.org/install.ps1' `
            -UseBasicParsing

        Invoke-Expression $installScript.Content
    }

    # Install Nerd Fonts (idempotent)
    choco install `
        nerd-fonts-hack --force `
        nerd-fonts-firacode --force `
        nerd-fonts-jetbrainsmono --force `
        -y --no-progress

    Write-Host '✅ Nerd Fonts installation completed' -ForegroundColor Green
}

################################################################################################
# SECTION 4: TOOL INSTALLATION VIA WINGET
################################################################################################

$Tools = @(
    @{ Name='gsudo';    Cmd='gsudo';    Id='gerardog.gsudo' },
    @{ Name='git';      Cmd='git';      Id='Git.Git' },
    @{ Name='lazygit';  Cmd='lazygit';  Id='JesseDuffield.lazygit' },
    @{ Name='Wget2';    Cmd='wget2';    Id='GNU.Wget2' },
    @{ Name='curl';     Cmd='curl';     Id='cURL.cURL' },
    @{ Name='tar';      Cmd='tar';      Id='GnuWin32.Tar' },
    @{ Name='unzip';    Cmd='unzip';    Id='GnuWin32.UnZip' },
    @{ Name='fzf';      Cmd='fzf';      Id='junegunn.fzf' },
    @{ Name='bat';      Cmd='bat';      Id='sharkdp.bat' },
    @{ Name='fd';       Cmd='fd';       Id='sharkdp.fd' },
    @{ Name='rg';       Cmd='rg';       Id='BurntSushi.ripgrep.MSVC' },
    @{ Name='delta';    Cmd='delta';    Id='dandavison.delta' },
    @{ Name='eza';      Cmd='eza';      Id='eza-community.eza' },
    @{ Name='zoxide';   Cmd='zoxide';   Id='ajeetdsouza.zoxide' },
    @{ Name='starship'; Cmd='starship'; Id='Starship.Starship' },
    @{ Name='nvim';     Cmd='nvim';     Id='Neovim.Neovim' }
)

function Install-Tools {
    Write-Host '📦 Installing tools via Winget...' -ForegroundColor Cyan

    foreach ($Tool in $Tools) {
        if (Get-Command $Tool.Cmd -ErrorAction SilentlyContinue) {
            Write-Host "✅ $($Tool.Name) already installed" -ForegroundColor Green
            continue
        }

        Write-Host "🚀 Installing $($Tool.Name)..." -ForegroundColor Yellow
        try {
            winget install --id $Tool.Id --exact --silent `
                --accept-package-agreements --accept-source-agreements

            Write-Host "✅ $($Tool.Name) installation completed" -ForegroundColor Green
        } catch {
            Write-Warning "❌ Failed to install $($Tool.Name): $_"
        }
    }
}

################################################################################################
# SECTION 5: TERMINAL ICONS
################################################################################################

function Install-TerminalIcons {
    Write-Host '📦 Installing Terminal-Icons module...' -ForegroundColor Cyan

    try {
        if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        if (Get-Module -ListAvailable -Name Terminal-Icons) {
            Write-Host '✅ Terminal-Icons already installed' -ForegroundColor Green
            return
        }

        Install-Module `
            -Name Terminal-Icons `
            -Repository PSGallery `
            -Scope CurrentUser `
            -Force `
            -AllowClobber `
            -ErrorAction Stop

        Write-Host '✅ Terminal-Icons module installed' -ForegroundColor Green
    } catch {
        Write-Warning "❌ Terminal-Icons installation failed: $($_.Exception.Message)"
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
        } else {
            Write-Host "❌ $($Tool.Name) missing" -ForegroundColor Red
        }
    }
}

################################################################################################
# SECTION 7: MAIN EXECUTION
################################################################################################

Write-Host ('=' * 60) -ForegroundColor Cyan
Write-Host ' PowerShell Profile Setup ' -ForegroundColor Cyan
Write-Host ' https://github.com/hetfs/powershell-profile' -ForegroundColor Cyan
Write-Host ('=' * 60) -ForegroundColor Cyan

if (-not (Test-InternetConnection)) {
    throw '❌ Active internet connection is required.'
}

Install-NerdFontsAuto
Install-Tools
Install-TerminalIcons
Verify-Installation

Write-Host '🎯 Setup completed successfully.' -ForegroundColor Cyan
