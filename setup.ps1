# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Function to install Nerd Fonts
function Install-NerdFonts {
    param (
        [string]$FontName = "CascadiaCode",
        [string]$FontDisplayName = "CaskaydiaCove NF",
        [string]$Version = "3.2.1"
    )

    try {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        if ($fontFamilies -notcontains "${FontDisplayName}") {
            $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip"
            $zipFilePath = "$env:TEMP\${FontName}.zip"
            $extractPath = "$env:TEMP\${FontName}"

            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri($fontZipUrl)), $zipFilePath)

            while ($webClient.IsBusy) {
                Start-Sleep -Seconds 2
            }

            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
            Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
                If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                    $destination.CopyHere($_.FullName, 0x10)
                }
            }

            Remove-Item -Path $extractPath -Recurse -Force
            Remove-Item -Path $zipFilePath -Force
            Write-Host "✅ Font ${FontDisplayName} installed successfully."
        } else {
            Write-Host "ℹ️  Font ${FontDisplayName} already installed"
        }
    }
    catch {
        Write-Error "❌ Failed to download or install ${FontDisplayName} font. Error: $_"
    }
}

# Function to install tools via Winget
function Install-WingetTools {
    param (
        [array]$ToolsList
    )
    
    Write-Host "📦 Installing tools via Winget..." -ForegroundColor Cyan
    
    foreach ($tool in $ToolsList) {
        try {
            Write-Host "Installing $($tool.Name)..." -ForegroundColor Yellow
            winget install --id $tool.Id -e --accept-source-agreements --accept-package-agreements --silent
            Write-Host "✅ $($tool.Name) installed successfully." -ForegroundColor Green
        }
        catch {
            Write-Warning "⚠️  Failed to install $($tool.Name). Error: $_"
        }
    }
}

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    break
}

# Profile creation or update
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of PowerShell & Create Profile directories if they do not exist.
        $profilePath = ""
        if ($PSVersionTable.PSEdition -eq "Core") {
            $profilePath = "$env:userprofile\Documents\Powershell"
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            $profilePath = "$env:userprofile\Documents\WindowsPowerShell"
        }

        if (!(Test-Path -Path $profilePath)) {
            New-Item -Path $profilePath -ItemType "directory"
        }

        Invoke-RestMethod https://github.com/hetfs/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "✅ The profile @ [$PROFILE] has been created."
        Write-Host "ℹ️  If you want to make any personal changes or customizations, please do so at [$profilePath\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "❌ Failed to create or update the profile. Error: $_"
    }
}
else {
    try {
        $backupPath = Join-Path (Split-Path $PROFILE) "oldprofile.ps1"
        Move-Item -Path $PROFILE -Destination $backupPath -Force
        Invoke-RestMethod https://github.com/hetfs/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "✅ PowerShell profile at [$PROFILE] has been updated."
        Write-Host "📦 Your old profile has been backed up to [$backupPath]"
        Write-Host "⚠️  NOTE: Please back up any persistent components of your old profile to [$HOME\Documents\PowerShell\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "❌ Failed to backup and update the profile. Error: $_"
    }
}

# Font Install
Install-NerdFonts -FontName "CascadiaCode" -FontDisplayName "CaskaydiaCove NF"

# Install Core Tools via Winget
$wingetTools = @(
    @{Id = "Git.Git"; Name = "Git"},
    @{Id = "ajeetdsouza.zoxide"; Name = "zoxide"},
    @{Id = "sharkdp.fd"; Name = "fd"},
    @{Id = "BurntSushi.ripgrep.MSVC"; Name = "ripgrep"},
    @{Id = "sharkdp.bat"; Name = "bat"},
    @{Id = "eza.eza"; Name = "eza"},
    @{Id = "dandavison.delta"; Name = "delta"},
    @{Id = "gerardog.gsudo"; Name = "gsudo"},
    @{Id = "GitHub.cli"; Name = "GitHub CLI"},
    @{Id = "JesseDuffield.lazygit"; Name = "lazygit"},
   @{Id = "starship.starship"; Name = "Starship"},
   @{Id = "neovim.neovim"; Name = "Neovim"},
   @{Id = "tealdeer.tealdeer"; Name = "tldr"}
)

Install-WingetTools -ToolsList $wingetTools

# Choco install
try {
    Write-Host "🍫 Installing Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "✅ Chocolatey installed successfully." -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to install Chocolatey. Error: $_"
}

# Terminal Icons Install
try {
    Write-Host "🎨 Installing Terminal Icons..." -ForegroundColor Cyan
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force
    Write-Host "✅ Terminal Icons module installed successfully." -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to install Terminal Icons module. Error: $_"
}

# Final check and message to the user
try {
    # Check font installation
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
    $fontInstalled = $fontFamilies -contains "CaskaydiaCove NF"
    
    if ((Test-Path -Path $PROFILE) -and $fontInstalled) {
        Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
        Write-Host "✨ Please restart your PowerShell session to apply changes." -ForegroundColor Yellow
        Write-Host "🚀 Next steps:" -ForegroundColor Cyan
        Write-Host "   1. Restart PowerShell/Terminal" -ForegroundColor White
        Write-Host "   2. Configure Starship: Run 'starship preset pastel-powerline > ~/.config/starship.toml'" -ForegroundColor White
        Write-Host "   3. Configure zoxide: Add 'Invoke-Expression (& { (zoxide init powershell | Out-String) })' to your profile" -ForegroundColor White
    } else {
        Write-Warning "⚠️  Setup completed with errors. Please check the error messages above."
        if (-not $fontInstalled) { Write-Warning "   - Font installation failed" }
        if (-not (Test-Path -Path $PROFILE)) { Write-Warning "   - Profile creation failed" }
    }
}
catch {
    Write-Warning "⚠️  Setup completed with errors. Please check the error messages above."
}
