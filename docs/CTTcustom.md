# 🎨 `CTTcustom.ps1` Complete Customization Guide

## 📖 Introduction

`CTTcustom.ps1` is your personal customization file for the Modular PowerShell Profile. It allows you to personalize and extend your PowerShell environment without modifying the core modules, ensuring your customizations persist through updates.

## 📍 File Location & Loading

### **Location:**
```
$HOME\Documents\PowerShell\CTTcustom.ps1
```

### **Loading Order:**
1. Main profile (`Microsoft.PowerShell_profile.ps1`) loads
2. Modular configuration (`ProfileConfig.ps1`) loads
3. All modules from `Modules\` directory load in order
4. **Finally:** `CTTcustom.ps1` loads (if it exists)

### **Verification:**
```powershell
# Check if CTTcustom.ps1 exists
Test-Path "$HOME\Documents\PowerShell\CTTcustom.ps1"

# Check loading order in debug mode
$debug_Override = $true
. $PROFILE
```

---

## 🎯 Override System

### **Variable Overrides**

Override core variables by appending `_Override` to their names:

| Variable | Description | Default Value | Example |
|----------|-------------|---------------|---------|
| `$debug_Override` | Enable debug mode | `$false` | `$debug_Override = $true` |
| `$EDITOR_Override` | Preferred text editor | Auto-detected | `$EDITOR_Override = "code"` |
| `$repo_root_Override` | Update source URL | ChrisTitusTech repo | `$repo_root_Override = "https://raw.githubusercontent.com/YOUR_USERNAME/powershell-profile"` |
| `$timeFilePath_Override` | Update tracking file | `LastExecutionTime.txt` | `$timeFilePath_Override = "$env:TEMP\PowerShellUpdates.txt"` |
| `$updateInterval_Override` | Update frequency (days) | `7` | `$updateInterval_Override = 14` |

**Example:**
```powershell
# CTTcustom.ps1
$debug_Override = $false  # Keep debug off
$EDITOR_Override = "nvim" # Use Neovim as editor
$updateInterval_Override = 30  # Check monthly
```

### **Function Overrides**

Replace core functions by appending `_Override`:

| Function | Description | When to Override |
|----------|-------------|------------------|
| `Debug-Message_Override` | Custom debug messages | Want different debug output |
| `Update-Profile_Override` | Profile update logic | Custom update source/method |
| `Update-PowerShell_Override` | PowerShell update | Different update strategy |
| `Clear-Cache_Override` | Cache clearing | Additional cache locations |
| `Get-Theme_Override` | Prompt theming | Custom Starship/Posh setup |
| `WinUtilDev_Override` | WinUtil script | Different WinUtil source |
| `Set-PredictionSource_Override` | PSReadLine prediction | Custom prediction settings |

**Example:**
```powershell
function Update-Profile_Override {
    Write-Host "🔄 Custom profile update running..." -ForegroundColor Yellow
    
    # Backup current modules
    $backupDir = "$HOME\PowerShellBackups\$(Get-Date -Format 'yyyyMMdd')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Copy-Item "$HOME\Documents\PowerShell\Modules" $backupDir -Recurse -Force
    
    # Use default update logic
    try {
        $url = "https://raw.githubusercontent.com/ChrisTitusTech/powershell-profile/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp\profile_update.ps1"
        $newhash = Get-FileHash "$env:temp\profile_update.ps1"
        
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp\profile_update.ps1" -Destination $PROFILE -Force
            Write-Host "✅ Profile updated with backup at: $backupDir" -ForegroundColor Green
        } else {
            Write-Host "📦 Profile already up to date" -ForegroundColor Blue
        }
    }
    catch {
        Write-Error "❌ Update failed: $_"
    }
    finally {
        Remove-Item "$env:temp\profile_update.ps1" -ErrorAction SilentlyContinue
    }
}
```

---

## 🛠️ Custom Functions & Aliases

### **Creating Custom Functions**

**Basic Pattern:**
```powershell
function Verb-Noun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Parameter1,
        
        [switch]$Flag
    )
    
    begin {
        Write-Verbose "Starting Verb-Noun function" -Verbose
    }
    
    process {
        try {
            # Main logic here
            Write-Host "Processing with parameter: $Parameter1" -ForegroundColor Cyan
            
            if ($Flag) {
                Write-Host "Flag is enabled" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Error "Error in Verb-Noun: $_"
        }
    }
    
    end {
        Write-Verbose "Function completed" -Verbose
    }
}
```

### **Example Functions:**

**1. Project Management:**
```powershell
function proj {
    param(
        [Parameter(Mandatory=$false)]
        [string]$ProjectName,
        
        [switch]$List,
        [switch]$Create
    )
    
    $projectsRoot = "$HOME\Projects"
    
    if (-not (Test-Path $projectsRoot)) {
        New-Item -ItemType Directory -Path $projectsRoot -Force | Out-Null
    }
    
    if ($List) {
        Write-Host "📁 Available Projects:" -ForegroundColor Cyan
        Get-ChildItem -Path $projectsRoot -Directory | ForEach-Object {
            Write-Host "  • $($_.Name)" -ForegroundColor White
        }
        return
    }
    
    if ($Create -and $ProjectName) {
        $newProjectPath = Join-Path $projectsRoot $ProjectName
        if (-not (Test-Path $newProjectPath)) {
            New-Item -ItemType Directory -Path $newProjectPath -Force | Out-Null
            Set-Location $newProjectPath
            Write-Host "✅ Created and switched to: $ProjectName" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Project already exists: $ProjectName" -ForegroundColor Yellow
        }
        return
    }
    
    if ($ProjectName) {
        $projectPath = Join-Path $projectsRoot $ProjectName
        if (Test-Path $projectPath) {
            Set-Location $projectPath
            Write-Host "📂 Switched to: $ProjectName" -ForegroundColor Green
        } else {
            Write-Host "❌ Project not found: $ProjectName" -ForegroundColor Red
            Write-Host "   Use -Create to create it" -ForegroundColor Gray
        }
    } else {
        Set-Location $projectsRoot
        Write-Host "📁 Projects root directory" -ForegroundColor Cyan
    }
}
```

**2. Enhanced Git Shortcuts:**
```powershell
function git-branch-cleanup {
    # Clean up merged branches
    git fetch --prune
    $mergedBranches = git branch --merged main | Where-Object { $_ -notmatch "^\*?\s*(main|master)$" }
    
    if ($mergedBranches) {
        Write-Host "🧹 Cleaning up merged branches:" -ForegroundColor Yellow
        $mergedBranches | ForEach-Object {
            $branch = $_.Trim()
            git branch -d $branch
            Write-Host "  Deleted: $branch" -ForegroundColor Green
        }
    } else {
        Write-Host "✅ No merged branches to clean" -ForegroundColor Green
    }
}

function git-commit-amend {
    # Amend last commit with current changes
    git add .
    git commit --amend --no-edit
    Write-Host "📝 Amended last commit" -ForegroundColor Green
}
```

**3. System Diagnostics:**
```powershell
function system-health {
    Write-Host "🏥 SYSTEM HEALTH CHECK" -ForegroundColor Cyan
    Write-Host "=" * 30 -ForegroundColor Cyan
    
    # CPU Usage
    $cpuUsage = Get-CimInstance Win32_Processor | 
        Measure-Object -Property LoadPercentage -Average | 
        Select-Object -ExpandProperty Average
    Write-Host "CPU Usage: $cpuUsage%" -ForegroundColor $(if ($cpuUsage -gt 80) { "Red" } else { "Green" })
    
    # Memory Usage
    $memory = Get-CimInstance Win32_OperatingSystem
    $usedMemory = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1MB, 2)
    $totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $memoryPercent = [math]::Round(($usedMemory / $totalMemory) * 100, 1)
    Write-Host "Memory: ${usedMemory}GB / ${totalMemory}GB (${memoryPercent}%)" -ForegroundColor $(if ($memoryPercent -gt 85) { "Red" } elseif ($memoryPercent -gt 70) { "Yellow" } else { "Green" })
    
    # Disk Space
    Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } | ForEach-Object {
        $freeGB = [math]::Round($_.Free / 1GB, 2)
        $usedGB = [math]::Round($_.Used / 1GB, 2)
        $totalGB = $freeGB + $usedGB
        $percentUsed = [math]::Round(($usedGB / $totalGB) * 100, 1)
        $color = if ($percentUsed -gt 90) { "Red" } elseif ($percentUsed -gt 80) { "Yellow" } else { "Green" }
        Write-Host "Disk $($_.Name): ${usedGB}GB / ${totalGB}GB (${percentUsed}%)" -ForegroundColor $color
    }
}
```

### **Creating Aliases**

**Syntax:**
```powershell
Set-Alias -Name <Shortcut> -Value <Command/Function>
```

**Example Aliases:**
```powershell
# Navigation
Set-Alias -Name home -Value { Set-Location $HOME }
Set-Alias -Name docs -Value { Set-Location ([Environment]::GetFolderPath("MyDocuments")) }
Set-Alias -Name dtop -Value { Set-Location ([Environment]::GetFolderPath("Desktop")) }
Set-Alias -Name dl -Value { Set-Location "$HOME\Downloads" }

# Editors
Set-Alias -Name nv -Value nvim
Set-Alias -Name vs -Value { code . }
Set-Alias -Name sublime -Value { sublime_text . }

# System
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name open -Value explorer
Set-Alias -Name myip -Value Get-PubIP

# Development
Set-Alias -Name py -Value python
Set-Alias -Name js -Value node
Set-Alias -Name ts -Value { npx ts-node }
Set-Alias -Name go-run -Value { go run . }

# Git (extended)
Set-Alias -Name gco -Value git checkout
Set-Alias -Name gbr -Value git branch
Set-Alias -Name gst -Value git status
Set-Alias -Name gdiff -Value git diff
Set-Alias -Name glog -Value { git log --oneline --graph --all }
```

---

## 🌍 Environment Variables

### **Setting Environment Variables:**

```powershell
# User-specific variables
$env:EDITOR = "nvim"
$env:PAGER = "less"
$env:BAT_THEME = "TwoDark"
$env:FZF_DEFAULT_OPTS = "--height 40% --border"

# Development
$env:GOPATH = "$HOME\go"
$env:CARGO_HOME = "$HOME\.cargo"
$env:NODE_ENV = "development"

# API Keys (consider using secure methods instead)
# $env:GITHUB_TOKEN = "your-token-here"
```

### **Adding to PATH:**
```powershell
# Add custom directories to PATH
$customPaths = @(
    "$HOME\bin",
    "$HOME\.local\bin",
    "$env:GOPATH\bin",
    "$env:CARGO_HOME\bin",
    "$HOME\AppData\Local\Programs\Python\Python39\Scripts"
)

foreach ($path in $customPaths) {
    if (Test-Path $path -PathType Container) {
        if ($env:PATH -notlike "*$path*") {
            $env:PATH = "$path;$env:PATH"
        }
    }
}
```

### **Persistent Environment Variables:**

For variables that should persist across sessions, set them in Windows:

```powershell
# Set user-level environment variable
[System.Environment]::SetEnvironmentVariable("MY_VAR", "my-value", [System.EnvironmentVariableTarget]::User)

# Set machine-level (requires admin)
# [System.Environment]::SetEnvironmentVariable("MY_VAR", "my-value", [System.EnvironmentVariableTarget]::Machine)
```

---

## 🎨 Prompt Customization

### **Custom Prompt Functions:**

**Basic Custom Prompt:**
```powershell
function prompt {
    # Save original location
    $currentPath = $executionContext.SessionState.Path.CurrentLocation
    
    # Git information
    $gitInfo = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git branch --show-current 2>$null
        if ($branch) {
            $gitInfo = " [$branch]"
        }
    }
    
    # Admin indicator
    $adminPrompt = ""
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $adminPrompt = " [ADMIN]"
    }
    
    # Time indicator
    $time = Get-Date -Format "HH:mm"
    
    # Return custom prompt
    "[$time]$adminPrompt $currentPath$gitInfo`nPS> "
}
```

**With Color and Icons:**
```powershell
function prompt {
    $currentPath = $(Get-Location).Path
    $time = Get-Date -Format "HH:mm:ss"
    
    # Git status
    $gitStatus = ""
    if (Test-Path .git -PathType Container) {
        $branch = git branch --show-current 2>$null
        if ($branch) {
            $gitStatus = " 🌿 $branch"
        }
    }
    
    # Admin indicator
    $adminIndicator = ""
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $adminIndicator = " ⚡"
    }
    
    # Build prompt with colors
    Write-Host "[$time]" -NoNewline -ForegroundColor DarkGray
    Write-Host "$adminIndicator " -NoNewline -ForegroundColor Red
    Write-Host "$currentPath" -NoNewline -ForegroundColor Cyan
    Write-Host "$gitStatus" -ForegroundColor Green
    "PS> "
}
```

### **Starship Customization:**

**Basic Starship Config:**
```powershell
function Get-Theme_Override {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        # Load Starship with custom config path
        $starshipConfig = "$HOME\.config\starship.toml"
        if (Test-Path $starshipConfig) {
            $env:STARSHIP_CONFIG = $starshipConfig
        }
        
        Invoke-Expression (&starship init powershell)
    } else {
        Write-Warning "Starship not found. Using default prompt."
    }
}
```

**Create a custom Starship config:**
```powershell
# Generate a custom config
@"
# ~/.config/starship.toml

# Don't print a new line at the start of the prompt
add_newline = false

# Custom format
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$python\
$character"""

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"
vimcmd_symbol = "[V](bold blue)"

[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold cyan"

[git_branch]
symbol = "🌿 "
style = "bold green"

[git_status]
ahead = "⇡\${count}"
behind = "⇣\${count}"

[cmd_duration]
min_time = 1000
format = "took [\$duration](\$style)"
"@ | Out-File -FilePath "$HOME\.config\starship.toml" -Encoding UTF8
```

---

## 📦 Module Management

### **Importing Additional Modules:**

```powershell
# Development modules
Import-Module Az -ErrorAction SilentlyContinue  # Azure PowerShell
Import-Module AWS.Tools.Common -ErrorAction SilentlyContinue  # AWS Tools
Import-Module PSScriptAnalyzer -ErrorAction SilentlyContinue  # Script analysis

# Productivity modules
Import-Module PSReadLine -ErrorAction SilentlyContinue
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# Custom modules from different locations
$customModulePaths = @(
    "$HOME\PowerShellModules",
    "$PSScriptRoot\MyModules",
    "\\network\share\PowerShellModules"
)

foreach ($path in $customModulePaths) {
    if (Test-Path $path) {
        $env:PSModulePath = "$path;$env:PSModulePath"
    }
}
```

### **Loading Specific Modules Conditionally:**

```powershell
# Load Azure module only when needed
function Connect-Azure {
    if (-not (Get-Module Az -ListAvailable)) {
        Write-Host "Installing Azure PowerShell module..." -ForegroundColor Yellow
        Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber
    }
    
    Import-Module Az -ErrorAction Stop
    Connect-AzAccount
    
    Write-Host "✅ Connected to Azure" -ForegroundColor Green
}

# Load modules based on environment
$computerName = $env:COMPUTERNAME
if ($computerName -match "WORK") {
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    Import-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue
} elseif ($computerName -match "DEV") {
    Import-Module DockerCompletion -ErrorAction SilentlyContinue
    Import-Module Pester -ErrorAction SilentlyContinue
}
```

---

## 👔 Work & Personal Environments

### **Environment-Specific Configurations:**

```powershell
# Detect environment
$isWorkComputer = $env:COMPUTERNAME -match "CORP"
$isPersonalComputer = $env:COMPUTERNAME -match "HOME|LAPTOP"
$isServer = $env:COMPUTERNAME -match "SRV"

# Work environment setup
if ($isWorkComputer) {
    function work-start {
        Write-Host "🚀 Starting work environment..." -ForegroundColor Cyan
        
        # Set work-specific variables
        $env:COMPANY_PROXY = "http://proxy.company.com:8080"
        $env:OFFICE_MODE = $true
        
        # Connect to work resources
        # Connect-VPN -Name "WorkVPN"
        # Connect-ExchangeOnline
        
        # Start work applications
        # Start-Process "outlook"
        # Start-Process "teams"
        
        Write-Host "✅ Work environment ready" -ForegroundColor Green
    }
    
    function work-end {
        Write-Host "🏁 Ending work session..." -ForegroundColor Cyan
        
        # Disconnect resources
        # Disconnect-VPN -Name "WorkVPN"
        # Disconnect-ExchangeOnline
        
        # Clear work-specific variables
        $env:OFFICE_MODE = $false
        
        Write-Host "👋 Work session ended" -ForegroundColor Green
    }
    
    # Auto-load work modules
    # Import-Module ActiveDirectory
    # Import-Module ExchangeOnlineManagement
}

# Personal environment setup
if ($isPersonalComputer) {
    function dev-setup {
        Write-Host "💻 Setting up development environment..." -ForegroundColor Cyan
        
        # Start development tools
        # Start-Process "vscode"
        # docker-compose up -d
        
        Write-Host "✅ Dev environment ready" -ForegroundColor Green
    }
    
    # Personal aliases
    Set-Alias -Name stream -Value { Start-Process "obs" }
    Set-Alias -Name music -Value { Start-Process "spotify" }
}
```

### **Machine-Specific Configurations:**

```powershell
# Machine-specific configuration file
$machineConfig = "$PSScriptRoot\CTTcustom-$($env:COMPUTERNAME).ps1"
if (Test-Path $machineConfig) {
    . $machineConfig
    Write-Host "📱 Loaded machine-specific config for: $($env:COMPUTERNAME)" -ForegroundColor Green
}

# Example machine-specific file (CTTcustom-DESKTOP-ABC123.ps1):
# @"
# # Desktop machine at home
# $env:SCREEN_RESOLUTION = "4K"
# 
# function big-screen {
#     Write-Host "🖥️  Optimizing for big screen..." -ForegroundColor Cyan
#     # Adjust font sizes, etc.
# }
# "@
```

---

## 🔧 Advanced Customization

### **Event-Driven Actions:**

```powershell
# Run when directory changes
function On-DirectoryChange {
    param($newPath)
    
    # Auto-activate Python virtual environment
    if (Test-Path "$newPath\.venv") {
        & "$newPath\.venv\Scripts\Activate.ps1"
        Write-Host "✅ Activated virtual environment" -ForegroundColor Green
    }
    
    # Auto-load .env files
    if (Test-Path "$newPath\.env") {
        Get-Content "$newPath\.env" | ForEach-Object {
            if ($_ -match '^([^=]+)=(.*)$') {
                $envName = $matches[1].Trim()
                $envValue = $matches[2].Trim()
                [System.Environment]::SetEnvironmentVariable($envName, $envValue, "Process")
                Write-Verbose "Set env: $envName"
            }
        }
    }
}

# Hook into directory change
$function:prompt = {
    $currentPath = Get-Location
    On-DirectoryChange -newPath $currentPath
    
    # Call original prompt
    & (Get-Command prompt -CommandType Function).ScriptBlock
}
```

### **Profile Performance Monitoring:**

```powershell
# Add to beginning of CTTcustom.ps1
$profileStartTime = Get-Date

# Add to end of CTTcustom.ps1
$profileEndTime = Get-Date
$loadTime = ($profileEndTime - $profileStartTime).TotalMilliseconds

if ($loadTime -gt 1000) {
    Write-Host "⚠️  Profile load time: ${loadTime}ms (consider optimizing)" -ForegroundColor Yellow
} else {
    Write-Verbose "Profile load time: ${loadTime}ms" -Verbose
}

# List slow-loading modules
$moduleLoadTimes = @{}
Get-Module | ForEach-Object {
    $moduleLoadTimes[$_.Name] = [math]::Round($_.OnRemove.Length, 2)
}

$slowModules = $moduleLoadTimes.GetEnumerator() | Where-Object { $_.Value -gt 100 } | Sort-Object Value -Descending
if ($slowModules) {
    Write-Host "🐌 Slow-loading modules:" -ForegroundColor Yellow
    $slowModules | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)ms" -ForegroundColor Gray
    }
}
```

### **Secure Credential Management:**

```powershell
# Store credentials securely
function Save-SecureCredential {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key,
        
        [Parameter(Mandatory=$true)]
        [string]$Value
    )
    
    $secureValue = ConvertTo-SecureString $Value -AsPlainText -Force
    $encryptedValue = ConvertFrom-SecureString $secureValue
    
    $credPath = "$HOME\.secure\credentials"
    if (-not (Test-Path $credPath)) {
        New-Item -ItemType Directory -Path $credPath -Force | Out-Null
    }
    
    $encryptedValue | Out-File "$credPath\$Key.secure"
    Write-Host "🔒 Saved credential: $Key" -ForegroundColor Green
}

function Get-SecureCredential {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key
    )
    
    $credFile = "$HOME\.secure\credentials\$Key.secure"
    if (Test-Path $credFile) {
        $encryptedValue = Get-Content $credFile
        $secureString = ConvertTo-SecureString $encryptedValue
        $credential = New-Object System.Management.Automation.PSCredential("user", $secureString)
        return $credential.GetNetworkCredential().Password
    } else {
        Write-Error "Credential not found: $Key"
    }
}

# Usage:
# Save-SecureCredential -Key "GitHubToken" -Value "ghp_abc123"
# $token = Get-SecureCredential -Key "GitHubToken"
```

---

## 🚀 Quick Start Templates

### **Minimal Customization (For Beginners):**
```powershell
# CTTcustom.ps1 - Minimal version

# 1. Set your editor
$EDITOR_Override = "code"

# 2. Add a few useful aliases
Set-Alias -Name home -Value { Set-Location $HOME }
Set-Al
