# PowerShell Profile User Guide

## 🎨 `HETFSCustom.ps1` Complete Customization Guide

### 📖 Introduction

`HETFSCustom.ps1` is the **personal customization file** for the modular PowerShell profile. It allows you to tailor your environment, define personal aliases, functions, environment variables, and theming **without modifying core modules**. Your customizations persist through profile updates.

---

## 📍 File Location & Loading

### **Location**

```text
$HOME\Documents\PowerShell\HFCustom.ps1
```

### **Loading Order**

1. Main profile (`Microsoft.PowerShell_profile.ps1`) loads first
2. `HETFSCustom.ps1` loads last (if it exists)

### **Verification**

```powershell
# Check if HFCustom.ps1 exists
Test-Path "$HOME\Documents\PowerShell\HETFSCustom.ps1"

# Check loading order in debug mode
$debug_Override = $true
. $PROFILE
```

---

## 🎯 Override System

### **Variable Overrides**

Append `_Override` to core variable names to override defaults:

| Variable                   | Description              | Default                 | Example                                                                              |
| -------------------------- | ------------------------ | ----------------------- | ------------------------------------------------------------------------------------ |
| `$debug_Override`          | Enable debug mode        | `$false`                | `$debug_Override = $true`                                                            |
| `$EDITOR_Override`         | Preferred editor         | Auto-detected           | `$EDITOR_Override = "code"`                                                          |
| `$repo_root_Override`      | Update source URL        | Default repo            | `$repo_root_Override = "https://raw.githubusercontent.com/hetfs/powershell-profile"` |
| `$timeFilePath_Override`   | Update tracking file     | `LastExecutionTime.txt` | `$timeFilePath_Override = "$env:TEMP\PowerShellUpdates.txt"`                         |
| `$updateInterval_Override` | Update frequency in days | `7`                     | `$updateInterval_Override = 14`                                                      |

**Example:**

```powershell
$debug_Override = $false
$EDITOR_Override = "nvim"
$updateInterval_Override = 30
$repo_root_Override = "https://raw.githubusercontent.com/hetfs/powershell-profile"
```

### **Function Overrides**

Append `_Override` to replace core functions:

| Function                        | Description           | Use Case                        |
| ------------------------------- | --------------------- | ------------------------------- |
| `Debug-Message_Override`        | Custom debug output   | Change debug display            |
| `Update-Profile_Override`       | Profile update logic  | Use custom repository           |
| `Update-PowerShell_Override`    | PowerShell update     | Alternate update strategy       |
| `Clear-Cache_Override`          | Cache clearing        | Add extra cache paths           |
| `Get-Theme_Override`            | Prompt theming        | Custom Starship or prompt setup |
| `WinUtilDev_Override`           | WinUtil script        | Use custom source               |
| `Set-PredictionSource_Override` | PSReadLine prediction | Custom prediction settings      |

**Example:**

```powershell
function Update-Profile_Override {
    Write-Host "🔄 Custom profile update running..." -ForegroundColor Yellow
    $backupDir = "$HOME\PowerShellBackups\$(Get-Date -Format 'yyyyMMdd')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Copy-Item $PROFILE "$backupDir\profile.ps1" -Force

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

## 🛠️ Custom Functions & Aliases

### **Creating Functions**

```powershell
function Verb-Noun {
    [CmdletBinding()]
    param(
        [string]$Parameter1,
        [switch]$Flag
    )
    process {
        Write-Host "Processing: $Parameter1"
        if ($Flag) { Write-Host "Flag enabled" }
    }
}
```

### **Example Functions**

**Project Management:**

```powershell
function proj {
    param([string]$ProjectName, [switch]$List, [switch]$Create)
    $projectsRoot = "$HOME\Projects"
    if (-not (Test-Path $projectsRoot)) { New-Item -ItemType Directory -Path $projectsRoot -Force | Out-Null }

    if ($List) {
        Get-ChildItem $projectsRoot -Directory | ForEach-Object { Write-Host "• $($_.Name)" }
        return
    }

    if ($Create -and $ProjectName) {
        $newPath = Join-Path $projectsRoot $ProjectName
        if (-not (Test-Path $newPath)) { New-Item -ItemType Directory -Path $newPath; Set-Location $newPath; Write-Host "✅ Created: $ProjectName" }
        else { Write-Host "⚠️ Already exists: $ProjectName" }
        return
    }

    if ($ProjectName) {
        $path = Join-Path $projectsRoot $ProjectName
        if (Test-Path $path) { Set-Location $path; Write-Host "📂 Switched to: $ProjectName" }
        else { Write-Host "❌ Project not found" }
    } else { Set-Location $projectsRoot; Write-Host "📁 Projects root" }
}
```

**Git Shortcuts:**

```powershell
function git-branch-cleanup {
    git fetch --prune
    $merged = git branch --merged main | Where-Object { $_ -notmatch "^\*?\s*(main|master)$" }
    $merged | ForEach-Object { git branch -d $_.Trim(); Write-Host "Deleted: $_" }
}
function git-commit-amend {
    git add .
    git commit --amend --no-edit
    Write-Host "📝 Amended last commit"
}
```

**System Diagnostics:**

```powershell
function system-health {
    $cpu = Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average | Select-Object -ExpandProperty Average
    Write-Host "CPU Usage: $cpu%"
    $mem = Get-CimInstance Win32_OperatingSystem
    $used = [math]::Round(($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory)/1MB,2)
    $total = [math]::Round($mem.TotalVisibleMemorySize/1MB,2)
    Write-Host "Memory: ${used}GB / ${total}GB"
    Get-PSDrive -PSProvider FileSystem | ForEach-Object { Write-Host "$($_.Name): $([math]::Round($_.Used/1GB,2))GB / $([math]::Round($_.Used/1GB + $_.Free/1GB,2))GB" }
}
```

### **Creating Aliases**

```powershell
Set-Alias -Name home -Value { Set-Location $HOME }
Set-Alias -Name docs -Value { Set-Location ([Environment]::GetFolderPath("MyDocuments")) }
Set-Alias -Name nv -Value nvim
Set-Alias -Name gco -Value git checkout
Set-Alias -Name cls -Value Clear-Host
```

---

## 🌍 Environment Variables

### **Setting Variables**

```powershell
$env:EDITOR = "nvim"
$env:PAGER = "delta"
$env:BAT_THEME = "TwoDark"
$env:GOPATH = "$HOME\go"
$env:CARGO_HOME = "$HOME\.cargo"
```

### **Adding to PATH**

```powershell
$paths = @("$HOME\bin", "$env:GOPATH\bin", "$env:CARGO_HOME\bin")
foreach ($p in $paths) { if (-not $env:PATH.Contains($p)) { $env:PATH = "$p;$env:PATH" } }
```

### **Persistent Variables**

```powershell
[System.Environment]::SetEnvironmentVariable("MY_VAR","value",[System.EnvironmentVariableTarget]::User)
```

---

## 🎨 Prompt Customization

**Basic Prompt:**

```powershell
function prompt {
    "$((Get-Date -Format 'HH:mm')) $(Get-Location)`nPS> "
}
```

**Colored Prompt with Git Info:**

```powershell
function prompt {
    $path = Get-Location
    $branch = if (Test-Path .git) { git branch --show-current 2>$null }
    Write-Host "$path [$branch]" -ForegroundColor Cyan
    "PS> "
}
```

**Starship Integration:**

```powershell
function Get-Theme_Override {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        $env:STARSHIP_CONFIG="$HOME\.config\starship.toml"
        Invoke-Expression (&starship init powershell)
    }
}
```

---

## 📦 Module Management

**Import Modules:**

```powershell
Import-Module PSReadLine -ErrorAction SilentlyContinue
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
```

**Conditional Modules:**

```powershell
if ($env:COMPUTERNAME -match "work") { Import-Module ActiveDirectory }
if ($env:COMPUTERNAME -match "dev") { Import-Module DockerCompletion }
```

---

## 👔 Work & Personal Environments

```powershell
if ($env:COMPUTERNAME -match "corp") { function work-start { Write-Host "🚀 Work mode" } }
if ($env:COMPUTERNAME -match "home") { function dev-setup { Write-Host "💻 Dev mode" } }
```

Machine-specific configs: `$PSScriptRoot\HFCustom-$($env:COMPUTERNAME).ps1`

---

## 🔧 Advanced Customization

**Event-Driven Actions:**

```powershell
function On-DirectoryChange { param($newPath) }
```

**Profile Performance Monitoring:**

```powershell
$profileStartTime = Get-Date
# At end
$loadTime = (Get-Date - $profileStartTime).TotalMilliseconds
Write-Host "Profile loaded in $loadTime ms"
```

**Secure Credential Management:**

```powershell
function Save-SecureCredential { param($Key,$Value) }
function Get-SecureCredential { param($Key) }
```

---

## 🚀 Quick Start Templates

**Minimal Customization:**

```powershell
$EDITOR_Override="code"
Set-Alias home { Set-Location $HOME }
Write-Host "✨ Custom profile loaded!"
```

**Developer Customization:**

```powershell
$EDITOR_Override="nvim"
function dev { Write-Host "💻 Dev environment ready" }
function gcom { git add .; git commit -m $Message }
Write-Host "🚀 Developer profile loaded!"
```

---

## ❓ Troubleshooting

* Profile not loading: check execution policy
* Function conflicts: `Get-Command -Type Function | Group-Object Name`
* Module issues: inspect `$env:PSModulePath` and `Get-Module -ListAvailable`
* Debug mode: `$debug_Override = $true`

---

## 📚 Additional Resources

* [Repository](https://github.com/hetfs/powershell-profile)
* [PowerShell Docs](https://learn.microsoft.com/powershell/)
* [Starship Prompt](https://starship.rs/)
* [Nerd Fonts](https://www.nerdfonts.com/)

---

**🎉 Happy Customizing!** Backup your `HETFSCustom.ps1` when making major changes.
