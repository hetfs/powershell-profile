# ============================================================
# PowerShell Profile Setup Script (Hardened & Idempotent)
# Repository: https://github.com/hetfs/powershell-profile
# Description: Installs essential dev tools, Nerd Fonts, and terminal enhancements for Windows.
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
    <#
    .SYNOPSIS
        Checks if the system has an active internet connection.
    .OUTPUTS
        [bool] True if internet is reachable, False otherwise.
    #>
    Write-Host '🌐 Testing internet connection...' -ForegroundColor Cyan
    try {
        return Test-Connection -ComputerName 'www.google.com' -Count 1 -Quiet
    } catch {
        return $false
    }
}

################################################################################################
# SECTION 3: NERD FONTS INSTALLATION VIA CHOCOLATEY
# Source: https://github.com/ryanoasis/nerd-fonts
################################################################################################

function Install-NerdFontsAuto {
    <#
    .SYNOPSIS
        Installs popular Nerd Fonts via Chocolatey.
    .DESCRIPTION
        This function ensures Chocolatey is installed, then installs Hack, FiraCode, and JetBrainsMono Nerd Fonts.
        It enforces TLS 1.2 for secure download and is idempotent.
    #>
    Write-Host '🔤 Installing Nerd Fonts via Chocolatey...' -ForegroundColor Cyan

    # Ensure TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    # Install Chocolatey if missing
    if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Write-Host '📦 Installing Chocolatey...' -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        $installScript = Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -UseBasicParsing
        Invoke-Expression $installScript.Content
    }

    # Install Nerd Fonts (idempotent)
    $fonts = @('nerd-fonts-hack', 'nerd-fonts-firacode', 'nerd-fonts-jetbrainsmono')
    foreach ($font in $fonts) {
        if (-not (choco list --local-only | Select-String $font)) {
            Write-Host "🚀 Installing $font..." -ForegroundColor Yellow
            choco install $font -y --no-progress
        } else {
            Write-Host "✅ $font already installed" -ForegroundColor Green
        }
    }

    Write-Host '✅ Nerd Fonts installation completed' -ForegroundColor Green
}

################################################################################################
# SECTION 4: TOOL INSTALLATION VIA WINGET
################################################################################################

# Tools metadata: Name, executable command, Winget package Id
$Tools = @(
    @{ Name='gsudo';    Cmd='gsudo';    Id='gerardog.gsudo' },           # Elevation tool
    @{ Name='git';      Cmd='git';      Id='Git.Git' },                  # Git version control
    @{ Name='lazygit';  Cmd='lazygit';  Id='JesseDuffield.lazygit' },    # Terminal UI for Git
    @{ Name='Wget2';    Cmd='wget2';    Id='GNU.Wget2' },                # HTTP downloader
    @{ Name='curl';     Cmd='curl';     Id='cURL.cURL' },                # HTTP downloader
    @{ Name='tar';      Cmd='tar';      Id='GnuWin32.Tar' },             # Archive extractor
    @{ Name='unzip';    Cmd='unzip';    Id='GnuWin32.UnZip' },           # Zip extractor
    @{ Name='fzf';      Cmd='fzf';      Id='junegunn.fzf' },             # Fuzzy finder
    @{ Name='bat';      Cmd='bat';      Id='sharkdp.bat' },              # Enhanced cat replacement
    @{ Name='fd';       Cmd='fd';       Id='sharkdp.fd' },               # Fast file search
    @{ Name='lf';       Cmd='lf';       Id='gokcehan.lf' },              # Terminal file manager
    @{ Name='rg';       Cmd='rg';       Id='BurntSushi.ripgrep.MSVC' },  # Fast grep
    @{ Name='delta';    Cmd='delta';    Id='dandavison.delta' },         # Git diff viewer
    @{ Name='eza';      Cmd='eza';      Id='eza-community.eza' },        # LS replacement
    @{ Name='zoxide';   Cmd='zoxide';   Id='ajeetdsouza.zoxide' },       # Smart directory jumper
    @{ Name='starship'; Cmd='starship'; Id='Starship.Starship' },        # Shell prompt
    @{ Name='nvim';     Cmd='nvim';     Id='Neovim.Neovim' }             # Terminal editor
)

function Install-Tools {
    <#
    .SYNOPSIS
        Installs developer tools via Winget.
    .DESCRIPTION
        Iterates through a predefined list of tools.
        Skips tools already installed to ensure idempotency.
    #>
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
# SECTION 5: TERMINAL ICONS MODULE
################################################################################################

function Install-TerminalIcons {
    <#
    .SYNOPSIS
        Installs the Terminal-Icons PowerShell module for enhanced file icons.
    .DESCRIPTION
        Ensures PSGallery repository is trusted, then installs Terminal-Icons for the current user.
    #>
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
# SECTION 6: INSTALLATION VERIFICATION
################################################################################################

function Verify-Installation {
    <#
    .SYNOPSIS
        Verifies that all tools and modules were successfully installed.
    .DESCRIPTION
        Checks each tool in $Tools for its command availability and prints a summary.
    #>
    Write-Host '🔍 Verifying installed tools...' -ForegroundColor Cyan
    foreach ($Tool in $Tools) {
        if (Get-Command $Tool.Cmd -ErrorAction SilentlyContinue) {
            Write-Host "✅ $($Tool.Name) OK" -ForegroundColor Green
        } else {
            Write-Host "❌ $($Tool.Name) missing" -ForegroundColor Red
        }
    }

    # Verify Terminal-Icons
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Write-Host "✅ Terminal-Icons OK" -ForegroundColor Green
    } else {
        Write-Host "❌ Terminal-Icons missing" -ForegroundColor Red
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

# Install all components
Install-NerdFontsAuto
Install-Tools
Install-TerminalIcons
Verify-Installation

Write-Host '🎯 Setup completed successfully.' -ForegroundColor Cyan
