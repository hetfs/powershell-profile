# PowerShell Environment Setup for HETFS
# Repository: https://github.com/hetfs/powershell-profile

# Admin check
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "⚠️ Please run this script as Administrator!"
    exit 1
}

Write-Host "🚀 HETFS PowerShell Environment Setup" -ForegroundColor Cyan
Write-Host "Repository: https://github.com/hetfs/powershell-profile" -ForegroundColor Blue
Write-Host ""

# Configuration
$RepoBase = "https://github.com/hetfs/powershell-profile"
$ProfileUrl = "$RepoBase/raw/main/Microsoft.PowerShell_profile.ps1"
$CustomConfigUrl = "$RepoBase/raw/main/HETFScustom.ps1"

# Function to check internet
function Test-ConnectionToGitHub {
    try {
        Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 3
        return $true
    } catch {
        return $false
    }
}

# Main setup
Write-Host "🔍 Checking internet connection..." -ForegroundColor Yellow
if (-not (Test-ConnectionToGitHub)) {
    Write-Error "❌ No internet connection. Setup cannot continue."
    exit 1
}

# Step 1: Install PowerShell profile
Write-Host "`n📁 Step 1: Installing PowerShell profile..." -ForegroundColor Cyan

$profileDir = if ($PSVersionTable.PSEdition -eq "Core") {
    "$env:USERPROFILE\Documents\PowerShell"
} else {
    "$env:USERPROFILE\Documents\WindowsPowerShell"
}

# Create directory if needed
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Download main profile
try {
    Write-Host "📥 Downloading main profile..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $ProfileUrl -OutFile $PROFILE -UseBasicParsing
    Write-Host "✅ Main profile installed" -ForegroundColor Green
} catch {
    Write-Error "❌ Failed to download profile: $_"
    exit 1
}

# Download custom config template
try {
    Write-Host "📥 Downloading custom config template..." -ForegroundColor Yellow
    $customPath = Join-Path $profileDir "HETFScustom.ps1"
    if (-not (Test-Path $customPath)) {
        Invoke-WebRequest -Uri $CustomConfigUrl -OutFile $customPath -UseBasicParsing
        Write-Host "✅ Custom config template installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Custom config already exists, skipping..." -ForegroundColor Yellow
    }
} catch {
    Write-Warning "Custom config template not available, continuing..."
}

# Step 2: Install Starship
Write-Host "`n🚀 Step 2: Installing Starship prompt..." -ForegroundColor Cyan

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Write-Host "✅ Starship already installed" -ForegroundColor Green
} else {
    try {
        Write-Host "📦 Installing via winget..." -ForegroundColor Yellow
        winget install Starship.Starship -e --accept-source-agreements --accept-package-agreements
        Write-Host "✅ Starship installed" -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to install Starship. Please install manually from https://starship.rs/"
    }
}

# Step 3: Install Terminal Icons
Write-Host "`n🎨 Step 3: Installing Terminal Icons..." -ForegroundColor Cyan

if (Get-Module -ListAvailable Terminal-Icons) {
    Write-Host "✅ Terminal Icons already installed" -ForegroundColor Green
} else {
    try {
        Install-Module Terminal-Icons -Repository PSGallery -Force -AllowClobber -Scope CurrentUser
        Write-Host "✅ Terminal Icons installed" -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to install Terminal Icons"
    }
}

# Step 4: Install zoxide
Write-Host "`n📁 Step 4: Installing zoxide..." -ForegroundColor Cyan

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Write-Host "✅ zoxide already installed" -ForegroundColor Green
} else {
    try {
        winget install ajeetdsouza.zoxide -e --accept-source-agreements --accept-package-agreements
        Write-Host "✅ zoxide installed" -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to install zoxide"
    }
}

# Step 5: Create basic Starship config
Write-Host "`n⚙️  Step 5: Configuring Starship..." -ForegroundColor Cyan

$starshipConfigDir = "$env:USERPROFILE\.config"
if (-not (Test-Path $starshipConfigDir)) {
    New-Item -ItemType Directory -Path $starshipConfigDir -Force | Out-Null
}

$starshipConfigPath = "$starshipConfigDir\starship.toml"
if (-not (Test-Path $starshipConfigPath)) {
    $basicConfig = @"
# Starship configuration for HETFS
# Docs: https://starship.rs/config/

format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"
vimcmd_symbol = "[❮](bold green)"

[directory]
truncation_length = 3
truncate_to_repo = false
style = "blue bold"

[git_branch]
symbol = " "
style = "bold green"

[cmd_duration]
format = "[$duration]($style)"
style = "yellow"

[time]
disabled = false
format = '[🕙 $time]($style)'
time_format = "%R"
style = "bold dimmed white"
"@
    
    Set-Content -Path $starshipConfigPath -Value $basicConfig
    Write-Host "✅ Basic Starship config created" -ForegroundColor Green
} else {
    Write-Host "✅ Starship config already exists" -ForegroundColor Green
}

# Completion
Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "✨ SETUP COMPLETE ✨" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Green

Write-Host "`n📋 Components installed:" -ForegroundColor Yellow
Write-Host "  ✓ Modular PowerShell profile" -ForegroundColor Green
Write-Host "  ✓ Starship prompt" -ForegroundColor Green
Write-Host "  ✓ Terminal Icons" -ForegroundColor Green
Write-Host "  ✓ zoxide (smart cd)" -ForegroundColor Green
Write-Host "  ✓ Custom config template (HETFScustom.ps1)" -ForegroundColor Green
if ($installChoco -match '^[Yy]') {
    Write-Host "  ✓ Chocolatey package manager" -ForegroundColor Green
}

Write-Host "`n🚀 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart your PowerShell/terminal" -ForegroundColor White
Write-Host "  2. Run 'Show-Help' to see available commands" -ForegroundColor White
Write-Host "  3. Customize your setup:" -ForegroundColor White
Write-Host "     - Edit profile: ep (or Edit-Profile)" -ForegroundColor White
Write-Host "     - Custom config: $profileDir\HETFScustom.ps1" -ForegroundColor White
Write-Host "     - Starship config: $starshipConfigPath" -ForegroundColor White
Write-Host "  4. Check for updates: Update-Profile" -ForegroundColor White

Write-Host "`n🔗 Links:" -ForegroundColor Cyan
Write-Host "  Repository: $RepoBase" -ForegroundColor Blue
Write-Host "  Starship: https://starship.rs/" -ForegroundColor Blue
Write-Host "  PowerShell Docs: https://docs.microsoft.com/powershell/" -ForegroundColor Blue

Write-Host "`n🎉 Setup complete! Restart your terminal to enjoy the new experience." -ForegroundColor Green
