<div align="center">

# PowerShell Profile & DevTools

# **HETFS LTD Edition**

[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-blue)](https://learn.microsoft.com/powershell/)

[![License](https://img.shields.io/badge/License-MIT-green)](./LICENSE)

A production-grade PowerShell environment with a bootstrap-first DevTools system for managing developer tools at scale.

</div>

A **fully modular PowerShell environment** that turns your terminal into a powerful, reproducible, and developer-focused workspace.
This repository unifies a **modern PowerShell profile** with **DevTools**, a data-driven toolkit for bootstrapping and managing developer tools at scale.
It is built for **maintainability**, **extensibility**, and **long-term productivity**.

---

## Overview

This project delivers:

* A **modular PowerShell profile** optimized for daily development
* A **bootstrap-first DevTools system** for installing and validating tools
* Safe defaults with explicit override points
* First-class support for local usage, CI, and automation

Each component works seamlessly together, while remaining fully usable on its own.

---

## PowerShell Profile

The PowerShell profile enhances your shell with modern tooling, smart defaults, and productivity shortcuts—without sacrificing reliability or maintainability.

### Features

1. **Modular architecture**
   Clear separation of concerns with readable, maintainable sections.

2. **Starship prompt**
   Fast, cross-shell prompt with rich context and deep customization.

3. **Smart navigation**
   zoxide-powered directory jumping.

4. **Terminal icons**
   Improved file and folder visibility.

5. **Auto-updating**
   Built-in checks for PowerShell and profile updates.

6. **Override system**
   Safe customization without modifying core files.

7. **Developer-focused defaults**
   Git shortcuts, completions, and quality-of-life enhancements.

8. **Debug-friendly**
   Dedicated debug mode for quickly isolating profile issues.

---

## Quick Start

### Prerequisites

* PowerShell 7.0 or newer
* Internet access for downloads
* Administrator privileges for full installation
* WinGet (Windows 10 1809+ or Windows 11)

### One-Line Installation

Run as Administrator:

```powershell
irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/setup.ps1 | iex
```

This installs the profile, required tools, and optional enhancements.

---

## Manual Installation

Clone or download the repository:

```powershell
git clone https://github.com/hetfs/powershell-profile.git "$env:TEMP\powershell-profile"
Set-Location "$env:TEMP\powershell-profile"
```

Run the setup script:

```powershell
.\setup.ps1
```

Restart your terminal when complete.

---

## Essential Commands

```powershell
Show-Help        # Quick help and overview

# Profile management
ep               # Edit profile
Update-Profile   # Update from repository
reload-profile   # Reload profile without restarting

# Git workflow
gs               # git status
ga               # git add .
gc "msg"         # git commit -m "msg"
lazyg "msg"      # add, commit, and push

# Navigation
z <folder>       # Smart directory jump
docs             # Go to Documents
dtop             # Go to Desktop
la               # List all files

# System
admin | su       # Open elevated terminal
uptime           # System uptime
sysinfo          # System information
```

---

## Configuration Files

| File             | Purpose            | Location                                     |
| ---------------- | ------------------ | -------------------------------------------- |
| Main Profile     | Core profile logic | `$PROFILE`                                   |
| Custom Overrides | Personal settings  | `$HOME\Documents\PowerShell\profile.ps1`     |
| Extended Custom  | Extra functions    | `$HOME\Documents\PowerShell\HETFScustom.ps1` |
| Starship Config  | Prompt styling     | `$HOME\.config\starship.toml`                |

---

## DevTools

**DevTools** is a modular, data-driven PowerShell toolkit for **bootstrapping, installing, validating, and managing developer tools** in a reproducible way.

It follows a **bootstrap-first workflow**, allowing execution:

* From a **local clone** for customization
* Directly from **GitHub** with zero setup

Tool definitions are cleanly separated from installer logic, making the system easy to extend, test, and maintain as your toolchain evolves.

---

## Design Goals

DevTools is intentionally designed to be:

* **Bootstrap-driven**
  A minimal loader determines local versus online execution.

* **Declarative**
  Tools describe themselves as data.

* **Scalable**
  Add tools without modifying core logic.

* **CI-safe**
  Runs consistently in local shells, CI pipelines, and automation.

* **Backend-agnostic**
  Supports WinGet, Chocolatey, and GitHub Releases.

---

## DevTools Quick Start (Recommended)

Run DevTools directly from GitHub:

```powershell
iex (irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/DevToolsBootstrap.ps1)
```

This process will:

* Detect a local DevTools checkout if available
* Otherwise execute DevTools directly from GitHub
* Initialize the environment
* Load all tool registries
* Run with safe defaults

No cloning is required.

---

## Local Usage (Optional)

For customization or offline workflows:

```bash
git clone https://github.com/hetfs/powershell-profile.git
cd powershell-profile
```

Run the bootstrap locally:

```powershell
.\DevToolsBootstrap.ps1
```

Or invoke DevTools directly:

```powershell
.\DevTools\DevTools.ps1
```

---

## Supported Tooling

Optional but supported backends:
[Git](https://git-scm.com/)
[Winget](https://learn.microsoft.com/windows/package-manager/winget/)
[Chocolatey](https://chocolatey.org/)
[powershell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)

---

## Acknowledgments

Inspired by the original work of [Chris Titus Tech](https://github.com/ChrisTitusTech/powershell-profile)

Built with and powered by:

* [Zoxide](https://github.com/ajeetdsouza/zoxide)

* [Starship](https://starship.rs/)

* [Nerd Fonts](https://www.nerdfonts.com/)

* [PSReadLine](https://github.com/PowerShell/PSReadLine)

* [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)

---

## Support

* Issues and feature requests:
  [https://github.com/hetfs/powershell-profile/issues](https://github.com/hetfs/powershell-profile/issues)

* Quick help inside PowerShell:

  ```powershell
  Show-Help
  ```

---

<div align="center">

# **Happy PowerShelling.**

</div>

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=hetfs/powershell-profile&type=date&legend=top-left)](https://www.star-history.com/#hetfs/powershell-profile&type=date&legend=top-left)
