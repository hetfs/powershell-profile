# =======================================================
# PowerShell Bat Setup
# Author: Fredaw Lomdo (Adapted for bat)
# Repository: https://github.com/hetfs/powershell-profile
# =======================================================

$ErrorActionPreference = 'Stop'

# Check if bat is already installed
$batFound = $false

# Also check if it's in PATH
if (-not $batFound) {
    $batFound = [bool](Get-Command bat -ErrorAction SilentlyContinue)
    # Note: On Debian/Ubuntu, bat is sometimes installed as 'batcat' [citation:1]
    if (-not $batFound) {
        $batFound = [bool](Get-Command batcat -ErrorAction SilentlyContinue)
    }
}

# If bat not found, offer installation options
if (-not $batFound) {
    Write-Host "bat not found. This is a 'cat' clone with syntax highlighting and Git integration." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can install it using one of these methods:" -ForegroundColor Cyan

    $installOptions = @(
        [PSCustomObject]@{
            Name     = 'WinGet'
            Command  = 'winget install sharkdp.bat'
            Comment  = '(Recommended for Windows)'
        },
        [PSCustomObject]@{
            Name     = 'Scoop'
            Command  = 'scoop install bat'
        },
        [PSCustomObject]@{
            Name     = 'Chocolatey'
            Command  = 'choco install bat'
        },
        [PSCustomObject]@{
            Name     = 'Manual (Windows)'
            Command  = 'Download from: https://github.com/sharkdp/bat/releases'
            Comment  = '(Requires Visual C++ Redistributable) [citation:1]'
        },
        [PSCustomObject]@{
            Name     = 'Homebrew (macOS/Linux)'
            Command  = 'brew install bat'
            Comment  = ''
        },
        [PSCustomObject]@{
            Name     = 'Cargo (Rust)'
            Command  = 'cargo install --locked bat'
            Comment  = '(Requires Rust toolchain) [citation:1]'
        }
    )

    for ($i = 0; $i -lt $installOptions.Count; $i++) {
        $option = $installOptions[$i]
        $number = $i + 1
        Write-Host ("  {0}. {1,-20} {2}" -f $number, $option.Name, $option.Command) -ForegroundColor Green
        if ($option.Comment) { Write-Host ("     {0}" -f $option.Comment) -ForegroundColor DarkGray }
    }

    Write-Host ""
    $choice = Read-Host "Would you like to run one of these installers now? (Enter number, or press Enter to skip)"

    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $installOptions.Count) {
        $selected = $installOptions[[int]$choice - 1]

        if ($selected.Name -eq 'Manual (Windows)') {
            Write-Host "Opening bat GitHub releases page..." -ForegroundColor Cyan
            Start-Process "https://github.com/sharkdp/bat/releases"
        } else {
            Write-Host "Installing bat via $($selected.Name)..." -ForegroundColor Cyan
            Invoke-Expression $selected.Command
        }
    } else {
        Write-Host "Skipping installation. You can install bat manually later." -ForegroundColor Yellow
        Write-Host "The profile configuration will still be added." -ForegroundColor Yellow
    }
}

# -------------------------------
# PowerShell Profile Configuration
# -------------------------------
# bat configuration for PowerShell
$BatConfigBlock = @'
# bat configuration - A cat(1) clone with syntax highlighting and Git integration [citation:1]
if (Get-Command bat -ErrorAction SilentlyContinue) {
    # Set default bat options
    $env:BAT_PAGER = ""  # Disable pager for better PowerShell integration
    $env:BAT_STYLE = "numbers,changes,header"
    $env:BAT_THEME = "TwoDark"  # Use 'bat --list-themes' to see available themes

    # Create alias to replace cat with bat (without paging) [citation:1]
    if (-not (Get-Alias cat -ErrorAction SilentlyContinue)) {
        Set-Alias -Name cat -Value bat -Option AllScope
    }

    # Function to view bat themes
    function bat-themes {
        bat --list-themes | fzf --preview "bat --theme={} --color=always $PSHOME\profile.ps1"
    }

    # Function to view with line numbers only
    function batn {
        param([Parameter(ValueFromPipeline=$true)]$Path)
        bat --style=numbers $Path
    }

    # Function to show all characters (including non-printable) [citation:1]
    function bata {
        param([Parameter(ValueFromPipeline=$true)]$Path)
        bat --show-all $Path
    }

    # Function for plain output (no decorations, good for piping) [citation:1]
    function batp {
        param([Parameter(ValueFromPipeline=$true)]$Path)
        bat --plain $Path
    }

    # Function to use bat as a pager for other commands
    function batpipe {
        $input | bat --style=plain --color=always
    }

    # Function to view Git differences with bat
    function batdiff {
        git diff --name-only --relative --diff-filter=d | ForEach-Object {
            bat --diff "$_"
        }
    }

    # Function to view help with bat colorization [citation:1]
    function bathelp {
        param($Command)
        if ($Command) {
            & $Command --help 2>&1 | bat --language=help --style=plain
        } else {
            Write-Host "Usage: bathelp <command>" -ForegroundColor Yellow
            Write-Host "Example: bathelp git" -ForegroundColor Gray
        }
    }

    # Set BAT_CONFIG_DIR if you want a custom config location
    # $env:BAT_CONFIG_DIR = "$HOME\.config\bat"

    Write-Host "bat loaded. Use 'cat' for bat, 'batn' for line numbers, 'bathelp <cmd>' for colored help." -ForegroundColor Cyan
} elseif (Get-Command batcat -ErrorAction SilentlyContinue) {
    # Handle Debian/Ubuntu systems where it's installed as batcat [citation:1]
    Set-Alias -Name bat -Value batcat -Option AllScope
    if (-not (Get-Alias cat -ErrorAction SilentlyContinue)) {
        Set-Alias -Name cat -Value batcat -Option AllScope
    }
    Write-Host "bat (as batcat) loaded. Using 'batcat' command." -ForegroundColor Cyan
}
'@

# Ensure the profile file exists [citation:2]
if (-not (Test-Path $PROFILE)) {
    Write-Host "Creating PowerShell profile at: $PROFILE" -ForegroundColor Cyan
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Check if bat configuration already exists in profile
$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -and $profileContent -match '(bat\s+configuration|BAT_PAGER|BAT_THEME|function batn|function bata)') {
    Write-Host "bat configuration is already present in your PowerShell profile." -ForegroundColor Yellow
} else {
    # Add the configuration block to the profile
    Add-Content -Path $PROFILE -Value "`n$BatConfigBlock"
    Write-Host "bat configuration has been added to your PowerShell profile." -ForegroundColor Green
}

# -------------------------------
# Optional: Create bat config directory and files
# -------------------------------
$batConfigDir = Join-Path $HOME ".config\bat"
if (-not (Test-Path $batConfigDir)) {
    Write-Host "Creating bat config directory: $batConfigDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $batConfigDir -Force | Out-Null
}

# Create a basic config file if it doesn't exist
$batConfigFile = Join-Path $batConfigDir "config"
if (-not (Test-Path $batConfigFile)) {
    @'
# bat configuration file
# See: https://github.com/sharkdp/bat#configuration-file

# Disable paging by default (better for PowerShell)
--paging=never

# Always show line numbers, git modifications, and file header
--style=numbers,changes,header

# Use a nice theme (change to your preference)
--theme=TwoDark

# Syntax highlighting for specific file types
--map-syntax "*.conf:INI"
--map-syntax ".env*:Shell"
--map-syntax "Dockerfile*:Dockerfile"
'@ | Set-Content -Path $batConfigFile -Encoding UTF8
    Write-Host "Created sample bat configuration at: $batConfigFile" -ForegroundColor Green
}

# -------------------------------
# Completion and Instructions
# -------------------------------
Write-Host ""
Write-Host "BAT SETUP COMPLETE" -ForegroundColor Green

# Verify bat is available
$batCmd = if (Get-Command bat -ErrorAction SilentlyContinue) { "bat" }
         elseif (Get-Command batcat -ErrorAction SilentlyContinue) { "batcat" }
         else { $null }

if ($batCmd) {
    Write-Host "✓ bat is installed." -ForegroundColor Green
} else {
    Write-Host "⚠  bat is not yet installed or not in PATH." -ForegroundColor Yellow
    Write-Host "   Install it using one of the methods above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
Write-Host "2. Try these commands:" -ForegroundColor White
Write-Host "   - 'cat README.md'            # View any file with syntax highlighting" -ForegroundColor Gray
Write-Host "   - 'batn script.ps1'          # View with line numbers only" -ForegroundColor Gray
Write-Host "   - 'bata file.txt'            # Show all characters" -ForegroundColor Gray
Write-Host "   - 'bathelp git'              # View colored help for any command" -ForegroundColor Gray
Write-Host "   - 'bat --list-themes'        # See all available color themes" -ForegroundColor Gray
Write-Host "3. Customize themes: Change BAT_THEME in your profile or config file" -ForegroundColor White
Write-Host ""
Write-Host "TIP: For integration with fzf, use:" -ForegroundColor Magenta
Write-Host "     fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'" -ForegroundColor White
Write-Host ""
Write-Host "Configuration files:" -ForegroundColor DarkGray
Write-Host "  PowerShell profile: $PROFILE" -ForegroundColor DarkGray
if (Test-Path $batConfigFile) {
    Write-Host "  bat config file:   $batConfigFile" -ForegroundColor DarkGray
}
