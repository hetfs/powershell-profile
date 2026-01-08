# DevTools Guide

## Overview

**DevTools** is a modular, data-driven PowerShell toolkit for installing, validating, and managing essential developer tools across environments.

It is designed to be:

* **Scalable**—add tools without changing installer logic
* **Declarative**—tools define themselves
* **CI-friendly**—works locally, in CI, and GitHub Actions
* **Cross-platform aware**—WinGet, Chocolatey, and GitHub fallback support

DevTools separates **tool data** from **installer logic**, making it easy to maintain and extend as your toolchain grows.

---

## Quick Install (Inline)

Run DevTools directly without cloning the repository:

```powershell
irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/DevTools/DevTools.ps1 | iex
```

This will:

* Bootstrap DevTools
* Load all category registries
* Validate the environment
* Install missing tools using the best available provider

---

## Requirements

Before running DevTools, ensure:

* **PowerShell 7.2+**
* **Windows 10/11** (WinGet supported)
* **Internet access**
* Optional:

  * **Chocolatey** (fallback installer)
  * **Git** (for source-based installs)

PowerShell install:
[https://learn.microsoft.com/powershell/scripting/install/installing-powershell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)

---

## Getting Started

### Clone (Optional)

If you prefer local execution or customization:

```bash
git clone https://github.com/hetfs/powershell-profile.git
cd powershell-profile/DevTools
```

Run DevTools:

```powershell
.\DevTools.ps1 -Install
```

---

## Architecture Overview

DevTools follows a **CoreShell/DataTools architecture**:

* **Installer logic** is generic and never tool-specific
* **Each tool is declarative**
* **Validation is data-driven**

```
DevTools/
├── DevTools.ps1
├── Config/
│   └── Categories.ps1
├── Shared/
│   ├── Logging.ps1
│   ├── Validation.ps1
│   └── Schema.ps1
├── ToolsRegistry/
│   ├── CoreShell.ps1
│   ├── ShellProductivity.ps1
│   ├── DataTools.ps1
│   ├── Network.ps1
│   ├── SystemUtils.ps1
│   ├── Terminals.ps1
│   └── VersionControl.ps1
```

---

## Tool Categories

### CoreShell

Core shell environments and UX foundations.

Examples:

* PowerShell
* OpenSSH
* Starship
* Terminal Icons

---

### ShellProductivity

Navigation, search, and terminal efficiency tools.

Examples:

* fzf
* zoxide
* bat
* ripgrep
* eza

---

### DataTools

Data inspection and processing CLIs.

Examples:

* jq
* yq
* ytt
* Node.js

---

### Network

Networking, diagnostics, and security tooling.

Examples:

* curl
* wget
* httpie
* trivy
* globalping

---

### SystemUtils

System inspection, automation, and documentation tools.

Examples:

* fastfetch
* btop
* tldr
* glow
* task
* vale

---

### Terminals

Terminal emulators and shells.

Examples:

* Windows Terminal
* WezTerm

---

### VersionControl

Source control and collaboration tooling.

Examples:

* Git
* GitHub CLI
* lazygit
* delta

---

## Installation Process

1. DevTools loads all category registry files.
2. Each tool is normalized and schema-validated.
3. Installers are selected in priority order:

   1. WinGet
   2. Chocolatey
   3. GitHub releases
4. Post-install validation runs automatically.

Example output:

```text
→ Installing Git
✔ Git already installed
→ Installing lazygit
✔ lazygit installed successfully
```

---

## Validation Model

DevTools uses a **generic validation pipeline**.

Each tool defines its own validation:

```powershell
Validation = @{
    Type  = 'Command'
    Value = 'git.exe'
}
```

Supported validation types:

* `Command`—binary available in PATH
* `Path`—file or directory exists
* `Script`—custom PowerShell validation

The installer never contains tool-specific logic.

---

## Conclusion

DevTools provides a clean, scalable, and professional way to manage developer environments using PowerShell.

If you value:

* Reproducibility
* Declarative configuration
* CI compatibility
* Zero hard-coded logic

DevTools is built for you.

Happy hacking.
