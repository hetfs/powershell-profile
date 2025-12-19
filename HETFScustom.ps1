### HETFS Custom Configuration
### This file allows you to override default profile settings
### without modifying the main profile file.

# Override repository root (if using a fork)
# $repo_root_Override = "https://raw.githubusercontent.com/YOUR_USERNAME/powershell-profile"

# Enable debug mode
# $debug_Override = $true

# Change update interval (days, -1 for always check)
# $updateInterval_Override = 14

# Custom editor preference
# $EDITOR_Override = "code"

### Custom Functions ###

# Override Starship theme
function Get-Theme_Override {
    # Custom Starship configuration
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        # Use custom Starship config
        $env:STARSHIP_CONFIG = "$HOME\.config\starship\custom.toml"
        Invoke-Expression (&starship init powershell)
    }
}

# Custom update behavior
function Update-Profile_Override {
    Write-Host "🔧 Custom profile update in progress..." -ForegroundColor Yellow
    # Add custom update logic here
}

# Custom cache clearing
function Clear-Cache_Override {
    Write-Host "🧹 Custom cache clearing..." -ForegroundColor Cyan
    # Add custom cache paths here
    Clear-RecycleBin -Force
}

### Additional Custom Functions ###

# Example: Custom git function
function gsync {
    param([string]$Branch = "main")
    
    Write-Host "🔄 Syncing git repository..." -ForegroundColor Cyan
    git fetch origin
    git checkout $Branch
    git pull origin $Branch
    
    $status = git status --porcelain
    if ($status) {
        Write-Host "⚠️  You have uncommitted changes" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Repository synced successfully" -ForegroundColor Green
    }
}

# Example: System information
function myinfo {
    Write-Host "=== System Information ===" -ForegroundColor Cyan
    Write-Host "User: $env:USERNAME" -ForegroundColor Green
    Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor Green
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Green
    Write-Host "Starship: $(if (Get-Command starship) { 'Installed' } else { 'Not installed' })" -ForegroundColor Green
    
    # Show profile location
    Write-Host "Profile: $PROFILE" -ForegroundColor Yellow
    
    # Show custom config status
    $customPath = Join-Path (Split-Path $PROFILE) "HETFScustom.ps1"
    Write-Host "Custom Config: $(if (Test-Path $customPath) { 'Loaded' } else { 'Not found' })" -ForegroundColor Yellow
}

# Example: Quick directory shortcuts
function projects { Set-Location "$HOME\Projects" }
function downloads { Set-Location "$HOME\Downloads" }
function temp { Set-Location $env:TEMP }

# Example: Enhanced git log
function glog {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

# Load additional modules
# Import-Module PSReadLine
# Import-Module Terminal-Icons

# Custom aliases
Set-Alias -Name gs -Value git status
Set-Alias -Name gd -Value git diff
Set-Alias -Name gl -Value git log --oneline

# Environment variables
$env:EDITOR = "code"
$env:GIT_EDITOR = "code --wait"

# Custom prompt elements (if not using Starship)
# function prompt {
#     $path = (Get-Location).Path.Replace($HOME, '~')
#     "$path> "
# }

# PowerShell provider shortcuts
New-PSDrive -Name H -PSProvider FileSystem -Root $HOME -Description "Home Directory"
New-PSDrive -Name D -PSProvider FileSystem -Root "D:\" -Description "Data Drive" -ErrorAction SilentlyContinue

# Custom completions
Register-ArgumentCompleter -CommandName myinfo -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    @('system', 'profile', 'all') | Where-Object { $_ -like "$wordToComplete*" }
}

# Load additional scripts
# $scriptsPath = "$HOME\PowerShell\Scripts"
# if (Test-Path $scriptsPath) {
#     Get-ChildItem "$scriptsPath\*.ps1" | ForEach-Object { . $_ }
# }

Write-Host "✅ HETFS Custom Configuration loaded" -ForegroundColor Green
