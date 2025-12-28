# =======================================================
# PowerShell eza Setup with Catppuccin Mocha Theme
# Author: Fredaw Lomdo
# Repository: https://github.com/hetfs/powershell-profile
# =======================================================

$ErrorActionPreference = 'Stop'

# ----------------------
# Helpers
# ----------------------
function Write-Status {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-Command {
    param([string]$Name)
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# ----------------------
# Install / Upgrade eza
# ----------------------
Write-Status 'Checking for eza installation...' Cyan

if (-not (Test-Command 'eza')) {
    Write-Status 'Installing eza via winget...' Cyan

    winget install --id eza-community.eza `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements `
        -e

    if (-not (Test-Command 'eza')) {
        Write-Status '✗ Failed to install eza' Red
        exit 1
    }

    Write-Status '✓ eza installed successfully' Green
} else {
    Write-Status '✓ eza already installed' Green

    winget upgrade --id eza-community.eza `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements `
        | Out-Null
}

# ----------------------
# Configuration paths
# ----------------------
$EzaConfigDir = "$env:USERPROFILE\.config\eza"
$ThemeFile    = Join-Path $EzaConfigDir 'theme.yml'

if (-not (Test-Path $EzaConfigDir)) {
    New-Item -ItemType Directory -Path $EzaConfigDir -Force | Out-Null
    Write-Status "Created config directory: $EzaConfigDir" Green
}

# ----------------------
# Catppuccin Mocha theme (FULL OFFICIAL)
# ----------------------
Write-Status 'Installing Catppuccin Mocha theme...' Cyan

@"
colourful: true

filekinds:
  normal: {foreground: "#BAC2DE"}
  directory: {foreground: "#89B4FA"}
  symlink: {foreground: "#89DCEB"}
  pipe: {foreground: "#7F849C"}
  block_device: {foreground: "#EBA0AC"}
  char_device: {foreground: "#EBA0AC"}
  socket: {foreground: "#585B70"}
  special: {foreground: "#CBA6F7"}
  executable: {foreground: "#A6E3A1"}
  mount_point: {foreground: "#74C7EC"}

perms:
  user_read: {foreground: "#CDD6F4"}
  user_write: {foreground: "#F9E2AF"}
  user_execute_file: {foreground: "#A6E3A1"}
  user_execute_other: {foreground: "#A6E3A1"}
  group_read: {foreground: "#BAC2DE"}
  group_write: {foreground: "#F9E2AF"}
  group_execute: {foreground: "#A6E3A1"}
  other_read: {foreground: "#A6ADC8"}
  other_write: {foreground: "#F9E2AF"}
  other_execute: {foreground: "#A6E3A1"}
  special_user_file: {foreground: "#CBA6F7"}
  special_other: {foreground: "#585B70"}
  attribute: {foreground: "#A6ADC8"}

size:
  major: {foreground: "#A6ADC8"}
  minor: {foreground: "#89DCEB"}
  number_byte: {foreground: "#CDD6F4"}
  number_kilo: {foreground: "#BAC2DE"}
  number_mega: {foreground: "#89B4FA"}
  number_giga: {foreground: "#CBA6F7"}
  number_huge: {foreground: "#CBA6F7"}
  unit_byte: {foreground: "#A6ADC8"}
  unit_kilo: {foreground: "#89B4FA"}
  unit_mega: {foreground: "#CBA6F7"}
  unit_giga: {foreground: "#CBA6F7"}
  unit_huge: {foreground: "#74C7EC"}

users:
  user_you: {foreground: "#CDD6F4"}
  user_root: {foreground: "#F38BA8"}
  user_other: {foreground: "#CBA6F7"}
  group_yours: {foreground: "#BAC2DE"}
  group_other: {foreground: "#7F849C"}
  group_root: {foreground: "#F38BA8"}

links:
  normal: {foreground: "#89DCEB"}
  multi_link_file: {foreground: "#74C7EC"}

git:
  new: {foreground: "#A6E3A1"}
  modified: {foreground: "#F9E2AF"}
  deleted: {foreground: "#F38BA8"}
  renamed: {foreground: "#94E2D5"}
  typechange: {foreground: "#F5C2E7"}
  ignored: {foreground: "#7F849C"}
  conflicted: {foreground: "#EBA0AC"}

git_repo:
  branch_main: {foreground: "#CDD6F4"}
  branch_other: {foreground: "#CBA6F7"}
  git_clean: {foreground: "#A6E3A1"}
  git_dirty: {foreground: "#F38BA8"}

security_context:
  colon: {foreground: "#7F849C"}
  user: {foreground: "#BAC2DE"}
  role: {foreground: "#CBA6F7"}
  typ: {foreground: "#585B70"}
  range: {foreground: "#CBA6F7"}

file_type:
  image: {foreground: "#F9E2AF"}
  video: {foreground: "#F38BA8"}
  music: {foreground: "#A6E3A1"}
  lossless: {foreground: "#94E2D5"}
  crypto: {foreground: "#585B70"}
  document: {foreground: "#CDD6F4"}
  compressed: {foreground: "#F5C2E7"}
  temp: {foreground: "#EBA0AC"}
  compiled: {foreground: "#74C7EC"}
  build: {foreground: "#585B70"}
  source: {foreground: "#89B4FA"}

punctuation: {foreground: "#7F849C"}
date: {foreground: "#F9E2AF"}
inode: {foreground: "#A6ADC8"}
blocks: {foreground: "#9399B2"}
header: {foreground: "#CDD6F4"}
octal: {foreground: "#94E2D5"}
flags: {foreground: "#CBA6F7"}

symlink_path: {foreground: "#89DCEB"}
control_char: {foreground: "#74C7EC"}
broken_symlink: {foreground: "#F38BA8"}
broken_path_overlay: {foreground: "#585B70"}
"@ | Out-File -Encoding UTF8 -FilePath $ThemeFile -Force

Write-Status "✓ Theme saved to $ThemeFile" Green

# ----------------------
# PowerShell profile
# ----------------------
$EzaProfileBlock = @'
# ===== BEGIN EZA CONFIGURATION =====

$env:EZA_CONFIG_DIR = "$env:USERPROFILE\.config\eza"

if (Test-Path env:\LS_COLORS) { Remove-Item env:\LS_COLORS }
if (Test-Path env:\EXA_COLORS) { Remove-Item env:\EXA_COLORS }

if (Get-Command eza -ErrorAction SilentlyContinue) {

    function ls  { eza --icons @args }
    function ll  { eza -lh --git --icons @args }
    function la  { eza -lah --git --icons @args }
    function lt  { eza --tree --level=2 --icons @args }
    function treeg { eza --tree --git --icons @args }

    function llt { eza -lh --git --icons --sort=modified @args }
    function lls { eza -lh --git --icons --sort=size @args }
    function lsd { eza -D --icons @args }

    function eza-info {
        eza --version
        Write-Host "Theme: $env:EZA_CONFIG_DIR\theme.yml"
    }

    function eza-test {
        eza --icons --git --header
    }
}

# ===== END EZA CONFIGURATION =====
'@

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -notmatch '# ===== BEGIN EZA CONFIGURATION =====') {
    Add-Content -Path $PROFILE -Value "`n$EzaProfileBlock"
    Write-Status '✓ PowerShell profile updated' Green
} else {
    Write-Status '✓ eza already configured in profile' Yellow
}

# ----------------------
# Verification
# ----------------------
Write-Status 'Testing eza...' Cyan
eza --version | Out-Null
Write-Status '✓ eza is operational' Green

# ----------------------
# Completion
# ----------------------
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Status 'EZA SETUP COMPLETE' Green
Write-Host '==================================================' -ForegroundColor Cyan

Write-Status 'Aliases available:' Magenta
Write-Host '  ls, ll, la, lt, llt, lls, lsd, treeg'
Write-Host '  eza-info, eza-test'

Write-Status "`nRestart PowerShell or run: . `$PROFILE" Cyan
Write-Status 'Enjoy Catppuccin Mocha with eza 🎨' Magenta
