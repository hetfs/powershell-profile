# PowerShell Profile Setup Script
# Repository: https://github.com/hetfs/powershell-profile

################################################################################################
# SECTION 1: ADMINISTRATOR CHECK
################################################################################################

# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Please run this script as an Administrator!" -ForegroundColor Red
    Write-Host "   Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    break
}

################################################################################################
# SECTION 2: INTERNET CONNECTIVITY CHECK
################################################################################################

function Test-InternetConnection {
    try {
        Write-Host "🌐 Testing internet connection..." -ForegroundColor Cyan
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null
        Write-Host "✅ Internet connection is available" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Internet connection is required but not available." -ForegroundColor Red
        Write-Host "   Please check your connection and try again." -ForegroundColor Yellow
        return $false
    }
}

################################################################################################
# SECTION 3: NERD FONTS INSTALLATION
################################################################################################

function Install-NerdFonts {
    param (
        [string]$FontName = "CascadiaCode",
        [string]$FontDisplayName = "CaskaydiaCove NF",
        [string]$Version = "3.2.1"
    )

    try {
        Write-Host "📝 Checking for Nerd Font installation..." -ForegroundColor Cyan

        # Check if font is already installed
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name

        if ($fontFamilies -notcontains "${FontDisplayName}") {
            Write-Host "📥 Downloading ${FontDisplayName} font..." -ForegroundColor Yellow

            $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip"
            $zipFilePath = "$env:TEMP\${FontName}.zip"
            $extractPath = "$env:TEMP\${FontName}"

            # Download font
            Invoke-WebRequest -Uri $fontZipUrl -OutFile $zipFilePath

            # Extract font
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force

            # Install font files
            $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
            $fontFiles = Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf"

            foreach ($fontFile in $fontFiles) {
                If (-not(Test-Path "C:\Windows\Fonts\$($fontFile.Name)")) {
                    $destination.CopyHere($fontFile.FullName, 0x10)
                }
            }

            # Cleanup
            Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue

            Write-Host "✅ ${FontDisplayName} font installed successfully" -ForegroundColor Green
        } else {
            Write-Host "✅ ${FontDisplayName} font is already installed" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "❌ Failed to download or install ${FontDisplayName} font." -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Yellow
    }
}

################################################################################################
# SECTION 4: PROFILE SETUP
################################################################################################

function Setup-PowerShellProfile {
    Write-Host "`n🔧 Setting up PowerShell profile..." -ForegroundColor Cyan

    # Determine PowerShell version and profile path
    $profilePath = ""
    if ($PSVersionTable.PSEdition -eq "Core") {
        $profilePath = "$env:userprofile\Documents\PowerShell"
    }
    elseif ($PSVersionTable.PSEdition -eq "Desktop") {
        $profilePath = "$env:userprofile\Documents\WindowsPowerShell"
    }

    # Create profile directory if it doesn't exist
    if (!(Test-Path -Path $profilePath)) {
        Write-Host "📁 Creating PowerShell profile directory..." -ForegroundColor Yellow
        New-Item -Path $profilePath -ItemType "directory" -Force | Out-Null
    }

    # Check if profile already exists
    if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
        try {
            Write-Host "📄 Creating new PowerShell profile..." -ForegroundColor Yellow
            $profileUrl = "https://raw.githubusercontent.com/hetfs/powershell-profile/main/Microsoft.PowerShell_profile.ps1"
            Invoke-RestMethod $profileUrl -OutFile $PROFILE
            Write-Host "✅ PowerShell profile created at: [$PROFILE]" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to create the profile." -ForegroundColor Red
            Write-Host "   Error: $_" -ForegroundColor Yellow
            return $false
        }
    }
    else {
        try {
            # Backup existing profile
            Write-Host "📦 Backing up existing profile..." -ForegroundColor Yellow
            $backupPath = Join-Path (Split-Path $PROFILE) "oldprofile.ps1"
            Copy-Item -Path $PROFILE -Destination $backupPath -Force

            # Download new profile
            Write-Host "🔄 Updating PowerShell profile..." -ForegroundColor Yellow
            $profileUrl = "https://raw.githubusercontent.com/hetfs/powershell-profile/main/Microsoft.PowerShell_profile.ps1"
            Invoke-RestMethod $profileUrl -OutFile $PROFILE

            Write-Host "✅ PowerShell profile updated at: [$PROFILE]" -ForegroundColor Green
            Write-Host "📦 Your old profile has been backed up to: [$backupPath]" -ForegroundColor Cyan
        }
        catch {
            Write-Host "❌ Failed to backup and update the profile." -ForegroundColor Red
            Write-Host "   Error: $_" -ForegroundColor Yellow
            return $false
        }
    }

    Write-Host "`n⚠️ IMPORTANT NOTE:" -ForegroundColor Yellow
    Write-Host "   If you want to make any personal changes or customizations," -ForegroundColor Cyan
    Write-Host "   please create a custom file at: [$profilePath\HETFScustom.ps1]" -ForegroundColor Cyan
    Write-Host "   The main profile has an automatic updater that will overwrite changes." -ForegroundColor Cyan

    return $true
}

################################################################################################
# SECTION 5: PACKAGE INSTALLATIONS
################################################################################################

function Install-Packages {
    Write-Host "`n📦 Installing required packages..." -ForegroundColor Cyan

    # 5.1 Install Starship Prompt
    Write-Host "🚀 Installing Starship prompt..." -ForegroundColor Yellow
    try {
        winget install -e --accept-source-agreements --accept-package-agreements starship
        Write-Host "✅ Starship prompt installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install Starship prompt." -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Yellow
    }

    # 5.2 Install Chocolatey
    Write-Host "🍫 Installing Chocolatey package manager..." -ForegroundColor Yellow
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "✅ Chocolatey installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install Chocolatey." -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Yellow
    }

    # 5.3 Install Terminal Icons module
    Write-Host "🎨 Installing Terminal Icons module..." -ForegroundColor Yellow
    try {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
        Write-Host "✅ Terminal Icons module installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install Terminal Icons module." -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Yellow
    }

    # 5.4 Install zoxide
    Write-Host "📁 Installing zoxide (smarter cd command)..." -ForegroundColor Yellow
    try {
        winget install -e --id ajeetdsouza.zoxide
        Write-Host "✅ zoxide installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install zoxide." -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Yellow
    }
}

################################################################################################
# SECTION 6: FINAL VERIFICATION
################################################################################################

function Verify-Installation {
    Write-Host "`n🔍 Verifying installation..." -ForegroundColor Cyan

    $verificationResults = @()

    # Check if profile was created/updated
    if (Test-Path -Path $PROFILE -PathType Leaf) {
        $verificationResults += @{
            Component = "PowerShell Profile"
            Status = "✅ Installed"
            Color = "Green"
        }
    } else {
        $verificationResults += @{
            Component = "PowerShell Profile"
            Status = "❌ Missing"
            Color = "Red"
        }
    }

    # Check if Starship is installed
    try {
        $starshipCheck = winget list --name "starship" -e 2>$null
        if ($starshipCheck -like "*starship*") {
            $verificationResults += @{
                Component = "Starship Prompt"
                Status = "✅ Installed"
                Color = "Green"
            }
        } else {
            $verificationResults += @{
                Component = "Starship Prompt"
                Status = "❌ Missing"
                Color = "Red"
            }
        }
    } catch {
        $verificationResults += @{
            Component = "Starship Prompt"
            Status = "⚠️ Check failed"
            Color = "Yellow"
        }
    }

    # Check if font is installed
    try {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        if ($fontFamilies -contains "CaskaydiaCove NF") {
            $verificationResults += @{
                Component = "Nerd Font"
                Status = "✅ Installed"
                Color = "Green"
            }
        } else {
            $verificationResults += @{
                Component = "Nerd Font"
                Status = "⚠️ Not found (may require restart)"
                Color = "Yellow"
            }
        }
    } catch {
        $verificationResults += @{
            Component = "Nerd Font"
            Status = "⚠️ Check failed"
            Color = "Yellow"
        }
    }

    # Check if Terminal Icons module is installed
    try {
        if (Get-Module -ListAvailable -Name Terminal-Icons) {
            $verificationResults += @{
                Component = "Terminal Icons"
                Status = "✅ Installed"
                Color = "Green"
            }
        } else {
            $verificationResults += @{
                Component = "Terminal Icons"
                Status = "❌ Missing"
                Color = "Red"
            }
        }
    } catch {
        $verificationResults += @{
            Component = "Terminal Icons"
            Status = "⚠️ Check failed"
            Color = "Yellow"
        }
    }

    # Display verification results
    Write-Host "`n📊 INSTALLATION SUMMARY:" -ForegroundColor Cyan
    Write-Host "=" * 50

    foreach ($result in $verificationResults) {
        Write-Host "$($result.Component): " -NoNewline
        Write-Host "$($result.Status)" -ForegroundColor $result.Color
    }

    Write-Host "=" * 50

    # Count successes
    $successCount = ($verificationResults | Where-Object { $_.Status -like "✅*" }).Count
    $totalCount = $verificationResults.Count

    if ($successCount -eq $totalCount) {
        Write-Host "`n🎉 All components installed successfully!" -ForegroundColor Green
        return $true
    } elseif ($successCount -gt 0) {
        Write-Host "`n⚠️ $successCount out of $totalCount components installed successfully." -ForegroundColor Yellow
        Write-Host "   Some components may need manual installation." -ForegroundColor Yellow
        return $false
    } else {
        Write-Host "`n❌ Installation failed. Please check the errors above." -ForegroundColor Red
        return $false
    }
}

################################################################################################
# SECTION 7: MAIN EXECUTION
################################################################################################

# Display header
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "    PowerShell Profile Setup Script     " -ForegroundColor Cyan
Write-Host "    Repository: hetfs/powershell-profile" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check internet connection
if (-not (Test-InternetConnection)) {
    Write-Host "`n💡 Tips:" -ForegroundColor Yellow
    Write-Host "   - Check your network connection" -ForegroundColor Cyan
    Write-Host "   - Disable VPN if using one" -ForegroundColor Cyan
    Write-Host "   - Try running the script again" -ForegroundColor Cyan
    break
}

# Step 2: Install Nerd Fonts
Install-NerdFonts -FontName "CascadiaCode" -FontDisplayName "CaskaydiaCove NF"

# Step 3: Setup PowerShell profile
$profileSetup = Setup-PowerShellProfile
if (-not $profileSetup) {
    Write-Host "`n❌ Profile setup failed. Exiting." -ForegroundColor Red
    break
}

# Step 4: Install packages
Install-Packages

# Step 5: Verify installation
$verification = Verify-Installation

# Step 6: Final instructions
Write-Host "`n📋 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "=" * 40

if ($verification) {
    Write-Host "1️⃣ RESTART PowerShell or Terminal to apply changes" -ForegroundColor Green
} else {
    Write-Host "1️⃣ Check the installation summary above for missing components" -ForegroundColor Yellow
}

Write-Host "2️⃣ Customize your profile by creating:" -ForegroundColor Cyan
Write-Host "   $env:USERPROFILE\Documents\PowerShell\HETFScustom.ps1" -ForegroundColor Yellow

Write-Host "3️⃣ For additional customization:" -ForegroundColor Cyan
Write-Host "   - Run 'starship preset' for preset configurations" -ForegroundColor Yellow
Write-Host "   - Visit https://starship.rs for Starship documentation" -ForegroundColor Yellow
Write-Host "   - Visit https://github.com/hetfs/powershell-profile for updates" -ForegroundColor Yellow

Write-Host "=" * 40
Write-Host "`n🎯 Setup completed!" -ForegroundColor Cyan
