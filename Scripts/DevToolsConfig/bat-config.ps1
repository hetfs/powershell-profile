# =======================================================
# Bat + Catppuccin Setup (Delta optional skipped)
# Windows-first, CI-safe, idempotent
# =======================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -------------------------------------------------------
# UI Helpers
# -------------------------------------------------------
$Colors = @{
    Info    = 'Cyan'
    Success = 'Green'
    Warning = 'Yellow'
    Error   = 'Red'
}

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error')]
        [string]$Type = 'Info'
    )
    $icon = @{
        Info    = '•'
        Success = '✓'
        Warning = '⚠'
        Error   = '✗'
    }[$Type]

    Write-Host "$icon $Message" -ForegroundColor $Colors[$Type]
}

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# -------------------------------------------------------
# Bat Helpers
# -------------------------------------------------------
function Install-Bat {
    Write-Status "Installing bat..." -Type Info

    if (Test-Command winget) {
        winget install --id sharkdp.bat --source winget `
            --accept-package-agreements --accept-source-agreements --silent
        return
    }

    throw "No supported package manager found. Please install bat manually: https://github.com/sharkdp/bat/releases"
}

function Find-BatExecutable {
    # First, try current PATH
    $cmd = Get-Command bat.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    # Fallback to default WindowsApps install location
    $defaultPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\bat.exe"
    if (Test-Path $defaultPath) {
        if ($env:PATH -notlike "*$env:LOCALAPPDATA\Microsoft\WindowsApps*") {
            $env:PATH = "$env:LOCALAPPDATA\Microsoft\WindowsApps;$env:PATH"
        }
        return $defaultPath
    }

    throw "bat.exe was installed but could not be located. Restart PowerShell to refresh PATH."
}

function Get-BatConfigDir {
    param([string]$BatCmd)
    # Use custom config directory
    $BAT_CONFIG_DIR = Resolve-Path "~/.config/bat" -ErrorAction SilentlyContinue
    if (-not $BAT_CONFIG_DIR) {
        $BAT_CONFIG_DIR = Join-Path $HOME ".config\bat"
        New-Item -ItemType Directory -Force -Path $BAT_CONFIG_DIR | Out-Null
    }
    return $BAT_CONFIG_DIR
}

function Install-CatppuccinTheme {
    param([string]$BatCmd)

    Write-Status "Installing Catppuccin Mocha theme..." -Type Info

    $themesDir = Join-Path (Get-BatConfigDir $BatCmd) 'themes'
    if (-not (Test-Path $themesDir)) {
        New-Item -ItemType Directory -Force -Path $themesDir | Out-Null
    }

    $themeFile = Join-Path $themesDir "Catppuccin Mocha.tmTheme"
    if (-not (Test-Path $themeFile)) {
        $url = "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
        try {
            Invoke-WebRequest -Uri $url -OutFile $themeFile -ErrorAction Stop
            Write-Status "Catppuccin Mocha theme installed" -Type Success
        }
        catch {
            Write-Status "Failed to download Catppuccin Mocha theme: $($_.Exception.Message)" -Type Error
        }
    }
    else {
        Write-Status "Catppuccin Mocha theme already exists" -Type Info
    }

    # Build bat cache
    & $BatCmd cache --build | Out-Null
    Write-Status "Bat cache built successfully" -Type Success
}

function Configure-Bat {
    param([string]$BatCmd)

    $configDir  = Get-BatConfigDir $BatCmd
    $configFile = Join-Path $configDir 'config'

@"
# =======================================================
# bat configuration file for Windows
# Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# Repository: https://github.com/sharkdp/bat
# Documentation: https://github.com/sharkdp/bat#configuration-file
# Catppuccin theme: Catppuccin Mocha
# =======================================================

# ──────────────────────────────────────────────────────
# Core Behavior
# ──────────────────────────────────────────────────────
--paging=always
--pager="delta"
--color=always
--strip-ansi=auto

# ──────────────────────────────────────────────────────
# Git Integration
# ──────────────────────────────────────────────────────
--diff-context=3

# ──────────────────────────────────────────────────────
# Display Style
# ──────────────────────────────────────────────────────
--style=numbers,changes,header,grid
--wrap=auto

# ──────────────────────────────────────────────────────
# Theme
# ──────────────────────────────────────────────────────
# Controlled via BAT_THEME environment variable
# =======================================================
# Only Catppuccin Mocha is supported
# Set in PowerShell profile:
# $env:BAT_THEME = "Catppuccin Mocha"

# ──────────────────────────────────────────────────────
# Syntax Mapping
# ──────────────────────────────────────────────────────
--map-syntax ".ignore:Git Ignore"
--map-syntax "*.conf:INI"
--map-syntax "*.env:INI"
--map-syntax "Dockerfile*:Dockerfile"
--map-syntax "Jenkinsfile*:Groovy"
--map-syntax "Makefile:Makefile"
--map-syntax "*.mk:Makefile"
"@ | Set-Content -Encoding UTF8 -Path $configFile

    Write-Status "Bat configuration written to $configFile" -Type Success
}

function Configure-PowerShellProfile {
    Write-Status "Configuring PowerShell profile..." -Type Info

    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

    $content = Get-Content $PROFILE -Raw
    if ($content -match 'BAT_THEME') { return }

@"
# ===== BEGIN BAT_THEME CONFIGURATION =====
# Bat theme environment
`$env:BAT_THEME = "Catppuccin Mocha"
# ===== END BAT_THEME CONFIGURATION =====
"@ | Add-Content $PROFILE

    Write-Status "BAT_THEME variable added to PowerShell profile" -Type Success
}

# -------------------------------------------------------
# Execution
# -------------------------------------------------------
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " bat + Catppuccin setup" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

try {
    # Install bat if missing
    if (-not (Test-Command bat)) {
        Install-Bat
    }

    $batCmd = Find-BatExecutable

    # Install theme and configure bat
    Install-CatppuccinTheme -BatCmd $batCmd
    Configure-Bat -BatCmd $batCmd
    Configure-PowerShellProfile

    Write-Status "Setup complete!" -Type Success
    Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Yellow
}
catch {
    Write-Status $_.Exception.Message -Type Error
    exit 1
}
