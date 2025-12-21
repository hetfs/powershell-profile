# =======================================================
# PowerShell Zoxide Configuration
# Author: Fredaw Lomdo
# Repository: https://github.com/hetfs/powershell-profile
# =======================================================

$ErrorActionPreference = 'Stop'

function Write-InstallInstructions {
    Write-Host "Zoxide not found. Please install via one of these methods:" -ForegroundColor Yellow
    Write-Host "`n1. Winget (Recommended):" -ForegroundColor Cyan
    Write-Host "   winget install ajeetdsouza.zoxide" -ForegroundColor Green

    Write-Host "`n2. Chocolatey:" -ForegroundColor Cyan
    Write-Host "   choco install zoxide" -ForegroundColor Green

    Write-Host "`n3. Manual installation:" -ForegroundColor Cyan
    Write-Host "   Download from: https://github.com/ajeetdsouza/zoxide/releases" -ForegroundColor Green
    Write-Host "   Add to PATH after extracting" -ForegroundColor Green

    Write-Host "`n4. Using cargo (if Rust is installed):" -ForegroundColor Cyan
    Write-Host "   cargo install zoxide --locked" -ForegroundColor Green

    Write-Host "`nAfter installation, restart PowerShell and run this script again." -ForegroundColor Yellow
}

function Test-ZoxideInstalled {
    $zoxideCmd = Get-Command zoxide -ErrorAction SilentlyContinue
    if ($zoxideCmd) {
        Write-Host "✓ Zoxide found at: $($zoxideCmd.Source)" -ForegroundColor Green
        return $true
    }
    return $false
}

function Get-ZoxideInitScript {
    @'
# ==== Zoxide configuration smart directory jumping ====

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& {
        $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
        (zoxide init --hook $hook powershell) -join "`n"
    })

    # Optional: Set custom environment variables
    # $env:_ZO_EXCLUDE_DIRS = 'C:\Users\*\.git,C:\Windows\System32'
    # $env:_ZO_MAXAGE = 10000
    # $env:_ZO_RESOLVE_SYMLINKS = 1

    # Aliases (optional - uncomment if desired)
    # Set-Alias -Name cd -Value __zoxide_z -Description 'Zoxide enhanced cd'
    # Set-Alias -Name zi -Value __zoxide_zi -Description 'Interactive directory selection'
}
'@
}

function Add-ZoxideAliases {
    @'
# Zoxide aliases for common operations
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    # z - jump to a directory
    function z { __zoxide_z @args }

    # zi - interactive selection with fzf (if installed)
    function zi {
        if (Get-Command fzf -ErrorAction SilentlyContinue) {
            __zoxide_zi
        } else {
            Write-Host "fzf not installed. Install with: winget install fzf" -ForegroundColor Yellow
            __zoxide_zi
        }
    }

    # za - add directory to database
    function za { __zoxide_za @args }

    # zq - query database without cd
    function zq { __zoxide_zq @args }

    # zr - remove directory from database
    function zr { __zoxide_zr @args }

    # zl - list matching directories (non-interactive)
    function zl { __zoxide_zl @args }

    # zc - clear entire database
    function zc { __zoxide_zc }
}
    # ======= End zoxide ==========
'@
}

function Write-SuccessMessage {
    Write-Host "`n" + "="*50 -ForegroundColor Cyan
    Write-Host "ZOXIDE SETUP COMPLETE!" -ForegroundColor Green
    Write-Host "="*50 -ForegroundColor Cyan
    Write-Host "`nZoxide has been configured with the following features:" -ForegroundColor White

    Write-Host "`n📁 Core Commands:" -ForegroundColor Yellow
    Write-Host "  z <query>       " -NoNewline -ForegroundColor Cyan
    Write-Host "Jump to frequently accessed directory" -ForegroundColor White

    Write-Host "  zi              " -NoNewline -ForegroundColor Cyan
    Write-Host "Interactive directory selection" -ForegroundColor White

    Write-Host "  za <path>       " -NoNewline -ForegroundColor Cyan
    Write-Host "Add directory to database" -ForegroundColor White

    Write-Host "  zr <path>       " -NoNewline -ForegroundColor Cyan
    Write-Host "Remove directory from database" -ForegroundColor White

    Write-Host "`n📊 Database Management:" -ForegroundColor Yellow
    Write-Host "  zq <query>      " -NoNewline -ForegroundColor Cyan
    Write-Host "Query database without changing directory" -ForegroundColor White

    Write-Host "  zl <query>      " -NoNewline -ForegroundColor Cyan
    Write-Host "List matching directories" -ForegroundColor White

    Write-Host "  zc              " -NoNewline -ForegroundColor Cyan
    Write-Host "Clear entire database" -ForegroundColor White

    Write-Host "`n🔍 Usage Examples:" -ForegroundColor Yellow
    Write-Host "  z proj          " -NoNewline -ForegroundColor Cyan
    Write-Host "Jump to project directory" -ForegroundColor White

    Write-Host "  z doc down      " -NoNewline -ForegroundColor Cyan
    Write-Host "Jump to Documents/Downloads" -ForegroundColor White

    Write-Host "  za .            " -NoNewline -ForegroundColor Cyan
    Write-Host "Add current directory" -ForegroundColor White

    Write-Host "  zi              " -NoNewline -ForegroundColor Cyan
    Write-Host "Fuzzy find directory (if fzf installed)" -ForegroundColor White

    Write-Host "`n📝 Tips:" -ForegroundColor Yellow
    Write-Host "  • Zoxide learns as you use it" -ForegroundColor White
    Write-Host "  • Directories used more frequently get higher priority" -ForegroundColor White
    Write-Host "  • Works with partial directory names" -ForegroundColor White
    Write-Host "  • Use quotes for directories with spaces" -ForegroundColor White

    Write-Host "`n🔄 Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor Green
    Write-Host "  2. Start using zoxide with 'z <directory>'" -ForegroundColor Green
    Write-Host "  3. Add directories with 'za' to build your database" -ForegroundColor Green

    Write-Host "`n" + "="*50 -ForegroundColor Cyan
}

# Main execution
Write-Host "Setting up Zoxide for PowerShell..." -ForegroundColor Cyan

# Check if zoxide is installed
if (-not (Test-ZoxideInstalled)) {
    Write-InstallInstructions
    return
}

# Get initialization script
$zoxideInitScript = Get-ZoxideInitScript
$zoxideAliases = Add-ZoxideAliases

# Ensure profile file exists
if (-not (Test-Path $PROFILE)) {
    Write-Host "Creating PowerShell profile..." -ForegroundColor Yellow
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Read existing profile content
$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue

# Check if zoxide is already configured
$zoxidePatterns = @('zoxide init', '__zoxide_', 'Invoke-Expression.*zoxide')
$alreadyConfigured = $false

foreach ($pattern in $zoxidePatterns) {
    if ($profileContent -and $profileContent -match $pattern) {
        $alreadyConfigured = $true
        break
    }
}

if ($alreadyConfigured) {
    Write-Host "Zoxide is already configured in your PowerShell profile." -ForegroundColor Yellow

    # Offer to update configuration
    $choice = Read-Host "Do you want to update the configuration? (y/N)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        # Remove existing zoxide configuration
        $lines = Get-Content -Path $PROFILE
        $newLines = @()
        $inZoxideBlock = $false

        foreach ($line in $lines) {
            if ($line -match '^\s*#.*Zoxide' -or $line -match 'zoxide init') {
                $inZoxideBlock = $true
                continue
            }

            if ($inZoxideBlock -and ($line -match '^\s*$' -or $line -notmatch '^\s*#')) {
                $inZoxideBlock = $false
            }

            if (-not $inZoxideBlock) {
                $newLines += $line
            }
        }

        # Save cleaned profile
        $newLines | Set-Content -Path $PROFILE -Encoding UTF8

        # Add new configuration
        Add-Content -Path $PROFILE -Value "`n$zoxideInitScript"
        Add-Content -Path $PROFILE -Value "`n$zoxideAliases"

        Write-Host "✓ Zoxide configuration updated." -ForegroundColor Green
    } else {
        Write-Host "Keeping existing configuration." -ForegroundColor Yellow
        return
    }
} else {
    # Add zoxide configuration
    Add-Content -Path $PROFILE -Value "`n$zoxideInitScript"
    Add-Content -Path $PROFILE -Value "`n$zoxideAliases"

    Write-Host "✓ Zoxide configuration added to PowerShell profile." -ForegroundColor Green
}

# Test zoxide initialization
Write-Host "`nTesting zoxide initialization..." -ForegroundColor Cyan
try {
    $testResult = zoxide --version
    Write-Host "✓ Zoxide test successful: $testResult" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not verify zoxide version. Installation may need a restart." -ForegroundColor Yellow
}

# Show success message
Write-SuccessMessage

# Optional: Show how to customize zoxide
Write-Host "`n🎨 Customization Options:" -ForegroundColor Magenta
Write-Host "To customize zoxide behavior, set these environment variables:" -ForegroundColor White
Write-Host '  $env:_ZO_EXCLUDE_DIRS = "C:\Windows\System32,C:\Users\*\.git"' -ForegroundColor Cyan
Write-Host "  # Exclude directories from database" -ForegroundColor Gray
Write-Host '  $env:_ZO_MAXAGE = 5000' -ForegroundColor Cyan
Write-Host "  # Maximum database age (milliseconds) before cleanup" -ForegroundColor Gray
Write-Host '  $env:_ZO_RESOLVE_SYMLINKS = 1' -ForegroundColor Cyan
Write-Host "  # Resolve symlinks to their real paths" -ForegroundColor Gray
Write-Host '  $env:_ZO_ECHO = 1' -ForegroundColor Cyan
Write-Host "  # Echo matched directory before cd" -ForegroundColor Gray
Write-Host '  $env:_ZO_FZF_OPTS = "--height 40% --reverse"' -ForegroundColor Cyan
Write-Host "  # Custom fzf options for interactive mode" -ForegroundColor Gray

Write-Host "`n💡 Pro Tip:" -ForegroundColor Magenta
Write-Host "Install 'fzf' for enhanced interactive directory selection:" -ForegroundColor White
Write-Host "  winget install fzf" -ForegroundColor Green
