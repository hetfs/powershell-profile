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
$FzfConfigBlock = @'
# ===== BEGIN FZF CONFIGURATION =====
if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
    return
}

# Global fzf defaults
# Catppuccin Macchiato theme
# https://github.com/catppuccin/fzf
$env:FZF_DEFAULT_OPTS = @"
--height=40%
--layout=reverse
--info=inline
--border
--margin=1
--padding=1
--multi
--walker-skip .git,node_modules,target
--preview 'bat --color=always {}'
--preview-window '~3'
--bind 'enter:become(nvim {+})'
--color=bg:#24273A,bg+:#363A4F
--color=fg:#CAD3F5,fg+:#CAD3F5
--color=hl:#ED8796,hl+:#ED8796
--color=info:#C6A0F6,prompt:#C6A0F6
--color=pointer:#F4DBD6,marker:#B7BDF8
--color=spinner:#F4DBD6
--color=selected-bg:#494D64
--color=border:#6E738D,label:#CAD3F5
# ---- Enable key bindings here ------
"@
# ===== END FZF CONFIGURATION =====
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
Write-Host ""
Write-Host "Your profile is located at: $PROFILE" -ForegroundColor DarkGray
Write-Host ""
Write-Host "TIP: For best experience with fzf on Windows, install git:" -ForegroundColor Magenta
Write-Host "     winget install Git.Git" -ForegroundColor White
