# PowerShell Profile hetfs Edition

A completely modular PowerShell profile that transforms your terminal into a powerful development environment. Built with maintainability, extensibility, and developer productivity in mind.

## ✨ Features

* **🎯 Modular Architecture** Clean, organized sections with clear separation of concerns
* **🔄 Starship Prompt** Fast, cross-shell prompt with extensive customization
* **📁 Smart Navigation** zoxide for intelligent directory jumping
* **🎨 Terminal Icons** Beautiful file and folder icons
* **⚡ Auto-Updating** Built-in update checks for profile and PowerShell
* **🔧 Override System** Safe customization without modifying main profile
* **🎯 Developer Focused** Git shortcuts, smart completions, productivity tweaks
* **🔍 Easy Debugging** Isolate issues with debug mode

---

## 📦 Quick Start

### Prerequisites

* Windows PowerShell 5.1+ or PowerShell 7+
* Administrator rights (for full installation)
* Winget package manager (comes with Windows 11/10 1809+)

### One-Line Installation

```powershell
# Download and run the setup script (Run as Administrator)
irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/setup.ps1 | iex
```

### Manual Installation

1. **Clone or download the repository**
```powershell
# Option 1: Clone (if you have git)
git clone https://github.com/hetfs/powershell-profile.git "$env:temp\powershell-profile"
Set-Location "$env:temp\powershell-profile"

# Option 2: Download manually
# Download setup.ps1 and Microsoft.PowerShell_profile.ps1 to your PowerShell directory
```

2. **Run the setup script**
```powershell
# Run as Administrator for full installation
.\setup.ps1
```

3. **Restart PowerShell/Terminal**
```powershell
# Close and reopen your terminal, or run:
. $PROFILE
```

---

## 🛠️ Installation Details

### What Gets Installed

The setup script installs the following modern CLI tools:

| Tool | Purpose | Installation Method |
|------|---------|-------------------|
| **Starship** | Cross-shell prompt | Winget |
| **zoxide** | Smart directory navigation | Winget |
| **Terminal Icons** | File type icons | PowerShell Gallery |
| **Nerd Font** | CaskaydiaCove NF font | GitHub releases |
| **Optional: Chocolatey** | Package manager | Installation script |

### Components

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

## 🤝 Contributing

### Development Guidelines

1. **Maintain Override System** - Always support `_Override` functions
2. **Error Handling** - Include try/catch blocks for robustness
3. **Documentation** - Add comments and update help text
4. **Backward Compatibility** - Don't break existing functionality
5. **Testing** - Test changes in both Windows PowerShell and PowerShell 7

### Module Structure Principles

- **Single Responsibility** - Each section handles one concern
- **Clear Dependencies** - Load order matters, document dependencies
- **Override Support** - Always allow user customization
- **Error Resilience** - Fail gracefully with helpful messages

---

## 📚 Learning Resources

* [PowerShell Documentation](https://learn.microsoft.com/powershell/) - Official Microsoft docs
* [Starship Documentation](https://starship.rs/) - Cross-shell prompt guide
* [zoxide Documentation](https://github.com/ajeetdsouza/zoxide) - Smart `cd` replacement
* [Windows Terminal Docs](https://learn.microsoft.com/windows/terminal/) - Terminal configuration
* [PowerShell Gallery](https://www.powershellgallery.com/) - Community modules

---

## ⚖️ License

MIT License - See [LICENSE](./LICENSE) file for details

## 🙏 Acknowledgments

Based on the original work by [Chris Titus Tech](https://christitus.com/)
* [Starship](https://starship.rs/) - Cross-shell prompt
* [Nerd Fonts](https://www.nerdfonts.com/) - Iconic font patches
* [Terminal Icons](https://github.com/devblackops/Terminal-Icons) - File type icons
* [zoxide](https://github.com/ajeetdsouza/zoxide) - Smarter `cd` command
* [PSReadLine](https://github.com/PowerShell/PSReadLine) - Enhanced command line

---

## 🆘 Support

* **Issues**: [GitHub Issues](https://github.com/hetfs/powershell-profile/issues)
* **Quick Help**: Run `Show-Help` in PowerShell
* **Customization Help**: See `docs/CUSTOMIZATION.md`

---

**Happy PowerShelling!** 🎉

## 🚀 Quick Reference Card

### Installation Cheat Sheet

```powershell
# One-line install (Admin)
irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/setup.ps1 | iex

# Manual steps
1. Clone repo
2. Run setup.ps1 as Admin
3. Restart terminal
4. Customize as needed
```

### Essential Commands

```powershell
# Profile management
ep           # Edit profile
Update-Profile   # Update from repo
reload-profile   # Reload current profile

# Git workflow
gs           # git status
ga           # git add .
gc "msg"     # git commit -m "msg"
lazyg "msg"  # add + commit + push

# Navigation
z <folder>   # Smart directory jump
docs         # Go to Documents
dtop         # Go to Desktop
la           # List all files

# System
admin        # Open admin terminal
uptime       # System uptime
sysinfo      # System information
```

### Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| Main Profile | Core functionality | `$PROFILE` |
| Custom Overrides | Personal settings | `$HOME\Documents\PowerShell\profile.ps1` |
| Extended Custom | Additional functions | `$HOME\Documents\PowerShell\HETFScustom.ps1` |
| Starship Config | Prompt customization | `$HOME\.config\starship.toml` |
