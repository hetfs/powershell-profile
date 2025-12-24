# =======================================================
# PowerShell Zoxide Configuration (Idempotent & Silent)
# Author: Fredaw Lomdo
# Repository: https://github.com/hetfs/powershell-profile
# =======================================================

$ErrorActionPreference = 'Stop'

Write-Host "▶ Configuring Zoxide for PowerShell..." -ForegroundColor Cyan

# -------------------------------------------------------
# Utility: Detect zoxide
# -------------------------------------------------------
function Test-ZoxideInstalled {
    return [bool](Get-Command zoxide -ErrorAction SilentlyContinue)
}

# -------------------------------------------------------
# Ensure PowerShell profile exists
# -------------------------------------------------------
if (-not (Test-Path $PROFILE)) {
    Write-Host "• Creating PowerShell profile: $PROFILE" -ForegroundColor Yellow
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# -------------------------------------------------------
# Zoxide configuration block (idempotent)
# -------------------------------------------------------
$ZoxideBlock = @'
# ===== BEGIN ZOXIDE CONFIGURATION =====
if (Get-Command zoxide -ErrorAction SilentlyContinue) {

    Invoke-Expression (& {
        $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
        (zoxide init --hook $hook powershell) -join "`n"
    })

    # ---------------------------------------------------
    # Optional: Custom environment variables
    # Uncomment to enable
    # ---------------------------------------------------
    # $env:_ZO_EXCLUDE_DIRS = 'C:\Users\*\.git,C:\Windows\System32'
    # $env:_ZO_MAXAGE = 10000
    # $env:_ZO_RESOLVE_SYMLINKS = 1

    # ---------------------------------------------------
    # Core commands
    # ---------------------------------------------------

    # Jump to directory
    function z {
        __zoxide_z @args
    }

    # Interactive jump (fzf optional)
    function zi {
        __zoxide_zi
    }

    # Add directory to database
    function za {
        param([string]$Path = (Get-Location).Path)
        zoxide add $Path
    }

    # Query database without cd
    function zq {
        zoxide query @args
    }

    # List matching directories
    function zl {
        zoxide query -l @args
    }

    # Remove directory from database
    function zr {
        param([string]$Path)
        if ($Path) {
            zoxide remove $Path
        }
    }

    # Clear entire database
    function zc {
        zoxide query -l | ForEach-Object { zoxide remove $_ }
    }

    # ---------------------------------------------------
    # Optional aliases (uncomment if desired)
    # ---------------------------------------------------
    # Set-Alias -Name cd -Value z -Description 'Zoxide enhanced cd'
    # Set-Alias -Name zi -Value zi -Description 'Interactive directory selection'
}
# ===== END ZOXIDE CONFIGURATION =====
'@

# -------------------------------------------------------
# Read profile once
# -------------------------------------------------------
$ProfileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue

# -------------------------------------------------------
# Idempotent profile update
# -------------------------------------------------------
if ($ProfileContent -match '# ===== BEGIN ZOXIDE CONFIGURATION =====') {
    Write-Host "✓ Zoxide configuration already present. Skipping re-add." -ForegroundColor Green
}
else {
    Write-Host "• Adding Zoxide configuration to PowerShell profile..." -ForegroundColor Cyan
    Add-Content -Path $PROFILE -Value "`n$ZoxideBlock"
    Write-Host "✓ Zoxide configuration added." -ForegroundColor Green
}

# -------------------------------------------------------
# Validation
# -------------------------------------------------------
if (Test-ZoxideInstalled) {
    $version = zoxide --version 2>$null
    Write-Host "✓ Zoxide detected: $version" -ForegroundColor Green
}
else {
    Write-Host "⚠ Zoxide is not installed." -ForegroundColor Yellow
    Write-Host "Install using one of the following:" -ForegroundColor Cyan
    Write-Host "  winget install ajeetdsouza.zoxide" -ForegroundColor White
    Write-Host "  choco install zoxide" -ForegroundColor White
    Write-Host "  cargo install zoxide --locked" -ForegroundColor White
}

# -------------------------------------------------------
# Completion (instructional output)
# -------------------------------------------------------
Write-Host ""
Write-Host "==================================================" -ForegroundColor DarkCyan
Write-Host " ZOXIDE SETUP COMPLETE" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor DarkCyan

Write-Host ""
Write-Host "Available commands:" -ForegroundColor Yellow
Write-Host "  z <query>   Jump to a directory" -ForegroundColor White
Write-Host "  zi          Interactive selection (fzf optional)" -ForegroundColor White
Write-Host "  za <path>   Add directory to database" -ForegroundColor White
Write-Host "  zr <path>   Remove directory" -ForegroundColor White
Write-Host "  zl <query>  List matches" -ForegroundColor White
Write-Host "  zc          Clear database" -ForegroundColor White

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  • Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
Write-Host "  • Start navigating with: z <directory>" -ForegroundColor White

Write-Host ""
Write-Host "Tip:" -ForegroundColor Magenta
Write-Host "  Install fzf for enhanced interactive search:" -ForegroundColor White
Write-Host "    winget install junegunn.fzf" -ForegroundColor White
