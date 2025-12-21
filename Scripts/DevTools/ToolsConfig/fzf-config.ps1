# =======================================================
# PowerShell fzf Setup
# Author: Fredaw Lomdo (Adapted for fzf)
# Repository: https://github.com/hetfs/powershell-profile
# =======================================================

$ErrorActionPreference = 'Stop'

# Check if fzf is already installed
$fzfFound = $false
$fzfPath = $null

# Check multiple possible installation locations
$possiblePaths = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe\fzf.exe",
    "$env:ProgramFiles\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe\fzf.exe",
    "$env:USERPROFILE\scoop\shims\fzf.exe",
    "$env:ProgramData\scoop\shims\fzf.exe",
    "$env:ChocolateyInstall\bin\fzf.exe",
    "$env:USERPROFILE\.fzf\bin\fzf.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $fzfPath = $path
        $fzfFound = $true
        break
    }
}

# Also check if it's in PATH
if (-not $fzfFound) {
    $fzfFound = [bool](Get-Command fzf -ErrorAction SilentlyContinue)
}

# If fzf not found, offer installation options
if (-not $fzfFound) {
    Write-Host "fzf not found. Installing it is recommended for the full setup." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can install it using one of these methods:" -ForegroundColor Cyan

    $installOptions = @(
        [PSCustomObject]@{
            Name     = 'WinGet'
            Command  = 'winget install junegunn.fzf'
        },
        [PSCustomObject]@{
            Name     = 'Chocolatey'
            Command  = 'choco install fzf'
        },
        [PSCustomObject]@{
            Name     = 'Manual'
            Command  = 'See: https://github.com/junegunn/fzf#installation'
            Comment  = '(Download from GitHub releases)'
        },
        [PSCustomObject]@{
            Name     = 'GitHub Script'
            Command  = 'powershell -c "irm https://junegunn.io/fzf/install-windows.ps1 | iex"'
            Comment  = '(Official Windows installer script)'

        },
        [PSCustomObject]@{
            Name     = 'Scoop'
            Command  = 'scoop install fzf'
            Comment  = '(Recommended for Windows with git)'
        }
    )

    $installOptions | ForEach-Object {
        Write-Host ("  • {0,-15} {1}" -f $_.Name, $_.Command) -ForegroundColor Green
        if ($_.Comment) { Write-Host ("    {0}" -f $_.Comment) -ForegroundColor DarkGray }
    }

    Write-Host ""
    $choice = Read-Host "Would you like to run one of these installers now? (Enter number, or press Enter to skip)"

    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $installOptions.Count) {
        $selected = $installOptions[[int]$choice - 1]

        # Special handling for the GitHub script
        if ($selected.Name -eq 'GitHub Script') {
            Write-Host "Running official fzf Windows installer script..." -ForegroundColor Cyan
            Write-Host "This script will download and install fzf with git integration." -ForegroundColor Cyan
            try {
                Invoke-RestMethod -Uri "https://junegunn.io/fzf/install-windows.ps1" | Invoke-Expression
            } catch {
                Write-Host "Error running installer script: $_" -ForegroundColor Red
                Write-Host "You can try a different installation method." -ForegroundColor Yellow
            }
        } elseif ($selected.Name -ne 'Manual') {
            Write-Host "Installing fzf via $($selected.Name)..." -ForegroundColor Cyan
            Invoke-Expression $selected.Command
        } else {
            Write-Host "Opening fzf GitHub releases page..." -ForegroundColor Cyan
            Start-Process "https://github.com/junegunn/fzf/releases"
        }
    } else {
        Write-Host "Skipping installation. You can install fzf manually later." -ForegroundColor Yellow
        Write-Host "The profile configuration will still be added." -ForegroundColor Yellow
    }
}

# -------------------------------
# PowerShell Profile Configuration
# -------------------------------
# fzf configuration for PowerShell
$FzfConfigBlock = @'
# ===== fzf configuration ======

if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Import the fzf module if available
    if (Get-Module -ListAvailable -Name PSFzf) {
        Import-Module PSFzf
        # Set PSReadLine key handler for fzf if PSReadLine is available
        if (Get-Module -ListAvailable -Name PSReadLine) {
            Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
        }
    } else {
        # Fallback basic integration if PSFzf module is not installed
        function fzf-select {
            fzf --height 40% --reverse --border
        }

        # Simple directory change with fzf
        function fzf-cd {
            $directory = Get-ChildItem -Directory -Recurse -Depth 3 |
                        Where-Object { $_.FullName -notmatch 'node_modules|\.git' } |
                        Select-Object -ExpandProperty FullName |
                        fzf-select
            if ($directory) {
                Set-Location $directory
            }
        }

        # Command history search with fzf
        function fzf-history {
            $command = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistory() | fzf-select
            if ($command) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
            }
        }

        # Set aliases for convenience
        Set-Alias -Name fz -Value fzf-select
        Set-Alias -Name fcd -Value fzf-cd
        Set-Alias -Name fh -Value fzf-history

        Write-Host "fzf basic integration loaded. Use 'fcd' to navigate, 'fh' for history." -ForegroundColor Cyan
    }

    # Set default fzf options for better Windows experience
    # $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --color=bg+:#3b4252,bg:#2e3440,spinner:#81a1c1,hl:#616e88,fg:#d8dee9,header:#616e88,info:#81a1c1,pointer:#81a1c1,marker:#81a1c1,fg+:#d8dee9,prompt:#81a1c1,hl+:#81a1c1'

    # Catppuccin for fzf  https://github.com/catppuccin/fzf/blob/main/themes/catppuccin-fzf-macchiato.ps1
     $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --color=bg+:#363A4F,bg:#24273A,spinner:#F4DBD6,hl:#ED8796, --color=fg:#CAD3F5,header:#ED8796,info:#C6A0F6,pointer:#F4DBD6, --color=marker:#B7BDF8,fg+:#CAD3F5,prompt:#C6A0F6,hl+:#ED8796, --color=selected-bg:#494D64, --color=border:#6E738D,label:#CAD3F5'
}
# ============= End fzf configuration ===========
'@

# Ensure the profile file exists
if (-not (Test-Path $PROFILE)) {
    Write-Host "Creating PowerShell profile at: $PROFILE" -ForegroundColor Cyan
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Check if fzf configuration already exists in profile
$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -and $profileContent -match '(fzf|PSFzf|fzf-select|fzf-cd|fzf-history)') {
    Write-Host "fzf configuration is already present in your PowerShell profile." -ForegroundColor Yellow
} else {
    # Add the configuration block to the profile
    Add-Content -Path $PROFILE -Value "`n$FzfConfigBlock"
    Write-Host "fzf configuration has been added to your PowerShell profile." -ForegroundColor Green
}

# -------------------------------
# Optional: Install PSFzf module
# -------------------------------
$installPSFzf = Read-Host "Would you like to install PSFzf module for better integration? (Y/N, default: Y)"
if ($installPSFzf -notmatch '^[Nn]') {
    Write-Host "Installing PSFzf module..." -ForegroundColor Cyan
    try {
        Install-Module -Name PSFzf -Scope CurrentUser -Force -ErrorAction Stop
        Write-Host "PSFzf module installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to install PSFzf module: $_" -ForegroundColor Red
        Write-Host "You can install it manually later with: Install-Module PSFzf" -ForegroundColor Yellow
    }
}

# -------------------------------
# Completion and Instructions
# -------------------------------
Write-Host ""
Write-Host "FZF SETUP COMPLETE" -ForegroundColor Green

# Verify fzf is available
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    Write-Host "✓ fzf is installed." -ForegroundColor Green
} else {
    Write-Host "⚠  fzf is not yet installed or not in PATH." -ForegroundColor Yellow
    Write-Host "   Install it using one of the methods above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
Write-Host "2. If you installed PSFzf, you can use:" -ForegroundColor White
Write-Host "   - Ctrl+R          # Search command history" -ForegroundColor Gray
Write-Host "   - Ctrl+T          # File search" -ForegroundColor Gray
Write-Host "   - Alt+C           # Directory navigation" -ForegroundColor Gray
Write-Host "3. Without PSFzf, use the provided aliases:" -ForegroundColor White
Write-Host "   - 'fcd'           # Change directory interactively" -ForegroundColor Gray
Write-Host "   - 'fh'            # Search command history" -ForegroundColor Gray
Write-Host "   - 'fz'            # Generic fzf selection" -ForegroundColor Gray
Write-Host "4. Try: Get-ChildItem | fz    # Pipe any list to fzf" -ForegroundColor White
Write-Host ""
Write-Host "Your profile is located at: $PROFILE" -ForegroundColor DarkGray
Write-Host ""
Write-Host "TIP: For best experience with fzf on Windows, install git:" -ForegroundColor Magenta
Write-Host "     winget install Git.Git" -ForegroundColor White
