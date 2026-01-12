
# 🛠️ Installation Details

## What Gets Installed

The setup script installs the following modern CLI tools:

| Tool | Purpose | Installation Method |
|------|---------|-------------------|
| **Starship** | Cross-shell prompt | Winget |
| **zoxide** | Smart directory navigation | Winget |
| **Terminal Icons** | File type icons | PowerShell Gallery |
| **Nerd Font** | CaskaydiaCove NF font | GitHub releases |
| **Optional: Chocolatey** | Package manager | Installation script |

## Components

| Component | Description |
|-----------|-------------|
| **Starship Prompt** | Fast, customizable prompt written in Rust |
| **zoxide** | Smarter `cd` command that learns your habits |
| **PSReadLine** | Enhanced command line editing |
| **Terminal Icons** | Visual file type indicators |
| **Custom Aliases** | Shortcuts for common commands |
| **Git Integration** | Useful Git workflows and aliases |
| **System Utilities** | Network, file, and system management tools |

---

## 🎯 Customization

### Override System

Create or edit `$HOME\Documents\PowerShell\profile.ps1` to override settings:

```powershell
# Example overrides in profile.ps1

# Variable Overrides
$debug_Override = $false
$EDITOR_Override = "nvim"
$updateInterval_Override = 14  # Check updates every 2 weeks
$repo_root_Override = "https://raw.githubusercontent.com/YOUR_USERNAME/powershell-profile"

# Function Overrides
function Debug-Message_Override {
    Write-Host "=== CUSTOM DEBUG MODE ===" -ForegroundColor Cyan
}

function Get-Theme_Override {
    # Custom Starship configuration
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        # Load custom Starship config
        $env:STARSHIP_CONFIG = "$HOME\.config\starship-custom.toml"
        Invoke-Expression (&starship init powershell)
    }
}
```

### HETFScustom.ps1

For more extensive customizations, create `HETFScustom.ps1` in your PowerShell directory:

```powershell
# Load additional modules
Import-Module PSScriptAnalyzer

# Add custom functions
function Get-Weather {
    param([string]$City = "London")
    (Invoke-WebRequest "https://wttr.in/$City").Content
}

# Custom aliases
Set-Alias -Name weather -Value Get-Weather
Set-Alias -Name dcup -Value { docker-compose up }
Set-Alias -Name dcdown -Value { docker-compose down }
```

### Available Overrides

| Variable | Description | Default |
|----------|-------------|---------|
| `$debug_Override` | Enable debug mode | `$false` |
| `$repo_root_Override` | Custom update source | hetfs repo |
| `$timeFilePath_Override` | Update tracking file | `LastExecutionTime.txt` |
| `$updateInterval_Override` | Update frequency (days) | `7` |
| `$EDITOR_Override` | Preferred editor | Auto-detected |

| Function | Description |
|----------|-------------|
| `Debug-Message_Override` | Custom debug messages |
| `Update-Profile_Override` | Custom update logic |
| `Update-PowerShell_Override` | Custom PowerShell update |
| `Clear-Cache_Override` | Custom cache clearing |
| `Get-Theme_Override` | Custom prompt/theme |
| `WinUtilDev_Override` | Custom WinUtil script |
| `Set-PredictionSource_Override` | Custom prediction settings |

---

## 🔧 Key Commands & Shortcuts

### Profile Management

| Command | Description | Alias |
|---------|-------------|-------|
| `Update-Profile` | Check for profile updates | |
| `Update-PowerShell` | Check for PowerShell updates | |
| `Edit-Profile` | Edit the main profile | `ep` |
| `reload-profile` | Reload the profile | |
| `Clear-Cache` | Clear system cache | |
| `Show-Help` | Display help message | |

### Git Shortcuts

| Shortcut | Command | Description |
|----------|---------|-------------|
| `gs` | `git status` | Check status |
| `ga` | `git add .` | Stage all changes |
| `gc "msg"` | `git commit -m "msg"` | Commit with message |
| `gpush` | `git push` | Push changes | `gp` |
| `gpull` | `git pull` | Pull changes |
| `gcom "msg"` | add + commit | Stage and commit |
| `lazyg "msg"` | add + commit + push | Complete workflow |
| `gcl <url>` | `git clone` | Clone repository |
| `g` | `zoxide github` | Jump to GitHub directory |

### Navigation

| Command | Description |
|---------|-------------|
| `docs` | Go to Documents folder |
| `dtop` | Go to Desktop folder |
| `mkcd <dir>` | Create and enter directory |
| `z <query>` | Smart directory jump (zoxide) |
| `la` | List all files (detailed) |
| `ll` | List including hidden files |

### System Utilities

| Command | Description |
|---------|-------------|
| `admin` | Open admin terminal | `su` |
| `uptime` | Show system uptime |
| `sysinfo` | Display system information |
| `flushdns` | Clear DNS cache |
| `Get-PubIP` | Get public IP address |
| `winutil` | System utility tool |
| `winutildev` | Dev version of WinUtil |

### File Operations

| Command | Description |
|---------|-------------|
| `touch <file>` | Create empty file |
| `trash <path>` | Move to recycle bin |
| `ff <pattern>` | Find files by name |
| `unzip <file>` | Extract archive |
| `hb <file>` | Upload to hastebin |
| `grep <pattern>` | Search with regex |

### Development

| Command | Description |
|---------|-------------|
| `nf <name>` | Create new file |
| `which <cmd>` | Show command path |
| `k9 <process>` | Kill process by name |
| `pgrep <name>` | Find process by name |
| `cpy <text>` | Copy to clipboard |
| `pst` | Paste from clipboard |

---

## 🎨 Theme & Appearance

### Starship Configuration

After installation, customize your Starship prompt:

```powershell
# Create a basic Starship config
@"
# ~/.config/starship.toml
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[directory]
truncation_length = 3
style = "cyan bold"

[git_branch]
symbol = "🌱 "
style = "bold green"
"@ | Set-Content ~/.config/starship.toml
```

### Font Setup

1. **Install Nerd Font** - Setup script installs CaskaydiaCove NF
2. **Restart Windows Terminal** after installation
3. **Set Font** to "CaskaydiaCove NF" in terminal settings
4. **Configure Icons** - Terminal Icons module handles icon display

---

## 🔍 Debugging & Troubleshooting

### Enable Debug Mode

```powershell
# In your profile.ps1 or directly in profile
$debug_Override = $true

# Or temporarily at runtime
$debug = $true
Update-Profile
```

### Common Issues

| Issue | Solution |
|-------|----------|
| **Profile not loading** | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| **Starship not showing** | Install Starship: `winget install Starship.Starship` |
| **Font not appearing** | Restart terminal, set font to "CaskaydiaCove NF" |
| **zoxide not working** | Ensure it's installed: `winget install ajeetdsouza.zoxide` |
| **Permission errors** | Run PowerShell as Administrator |
| **Update checks failing** | Check internet connection, set `$canConnectToGitHub` |

### Testing Profile Loading

```powershell
# Test profile loading
. $PROFILE

# Check for errors
$error[0..5] | Format-List -Force

# Test specific functions
Get-PubIP
gs
la
```

---

## 🔄 Updates & Maintenance

### Automatic Updates

The profile checks for updates every 7 days by default. Change interval:

```powershell
$updateInterval_Override = 14  # Check every 2 weeks
$updateInterval_Override = -1  # Always check
$updateInterval_Override = 0   # Never check
```

### Manual Updates

```powershell
Update-Profile    # Update profile from repository
Update-PowerShell # Update PowerShell itself
```

### Creating Backups

```powershell
# Backup entire profile
Copy-Item $PROFILE "$PROFILE.backup-$(Get-Date -Format 'yyyyMMdd')"

# Backup customizations
Copy-Item "$HOME\Documents\PowerShell\profile.ps1" "$HOME\Backups\"
```

---

## 🏗️ Project Structure

```
powershell-profile/
├── setup.ps1                    # Main installation script
├── setprofile.ps1              # Manual profile copy utility
├── Microsoft.PowerShell_profile.ps1  # Main profile (21 sections)
├── HETFScustom.ps1.example     # Customization template
├── starship.toml.example       # Starship configuration example
├── docs/
│   └── CUSTOMIZATION.md        # Detailed customization guide
├── .gitignore                  # Git ignore rules
├── README.md                   # This file
└── LICENSE                     # MIT License
```

### Profile Sections

1. **Configuration & Header** - Warnings and license info
2. **Override System Initialization** - Customization framework
3. **Debug & Core Functions** - Debug mode and core utilities
4. **Update System** - Auto-update functionality
5. **Utility Functions** - General utilities
6. **Module Imports** - External module loading
7. **Editor Configuration** - Editor preferences
8. **File Operations** - File management utilities
9. **Network Utilities** - Network tools
10. **System Utilities** - System information tools
11. **Directory Management** - Navigation utilities
12. **Git Shortcuts** - Git workflows
13. **WinUtil Functions** - System maintenance tools
14. **Quality of Life Aliases** - Common shortcuts
15. **PSReadLine Configuration** - Enhanced command line
16. **Starship Prompt Configuration** - Modern prompt setup
17. **Auto-Completion** - Smart tab completion
18. **zoxide Configuration** - Smart directory navigation
19. **Help Function** - Built-in documentation
20. **Customizations Loader** - External customization loading

---
