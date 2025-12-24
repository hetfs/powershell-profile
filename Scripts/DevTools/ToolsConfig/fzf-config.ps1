# =======================================================
# PowerShell fzf Setup
# Author: Fredaw Lomdo (Adapted for fzf)
# Repository: https://github.com/hetfs/powershell-profile
# =======================================================

$ErrorActionPreference = 'Stop'

# Helper function for colored status messages
function Write-Status {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Helper function to test if a command exists
function Test-Command {
    param([string]$CommandName)
    return [bool](Get-Command $CommandName -ErrorAction SilentlyContinue)
}

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
        Write-Status "Found fzf at: $path" Green
        break
    }
}

# Also check if it's in PATH
if (-not $fzfFound) {
    $fzfFound = Test-Command "fzf"
    if ($fzfFound) {
        Write-Status "fzf found in PATH" Green
    }
}

# ----------------------
# Tools installation (silent)
# ----------------------
$tools = @{
    'fzf' = @{Id = 'junegunn.fzf'}
    'bat' = @{Id = 'sharkdp.bat'}
    'fd' = @{Id = 'sharkdp.fd'}
    'rg' = @{Id = 'BurntSushi.ripgrep.MSVC'}
}

foreach ($tool in $tools.Keys) {
    if (-not (Test-Command $tool)) {
        try {
            Write-Status "Installing $tool..." Cyan
            winget install --id $($tools[$tool].Id) -e --silent --accept-package-agreements --accept-source-agreements
            Write-Status "Installed $tool" Green
        }
        catch {
            Write-Status "Failed to install $tool. You may need to run as admin." Red
            Write-Status "Error: $_" Red
        }
    }
    else {
        Write-Status "$tool already installed" Gray
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
--height=60%
--layout=reverse
--info=inline
--border
--input-label ' Input ' --header-label ' File Type '
--margin=1
--padding=1
--multi
--walker-skip=.git,node_modules,target
--preview="bat --color=always {}"
--preview-window="~3"
--preview-window="right:60%:wrap"

--bind="enter:become(nvim {+})"
--bind="ctrl-j:down,ctrl-k:up"
--bind="ctrl-d:preview-page-down,ctrl-u:preview-page-up"
--bind="ctrl-/:toggle-preview"
--bind=focus:transform-header:file

--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8
--color=selected-bg:#45475A
--color=border:#6C7086,label:#CDD6F4
--color=preview-border:#9999cc,preview-label:#ccccff
--color=list-border:#669966,list-label:#99cc99
--color=input-border:#996666,input-label:#ffcccc
--color=header-border:#6699cc,header-label:#99ccff
"@
# ===== END FZF CONFIGURATION =====
'@

# Ensure the profile file exists
if (-not (Test-Path $PROFILE)) {
    Write-Status "Creating PowerShell profile at: $PROFILE" Cyan
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Check if fzf configuration already exists in profile
$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -and $profileContent -match '# ===== BEGIN FZF CONFIGURATION =====') {
    Write-Status "fzf configuration is already present in your PowerShell profile." Yellow
}
else {
    # Add the configuration block to the profile
    Add-Content -Path $PROFILE -Value "`n$FzfConfigBlock"
    Write-Status "fzf configuration has been added to your PowerShell profile." Green
}

# -------------------------------
# Completion and Instructions
# -------------------------------
Write-Host ""
Write-Status "FZF SETUP COMPLETE" Green

# Verify fzf is available
if (Test-Command "fzf") {
    Write-Status "✓ fzf is installed." Green
}
else {
    Write-Status "⚠  fzf is not yet installed or not in PATH." Yellow
    Write-Status "   Install it using one of the methods above." Yellow
}

Write-Host ""
Write-Status "NEXT STEPS:" Cyan
Write-Status "1. Restart PowerShell or run: . `$PROFILE" White
Write-Host ""
Write-Status "Your profile is located at: $PROFILE" DarkGray
Write-Host ""
Write-Status "TIP: Use Ctrl+F to search files in the current directory" Cyan
Write-Status "TIP: Use fzf with Ctrl+R for command history search" Cyan
