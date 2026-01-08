# DevTools Guide

## Overview

**DevTools** is a modular, data-driven PowerShell toolkit for **bootstrapping, installing, validating, and managing developer tools** in a reproducible way.

It is built around a **bootstrap-first workflow** that allows DevTools to run:

* From a **local clone** for customization and development
* Directly from **GitHub** with no setup required

DevTools cleanly separates **tool definitions** from **installer logic**, making the system easy to extend, test, and maintain as your toolchain evolves.

---

## Design Goals

DevTools is intentionally designed to be:

* **Bootstrap-driven**—a minimal loader decides local vs online execution
* **Declarative**—tools describe themselves as data
* **Scalable**—add tools without modifying core logic
* **CI-safe**—works in local shells, CI pipelines, and automation
* **Backend-agnostic**—WinGet, Chocolatey, and GitHub Releases supported

---

## Quick Start (Recommended)

Run DevTools directly from GitHub using the bootstrap script:

```powershell
iex (irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/DevToolsBootstrap.ps1)
```

This will:

* Detect a local DevTools checkout if available
* Otherwise fetch and run DevTools from GitHub
* Initialize the environment
* Load all tool registries
* Execute DevTools with safe defaults

No cloning is required.

---

## Local Usage (Optional)

For customization or offline use, clone the repository:

```bash
git clone https://github.com/hetfs/powershell-profile.git
cd powershell-profile
```

Run the bootstrap locally:

```powershell
.\DevToolsBootstrap.ps1
```

You may also invoke DevTools directly:

```powershell
.\DevTools\DevTools.ps1
```

---

## Requirements

Before running DevTools, ensure:

* **PowerShell 7.0 or newer**
* **Windows 10 or 11**
* **Internet access** for downloads

Optional but supported:

* **WinGet**—primary installer backend
  [https://learn.microsoft.com/windows/package-manager/winget/](https://learn.microsoft.com/windows/package-manager/winget/)
* **Chocolatey**—fallback installer
  [https://chocolatey.org/](https://chocolatey.org/)
* **Git**—for source-based workflows

PowerShell installation guide:
[https://learn.microsoft.com/powershell/scripting/install/installing-powershell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)

---

## Architecture Overview

DevTools follows a **bootstrap + controller + registry** architecture.

* The bootstrap decides *where* DevTools runs from
* The controller (`DevTools.ps1`) decides *what* to install
* Registries define *how* tools are installed and validated

```
powershell-profile/
├── DevToolsBootstrap.ps1
├── DevTools/
│   ├── DevTools.ps1
│   ├── Installers/
│   │   ├── Install-Tools.ps1
│   │   ├── WinGet.ps1
│   │   ├── Chocolatey.ps1
│   │   └── GitHubRelease.ps1
│   ├── ToolsRegistry/
│   │   ├── Editors.ps1
│   │   ├── VersionControl.ps1
│   │   ├── Languages.ps1
│   │   ├── Terminals.ps1
│   │   └── SystemUtils.ps1
│   ├── Shared/
│   │   ├── Logging.ps1
│   │   ├── Environment.ps1
│   │   ├── DependencyResolver.ps1
│   │   └── ToolValidator.ps1
│   ├── Config/
│   └── Output/
```

---

## Tool Categories

Tools are grouped logically but installed dynamically.

### Editors

Code editors and IDE tooling.

Examples:

* Neovim
* Visual Studio Code

---

### VersionControl

Source control and collaboration tools.

Examples:

* Git
* GitHub CLI
* lazygit
* delta

---

### Languages

Language runtimes and SDKs.

Examples:

* Node.js
* Python
* Go

---

### Terminals

Terminal emulators and shells.

Examples:

* Windows Terminal
* WezTerm

---

### SystemUtils

System inspection and productivity tools.

Examples:

* fastfetch
* btop
* tldr
* glow
* vale

---

## Installation Workflow

1. Bootstrap determines execution source (local or online)
2. DevTools loads shared modules
3. Tool registries are loaded and normalized
4. Filters are applied (category or tool name)
5. Dependencies are resolved and ordered
6. Installers are selected in priority order:

   1. WinGet
   2. Chocolatey
   3. GitHub Releases
7. Each tool is validated post-install
8. Results are logged and summarized

Example output:

```text
→ Installing Git
✔ Git already installed
→ Installing Neovim
✔ Neovim installed successfully
```

---

## Dry Run Mode

Dry Run simulates the entire process without making changes.

```powershell
.\DevTools\DevTools.ps1 -DryRun
```

This mode is safe for CI, auditing, and planning.

---

## Validation Model

DevTools uses a **generic validation pipeline**.

Each tool defines how it is validated using simple metadata.

Example:

```powershell
BinaryCheck = 'git.exe'
```

Supported validation strategies include:

* Executable present in PATH
* File or directory existence
* Custom PowerShell validation logic

Installer code never contains tool-specific checks.

---

## Summary

DevTools provides a clean, scalable, and automation-friendly way to manage developer environments with PowerShell.

If you value:

* Reproducibility
* Declarative configuration
* CI compatibility
* Minimal bootstrap friction

DevTools is built for that workflow.

Happy building.
