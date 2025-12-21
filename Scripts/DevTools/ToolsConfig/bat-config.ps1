# bat-config.ps1
# =======================================================
# bat + Catppuccin Mocha setup
# Official theme instructions compliant
# Windows-first, CI-safe, idempotent
# =======================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

function Get-BatCommand {
    if (Get-Command bat -ErrorAction SilentlyContinue) { return 'bat' }
    if (Get-Command batcat -ErrorAction SilentlyContinue) { return 'batcat' }
    return $null
}

function Install-Bat {
    Write-Status "Installing bat..." -Type Info

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Status "Using winget package manager" -Type Info
        winget install --id sharkdp.bat --source winget `
            --accept-package-agreements --accept-source-agreements `
            --silent
        return
    }

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Status "Using Chocolatey package manager" -Type Info
        choco install bat -y
        return
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Status "Using Scoop package manager" -Type Info
        scoop install bat
        return
    }

    throw "No supported package manager found. Install bat manually from: https://github.com/sharkdp/bat/releases"
}

function Get-BatConfigDir {
    param([string]$BatCmd)

    $result = & $BatCmd --config-dir
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to get bat config directory. Is bat installed correctly?"
    }
    return $result.Trim()
}

function Install-CatppuccinThemes {
    param([string]$BatCmd)

    Write-Status "Installing Catppuccin themes..." -Type Info

    $configDir = Get-BatConfigDir $BatCmd
    $themesDir = Join-Path $configDir 'themes'

    # Create themes directory
    if (-not (Test-Path $themesDir)) {
        New-Item -ItemType Directory -Force -Path $themesDir | Out-Null
        Write-Status "Created themes directory: $themesDir" -Type Success
    }

    # List of Catppuccin themes
    $themes = @(
        "Catppuccin Latte",
        "Catppuccin Frappe",
        "Catppuccin Macchiato",
        "Catppuccin Mocha"
    )

    # Download each theme
    foreach ($theme in $themes) {
        $fileName = "$theme.tmTheme"
        $filePath = Join-Path $themesDir $fileName

        # Skip if already exists (idempotent)
        if (Test-Path $filePath) {
            Write-Status "Theme already exists: $fileName" -Type Info
            continue
        }

        $urlTheme = $theme -replace " ", "%20"
        $url = "https://github.com/catppuccin/bat/raw/main/themes/$urlTheme.tmTheme"

        try {
            Write-Status "Downloading: $fileName" -Type Info
            Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop
            Write-Status "Downloaded: $fileName" -Type Success
        }
        catch {
            Write-Status "Failed to download ${fileName}: $($_.Exception.Message)" -Type Error
            # Continue with other themes even if one fails
        }
    }

    # Build bat cache
    Write-Status "Building bat cache..." -Type Info
    & $BatCmd cache --build
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Bat cache built successfully" -Type Success
    }
    else {
        Write-Status "Warning: Failed to build bat cache" -Type Warning
    }
}

function Configure-Bat {
    param([string]$BatCmd)

    Write-Status "Configuring bat..." -Type Info

    $configDir = Get-BatConfigDir $BatCmd
    $configPath = Join-Path $configDir 'config'

    # Check if config already exists
    if (Test-Path $configPath) {
        Write-Status "Backing up existing config file..." -Type Warning
        $backupPath = "$configPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $configPath $backupPath -Force
        Write-Status "Backup saved to: $backupPath" -Type Info
    }

    # Create comprehensive configuration
@"
# =======================================================
# bat configuration file for Windows
# Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# Repository: https://github.com/sharkdp/bat
# Documentation: https://github.com/sharkdp/bat#configuration-file
# Catppuccin themes: https://github.com/catppuccin/bat
# =======================================================

# ─── Core Behavior ─────────────────────────────────────
# Disable paging by default (better for PowerShell/Windows Terminal)
--paging=never

# Force color output (always use colors, even when piping)
--color=always

# Set tab width (adjust to your preference)
--tabs=4

# Show non-printable characters (like tabs, spaces, line endings)
# --show-all


# ─── Display Style ─────────────────────────────────────
# Style components: numbers, changes (git), header, grid, rule
--style=numbers,changes,header,grid

# Show the line numbers (absolute)
--line-range=
# Highlight the line at the cursor position (when using --style=full)
--highlight-line=

# Wrap long lines (set to 'never', 'character', or 'number')
--wrap=auto


# ─── Theme & Colors ─────────────────────────────────────
# Theme: Catppuccin Mocha (dark), Latte (light), Frappe, Macchiato
--theme="Catppuccin Mocha"

# Custom theme file (if you want to use a custom .tmTheme file)
# --theme="path\to\your\theme.tmTheme"

# Italic text support (requires terminal and font support)
--italic-text=always


# ─── Language & Syntax ──────────────────────────────────
# Default language for unknown file types
--language=

# Map file extensions/names to languages
--map-syntax="*.conf:INI"
--map-syntax="*.env:INI"
--map-syntax="Dockerfile*:Dockerfile"
--map-syntax="Jenkinsfile*:Groovy"
--map-syntax="Makefile:Makefile"
--map-syntax="*.mk:Makefile"


# ─── Git Integration ───────────────────────────────────
# Show git modifications in the side bar (requires --style=changes)
--diff-context=3

# Only show git changes from the current file
# --diff=file

"@ | Set-Content -Path $configPath -Encoding UTF8

    Write-Status "Configuration written to: $configPath" -Type Success
}

function Configure-PowerShellProfile {
    Write-Status "Configuring PowerShell profile..." -Type Info

    # Create profile if it doesn't exist
    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        Write-Status "Created PowerShell profile: $PROFILE" -Type Success
    }

    $profileContent = Get-Content $PROFILE -Raw

    # Check if BAT_THEME is already set
    if ($profileContent -match "BAT_THEME") {
        Write-Status "BAT_THEME already configured in profile" -Type Info
        return
    }

    # Add BAT_THEME environment variable
    $batThemeConfig = @"

# Bat configuration
`$env:BAT_THEME = "Catppuccin Mocha"

"@

    Add-Content -Path $PROFILE -Value $batThemeConfig
    Write-Status "Added BAT_THEME to PowerShell profile" -Type Success
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# =======================================================
# Execution
# =======================================================

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " bat + Catppuccin Theme Setup (Official)" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# Check if running as administrator (recommended for package managers)
if (-not (Test-Administrator)) {
    Write-Status "Warning: Not running as administrator. Some package managers may require elevated privileges." -Type Warning
    Write-Status "If installation fails, try running this script as Administrator." -Type Warning
    Write-Host ""
}

try {
    # Check for bat installation
    $batCmd = Get-BatCommand
    if (-not $batCmd) {
        Write-Status "bat not found. Installing..." -Type Info
        Install-Bat
        $batCmd = Get-BatCommand

        if (-not $batCmd) {
            throw "Failed to install or find bat. Please install manually."
        }

        Write-Status "bat installed successfully" -Type Success
    }
    else {
        Write-Status "Found bat command: $batCmd" -Type Success
    }

    # Install Catppuccin themes
    Install-CatppuccinThemes -BatCmd $batCmd

    # Configure bat
    Configure-Bat -BatCmd $batCmd

    # Configure PowerShell profile
    Configure-PowerShellProfile

    Write-Host "`n" + "="*60 -ForegroundColor Green
    Write-Status "Setup complete!" -Type Success
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor Yellow
    Write-Host "2. Test with: bat --list-themes | findstr Catppuccin" -ForegroundColor Yellow
    Write-Host "3. Test with: bat C:\Windows\System32\drivers\etc\hosts" -ForegroundColor Yellow
    Write-Host "4. Change theme with: bat --theme='Catppuccin Latte'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Available Catppuccin themes:" -ForegroundColor Cyan
    Write-Host "  • Catppuccin Mocha (dark - default)" -ForegroundColor White
    Write-Host "  • Catppuccin Macchiato (dark)" -ForegroundColor White
    Write-Host "  • Catppuccin Frappe (dark)" -ForegroundColor White
    Write-Host "  • Catppuccin Latte (light)" -ForegroundColor White
    Write-Host ""
    Write-Host "To change the default theme, edit:" -ForegroundColor Cyan
    Write-Host "  `$env:BAT_THEME in your PowerShell profile" -ForegroundColor Yellow
    Write-Host "  or the --theme setting in $(bat --config-dir)\config" -ForegroundColor Yellow
    Write-Host "="*60 -ForegroundColor Green
}
catch {
    Write-Status "Setup failed: $($_.Exception.Message)" -Type Error
    Write-Host "`nTroubleshooting tips:" -ForegroundColor Red
    Write-Host "• Run PowerShell as Administrator" -ForegroundColor Yellow
    Write-Host "• Install bat manually: winget install sharkdp.bat" -ForegroundColor Yellow
    Write-Host "• Check network connection for theme downloads" -ForegroundColor Yellow
    exit 1
}
