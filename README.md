# 🚀 PowerShell Profile - Modular Refactor

A completely, modular PowerShell profile that transforms your terminal into a powerful development environment. Built with maintainability, extensibility, and developer productivity in mind.

## ✨ Features

* **🎯 Modular Architecture** Clean separation of concerns with individual module files
* **🔄 Selective Loading** Enable/disable modules by commenting in the load order
* **🔧 Easy Maintenance** Edit individual modules without touching the core profile
* **📦 Version Control Friendly** Track changes to specific modules
* **🎨 Modern Tools** Starship prompt, zoxide navigation, bat/eza for better listings
* **⚡ Auto-Updating**  Built-in update checks for profile and PowerShell
* **🎯 Developer Focused** Git shortcuts, smart completions, productivity tweaks
* **🔍 Easy Debugging** Isolate issues to specific modules

---

## 📦 Quick Start

### Prerequisites

* Windows PowerShell 5.1+ or PowerShell 7+
* Administrator rights (for full installation)
* Winget package manager (comes with Windows 11/10 1809+)

### One-Line Installation

```powershell
# Download and run the setup script
irm https://raw.githubusercontent.com/https/powershell-profile/main/setup.ps1 | iex
```

### Manual Installation

1. **Clone or download the repository**
```powershell
# Option 1: Clone (if you have Git)
git clone https://github.com/hetfs/powershell-profile.git "$env:TEMP\powershell-profile"
Set-Location "$env:TEMP\powershell-profile"

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

## 📁 Project Structure

```
Documents/PowerShell/
├── Microsoft.PowerShell_profile.ps1         # Main profile entry point
├── CTTcustom.ps1                            # Custom overrides (optional)
├── Modules/                                 # All modular components
│   ├── ProfileConfig.ps1                    # Configuration and settings
│   ├── CoreFunctions.psm1                   # Essential utility functions
│   ├── DebugModule.psm1                     # Debug mode functionality
│   ├── UpdateModule.psm1                    # Profile and PowerShell updates
│   ├── AdminModule.psm1                     # Admin functions and prompt
│   ├── EditorModule.psm1                    # Editor configuration
│   ├── NetworkModule.psm1                   # Networking utilities
│   ├── SystemModule.psm1                    # System information tools
│   ├── GitModule.psm1                       # Git shortcuts and functions
│   ├── NavigationModule.psm1                # Directory navigation
│   ├── UtilityModule.psm1                   # General utilities
│   ├── PSReadLineModule.psm1                # Enhanced command line
│   ├── CompletionModule.psm1                # Auto-completion setup
│   ├── ThemeModule.psm1                     # Prompt theming (Starship)
│   ├── ZoxideModule.psm1                    # Smart directory navigation
│   └── HelpModule.psm1                      # Help system
└── LastExecutionTime.txt                    # Update tracking
```

---

## 🛠️ Installation Details

### What Gets Installed

The setup script installs the following modern CLI tools via Winget:

| Tool | Purpose | Winget ID |
|------|---------|-----------|
| Git | Version control | Git.Git |
| Starship | Cross-shell prompt | starship.starship |
| zoxide | Smarter cd command | ajeetdsouza.zoxide |
| fd | Fast file finder | sharkdp.fd |
| ripgrep | Fast text search | BurntSushi.ripgrep.MSVC |
| bat | Better cat command | sharkdp.bat |
| eza | Modern ls replacement | eza.eza |
| delta | Git diff viewer | dandavison.delta |
| gsudo | Sudo for Windows | gerardog.gsudo |
| GitHub CLI | GitHub from terminal | GitHub.cli |
| lazygit | Terminal Git UI | JesseDuffield.lazygit |
| Neovim | Modern Vim editor | neovim.neovim |
| tldr | Simplified man pages | tealdeer.tealdeer |

### Additional Components

* **Nerd Fonts** Installs CaskaydiaCove NF font for proper icon support
* **PowerShell Modules** Terminal-Icons, PSReadLine enhancements
* **Chocolatey** Optional package manager installation
* **Profile Structure** Creates modular profile with auto-update capability

---

## 🎯 Customization

### Module Management

**Disable a module:** Comment it out in the `$modulesToLoad` array in `Microsoft.PowerShell_profile.ps1`:

```powershell
$modulesToLoad = @(
    "CoreFunctions",
    "DebugModule",
    # "ThemeModule",     # Disabled - uses default prompt
    "ZoxideModule",
    # ... other modules
)
```

**Add a custom module:**
1. Create `Modules\CustomModule.psm1`
2. Add functions and export them with `Export-ModuleMember`
3. Add "CustomModule" to the `$modulesToLoad` array

### Override System

Create or edit `CTTcustom.ps1` in your PowerShell directory to override settings:

```powershell
# $HOME\Documents\PowerShell\CTTcustom.ps1

# Variable overrides
$debug_Override = $false
$EDITOR_Override = "nvim"
$updateInterval_Override = 14  # Check for updates every 2 weeks

# Function overrides
function Update-Profile_Override {
    Write-Host "Using custom update logic..." -ForegroundColor Yellow
    # Your custom update code here
}

function Get-Theme_Override {
    # Custom theme setup - Starship with custom config
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        # Load custom starship config
        Invoke-Expression (&starship init powershell --config ~/.config/starship-custom.toml)
    }
}
```

### Available Overrides

| Variable | Description | Default |
|----------|-------------|---------|
| `$debug_Override` | Enable debug mode | `$false` |
| `$repo_root_Override` | Custom update source | ChrisTitusTech repo |
| `$timeFilePath_Override` | Custom update tracking file | `LastExecutionTime.txt` |
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

### Git Shortcuts
| Shortcut | Command | Description |
|----------|---------|-------------|
| `gs` | `git status` | Check status |
| `ga` | `git add .` | Stage all changes |
| `gc "msg"` | `git commit -m "msg"` | Commit with message |
| `gpush` | `git push` | Push changes |
| `gpull` | `git pull` | Pull changes |
| `gcom "msg"` | Add + commit | Stage and commit |
| `lazyg "msg"` | Add + commit + push | Complete workflow |
| `gcl <url>` | `git clone` | Clone repository |

### Navigation
| Command | Description |
|---------|-------------|
| `docs` | Go to Documents folder |
| `dtop` | Go to Desktop folder |
| `mkcd <dir>` | Create and enter directory |
| `z <query>` | Smart directory jump (zoxide) |
| `g` | Jump to GitHub directory |
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
| `winutildev` | Dev version of winutil |

### File Operations
| Command | Description |
|---------|-------------|
| `touch <file>` | Create empty file |
| `trash <path>` | Move to Recycle Bin |
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

After installation, customize your prompt:

```powershell
# Create a basic starship config
starship preset pastel-powerline > ~/.config/starship.toml

# Or create your own config
@"
# ~/.config/starship.toml
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[directory]
truncation_length = 3
truncate_to_repo = true
"@ | Set-Content ~/.config/starship.toml
```

### Font Setup

1. **Restart Windows Terminal** after installation
2. **Set font** to "CaskaydiaCove NF" in terminal settings
3. **Configure icons** by setting `$env:TERMINAL_ICONS_CUSTOM_FOLDER` if needed

---

## 🔍 Debugging & Troubleshooting

### Enable Debug Mode

```powershell
# In your CTTcustom.ps1 or directly in profile
$debug_Override = $true
```

### Common Issues

| Issue | Solution |
|-------|----------|
| **Profile not loading** | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| **Module not found** | Check module path and spelling in `$modulesToLoad` |
| **Starship not showing** | Install starship: `winget install starship.starship` |
| **Font not appearing** | Restart terminal, set font to "CaskaydiaCove NF" |
| **zoxide not working** | Add `Invoke-Expression (& { (zoxide init powershell | Out-String) })` to profile |
| **Permission errors** | Run PowerShell as Administrator |

### Testing Module Loading

```powershell
# Test specific module
. $PSScriptRoot\Modules\GitModule.psm1
gs  # Should show git status

# Check loaded modules
Get-Module | Select-Object Name

# Check for errors
$Error[0..5] | Format-List -Force
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
# Backup entire profile structure
Copy-Item "$HOME\Documents\PowerShell" "$HOME\Documents\PowerShell_Backup_$(Get-Date -Format 'yyyyMMdd')" -Recurse

# Backup individual module
Copy-Item "$HOME\Documents\PowerShell\Modules\GitModule.psm1" "$HOME\Backups\"
```

---

## 🤝 Contributing

### Module Development Guidelines

1. **Single Responsibility** Each module should handle one concern
2. **Export Functions** Use `Export-ModuleMember -Function <name>`
3. **Error Handling** Include try/catch blocks for robustness
4. **Help Comments** Add comment-based help for functions
5. **Testing** Test module in isolation before integration

### Example Module Template
```powershell
# Modules/NewModule.psm1
<#
.SYNOPSIS
    Brief description of module
.DESCRIPTION
    Detailed description of module functionality
#>

function New-Function {
    <#
    .SYNOPSIS
        Brief description
    .EXAMPLE
        New-Function -Parameter Value
    #>
    [CmdletBinding()]
    param()
    
    try {
        # Function logic here
    }
    catch {
        Write-Error "Error in New-Function: $_"
    }
}

Export-ModuleMember -Function New-Function
```

---

## 📚 Learning Resources

* [PowerShell Documentation](https://learn.microsoft.com/powershell/) Official Microsoft docs
* [Starship Documentation](https://starship.rs/) Cross-shell prompt guide
* [Oh My Posh Themes](https://ohmyposh.dev/docs/themes) Alternative theming
* [Windows Terminal Docs](https://learn.microsoft.com/windows/terminal/) Terminal configuration
* [PowerShell Gallery](https://www.powershellgallery.com/) Community modules

---

## ⚖️ License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

* [Chris Titus Tech](https://christitus.com/) Original profile inspiration
* [Starship](https://starship.rs/) Cross-shell prompt
* [Nerd Fonts](https://www.nerdfonts.com/) Iconic font patches
* [Terminal Icons](https://github.com/devblackops/Terminal-Icons) File type icons
* [PSReadLine](https://github.com/PowerShell/PSReadLine) Enhanced command line

---

## 🆘 Support

* **Issues**: [GitHub Issues](https://github.com/ChrisTitusTech/powershell-profile/issues)
* **Discussion**: Check the GitHub Discussions
* **Quick Help**: Run `Show-Help` in PowerShell

---

**Happy PowerShelling!** 🎉

