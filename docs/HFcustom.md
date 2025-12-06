# 🎨 `HFCustom.ps1` COMPLETE CUSTOMIZATION GUIDE

## 📖 INTRODUCTION

`HFCustom.ps1` is your personal customization file for the modular PowerShell profile. It allows you to personalize and extend your PowerShell environment without modifying the core modules, ensuring your customizations persist through updates.

## 📍 FILE LOCATION & LOADING

### **LOCATION:**
```
$HOME\Documents\PowerShell\HFCustom.ps1
```

### **LOADING ORDER:**
1. Main profile (`Microsoft.PowerShell_profile.ps1`) loads
2. Modular configuration (`ProfileConfig.ps1`) loads
3. All modules from `Modules\` directory load in order
4. **FINALLY:** `HFCustom.ps1` loads (if it exists)

### **VERIFICATION:**
```powershell
# Check if HFCustom.ps1 exists
Test-Path "$HOME\Documents\PowerShell\HFCustom.ps1"

# Check loading order in debug mode
$debug_Override = $true
. $PROFILE
```

---

## 🎯 OVERRIDE SYSTEM

### **VARIABLE OVERRIDES**

Override core variables by appending `_Override` to their names:

| Variable | Description | Default Value | Example |
|----------|-------------|---------------|---------|
| `$debug_Override` | Enable debug mode | `$false` | `$debug_Override = $true` |
| `$EDITOR_Override` | Preferred text editor | Auto-detected | `$EDITOR_Override = "code"` |
| `$repo_root_Override` | Update source URL | Your repo | `$repo_root_Override = "https://raw.githubusercontent.com/hetfs/powershell-profile"` |
| `$timeFilePath_Override` | Update tracking file | `LastExecutionTime.txt` | `$timeFilePath_Override = "$env:TEMP\PowerShellUpdates.txt"` |
| `$updateInterval_Override` | Update frequency (days) | `7` | `$updateInterval_Override = 14` |

**EXAMPLE:**
```powershell
# HFCustom.ps1
$debug_Override = $false  # Keep debug off
$EDITOR_Override = "nvim" # Use Neovim as editor
$updateInterval_Override = 30  # Check monthly
$repo_root_Override = "https://raw.githubusercontent.com/hetfs/powershell-profile"
```

### **FUNCTION OVERRIDES**

Replace core functions by appending `_Override`:

| Function | Description | When to Override |
|----------|-------------|------------------|
| `Debug-Message_Override` | Custom debug messages | Want different debug output |
| `Update-Profile_Override` | Profile update logic | Custom update source/method |
| `Update-PowerShell_Override` | PowerShell update | Different update strategy |
| `Clear-Cache_Override` | Cache clearing | Additional cache locations |
| `Get-Theme_Override` | Prompt theming | Custom Starship/posh setup |
| `WinUtilDev_Override` | WinUtil script | Different WinUtil source |
| `Set-PredictionSource_Override` | PSReadLine prediction | Custom prediction settings |

**EXAMPLE:**
```powershell
function Update-Profile_Override {
    Write-Host "🔄 Custom profile update running..." -ForegroundColor Yellow
    
    # Backup current modules
    $backupDir = "$HOME\PowerShellBackups\$(Get-Date -Format 'yyyyMMdd')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Copy-Item "$HOME\Documents\PowerShell\Modules" $backupDir -Recurse -Force
    
    # Use YOUR repository for updates
    try {
        $url = "https://raw.githubusercontent.com/hetfs/powershell-profile/main/Microsoft.PowerShell_profile.ps1"
        $oldHash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:TEMP\profile_update.ps1"
        $newHash = Get-FileHash "$env:TEMP\profile_update.ps1"
        
        if ($newHash.Hash -ne $oldHash.Hash) {
            Copy-Item -Path "$env:TEMP\profile_update.ps1" -Destination $PROFILE -Force
            Write-Host "✅ Profile updated with backup at: $backupDir" -ForegroundColor Green
        } else {
            Write-Host "📦 Profile already up to date" -ForegroundColor Blue
        }
    }
    catch {
        Write-Error "❌ Update failed: $_"
    }
    finally {
        Remove-Item "$env:TEMP\profile_update.ps1" -ErrorAction SilentlyContinue
    }
}
```

---

## 🛠️ CUSTOM FUNCTIONS & ALIASES

### **CREATING CUSTOM FUNCTIONS**

**BASIC PATTERN:**
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

### **EXAMPLE FUNCTIONS:**

**1. PROJECT MANAGEMENT:**
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
        Write-Host "📁 Available projects:" -ForegroundColor Cyan
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

**2. ENHANCED GIT SHORTCUTS:**
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

**3. SYSTEM DIAGNOSTICS:**
```powershell
function system-health {
    Write-Host "🏥 System Health Check" -ForegroundColor Cyan
    Write-Host "=" * 30 -ForegroundColor Cyan
    
    # CPU usage
    $cpuUsage = Get-CimInstance Win32_Processor | 
        Measure-Object -Property LoadPercentage -Average | 
        Select-Object -ExpandProperty Average
    Write-Host "CPU Usage: $cpuUsage%" -ForegroundColor $(if ($cpuUsage -gt 80) { "Red" } else { "Green" })
    
    # Memory usage
    $memory = Get-CimInstance Win32_OperatingSystem
    $usedMemory = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1MB, 2)
    $totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $memoryPercent = [math]::Round(($usedMemory / $totalMemory) * 100, 1)
    Write-Host "Memory: ${usedMemory}GB / ${totalMemory}GB (${memoryPercent}%)" -ForegroundColor $(if ($memoryPercent -gt 85) { "Red" } elseif ($memoryPercent -gt 70) { "Yellow" } else { "Green" })
    
    # Disk space
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

### **CREATING ALIASES**

**SYNTAX:**
```powershell
Set-Alias -Name <shortcut> -Value <command/function>
```

**EXAMPLE ALIASES:**
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

## 🌍 ENVIRONMENT VARIABLES

### **SETTING ENVIRONMENT VARIABLES:**

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

# API keys (consider using secure methods instead)
# $env:GITHUB_TOKEN = "your-token-here"
```

### **ADDING TO PATH:**
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

### **PERSISTENT ENVIRONMENT VARIABLES:**

For variables that should persist across sessions, set them in Windows:

```powershell
# Set user-level environment variable
[System.Environment]::SetEnvironmentVariable("MY_VAR", "my-value", [System.EnvironmentVariableTarget]::User)

# Set machine-level (requires admin)
# [System.Environment]::SetEnvironmentVariable("MY_VAR", "my-value", [System.EnvironmentVariableTarget]::Machine)
```

---

## 🎨 PROMPT CUSTOMIZATION

### **CUSTOM PROMPT FUNCTIONS:**

**BASIC CUSTOM PROMPT:**
```powershell
function prompt {
    # Save original location
    $currentPath = $ExecutionContext.SessionState.Path.CurrentLocation
    
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

**WITH COLOR AND ICONS:**
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

### **STARSHIP CUSTOMIZATION:**

**BASIC STARSHIP CONFIG:**
```powershell
function Get-Theme_Override {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        # Load starship with custom config path
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

**CREATE A CUSTOM STARSHIP CONFIG:**
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
vimcmd_symbol = "[v](bold blue)"

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

## 📦 MODULE MANAGEMENT

### **IMPORTING ADDITIONAL MODULES:**

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

### **LOADING SPECIFIC MODULES CONDITIONALLY:**

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
if ($computerName -match "work") {
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    Import-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue
} elseif ($computerName -match "dev") {
    Import-Module DockerCompletion -ErrorAction SilentlyContinue
    Import-Module Pester -ErrorAction SilentlyContinue
}
```

---

## 👔 WORK & PERSONAL ENVIRONMENTS

### **ENVIRONMENT-SPECIFIC CONFIGURATIONS:**

```powershell
# Detect environment
$isWorkComputer = $env:COMPUTERNAME -match "corp"
$isPersonalComputer = $env:COMPUTERNAME -match "home|laptop"
$isServer = $env:COMPUTERNAME -match "srv"

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

### **MACHINE-SPECIFIC CONFIGURATIONS:**

```powershell
# Machine-specific configuration file
$machineConfig = "$PSScriptRoot\HFCustom-$($env:COMPUTERNAME).ps1"
if (Test-Path $machineConfig) {
    . $machineConfig
    Write-Host "📱 Loaded machine-specific config for: $($env:COMPUTERNAME)" -ForegroundColor Green
}

# Example machine-specific file (HFCustom-Desktop-ABC123.ps1):
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

## 🔧 ADVANCED CUSTOMIZATION

### **EVENT-DRIVEN ACTIONS:**

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

### **PROFILE PERFORMANCE MONITORING:**

```powershell
# Add to beginning of HFCustom.ps1
$profileStartTime = Get-Date

# Add to end of HFCustom.ps1
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

### **SECURE CREDENTIAL MANAGEMENT:**

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
# Save-SecureCredential -Key "githubToken" -Value "ghp_abc123"
# $token = Get-SecureCredential -Key "githubToken"
```

---

## 🚀 QUICK START TEMPLATES

### **MINIMAL CUSTOMIZATION (FOR BEGINNERS):**
```powershell
# HFCustom.ps1 - Minimal version

# 1. Set your editor
$EDITOR_Override = "code"

# 2. Add a few useful aliases
Set-Alias -Name home -Value { Set-Location $HOME }
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name ll -Value Get-ChildItem

# 3. Personal functions
function proj {
    Set-Location "$HOME\Projects"
    Write-Host "📁 Projects directory" -ForegroundColor Green
}

function weather {
    Invoke-RestMethod "wttr.in/?format=3" | Write-Host
}

# 4. Environment variables
$env:BAT_THEME = "TwoDark"
$env:EDITOR = "code"

Write-Host "✨ Custom profile loaded!" -ForegroundColor Green
```

### **DEVELOPER CUSTOMIZATION:**
```powershell
# HFCustom.ps1 - Developer version

# Debug mode
$debug_Override = $true

# Editor preferences
$EDITOR_Override = "nvim"
$env:EDITOR = "nvim"

# Development tools setup
function dev {
    Write-Host "💻 Starting development environment..." -ForegroundColor Cyan
    
    # Check for required tools
    $tools = @("node", "python", "git", "docker")
    foreach ($tool in $tools) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) {
            Write-Host "  ✅ $tool" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $tool not found" -ForegroundColor Red
        }
    }
    
    # Set up development environment
    $env:NODE_ENV = "development"
    $env:PYTHONPATH = "$HOME\dev\python"
    
    # Start dev tools
    # code .
    # docker-compose up -d
    
    Write-Host "✅ Development environment ready!" -ForegroundColor Green
}

# Git shortcuts
function gcom {
    param([string]$Message)
    git add .
    git commit -m $Message
    Write-Host "📝 Committed: $Message" -ForegroundColor Green
}

function gpush {
    git push
    Write-Host "🚀 Pushed changes" -ForegroundColor Green
}

# Project navigation
$projects = @{
    "web" = "$HOME\Projects\web-app"
    "api" = "$HOME\Projects\api-server"
    "mobile" = "$HOME\Projects\mobile-app"
}

foreach ($key in $projects.Keys) {
    Set-Alias -Name "go-$key" -Value { Set-Location $projects[$key] }
}

Write-Host "🚀 Developer profile loaded!" -ForegroundColor Cyan
```

---

## ❓ TROUBLESHOOTING

### **COMMON ISSUES:**

1. **Profile not loading:**
   ```powershell
   # Check execution policy
   Get-ExecutionPolicy -List
   
   # Set execution policy
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   
   # Check for syntax errors
   . $PROFILE -ErrorAction Stop
   ```

2. **Function conflicts:**
   ```powershell
   # Find function conflicts
   Get-Command -Type Function | Group-Object Name | Where-Object Count -gt 1
   
   # Remove conflicting function
   Remove-Item Function:conflicting-function
   ```

3. **Module loading issues:**
   ```powershell
   # Check module paths
   $env:PSModulePath -split ';'
   
   # List available modules
   Get-Module -ListAvailable | Select-Object Name, Version, Path
   ```

### **DEBUGGING:**
```powershell
# Enable debug mode
$debug_Override = $true

# Test profile loading
. $PROFILE -Verbose

# Check loaded modules
Get-Module | Format-Table Name, Version, Path -AutoSize

# View recent errors
$Error[0..5] | Format-List -Force
```

---

## 📚 ADDITIONAL RESOURCES

* **Your Repository:** [https://github.com/hetfs/powershell-profile](https://github.com/hetfs/powershell-profile)
* **PowerShell Documentation:** [Microsoft Docs](https://learn.microsoft.com/powershell/)
* **Starship Prompt:** [starship.rs](https://starship.rs/)
* **Nerd Fonts:** [nerdfonts.com](https://www.nerdfonts.com/)

---

**🎉 HAPPY CUSTOMIZING!** Your PowerShell environment is now tailored to your workflow. Remember to back up your `HFCustom.ps1` file when making significant changes.
