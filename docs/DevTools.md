# DevTools Unified Developer Tools Installer

**Version:** 1.0.1
**Author:** HetFS
**Repository:** [https://github.com/hetfs/powershell-profile](https://github.com/hetfs/powershell-profile)

**DevTools** is a **modular, cross-platform, and fully automated PowerShell toolkit** for installing, validating, and managing developer tools. It supports **WinGet**, **Chocolatey**, and **GitHub release-based installations**, and provides **declarative tool definitions**, **dependency resolution**, and **generic validation pipelines**.

---

## ✨ Key Features

* **Single Entry Point:** `DevTools.ps1` orchestrates all installations.
* **Centralized Tool Registry:** All tools defined in `ToolsRegistry/*.ps1` with metadata.
* **Automatic Dependency Resolution:** Tools installed in proper order.
* **Installer Backends:** Priority order — WinGet → Chocolatey → GitHub Releases.
* **Dry-Run Simulation:** Preview installations without changes.
* **Structured Logging:** Info, Success, Warning, and Error messages.
* **Extensible & Modular:** Add new tools, categories, or installers easily.

---

## 🔧 Requirements

* **PowerShell 7.2+**
* **Windows 10/11** (WinGet supported)
* **Internet Access**

Optional:

* **Chocolatey** for fallback installs
* **Git** for source-based installations

---

## 🚀 Installation

### Inline Installation

Run DevTools directly:

```powershell
irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/DevTools/DevTools.ps1 | iex
```

This will:

* Bootstrap DevTools
* Load tool registries
* Validate the environment
* Install missing tools

### Local Installation (Optional)

Clone the repository for offline use or custom modifications:

```bash
git clone https://github.com/hetfs/powershell-profile.git
cd powershell-profile/DevTools
.\DevTools.ps1
```

### -WhatIf Mode

Simulate installation without changing the system:

```powershell
.\DevTools.ps1 -WhatIf

```

### Filtered Installation

Install only selected categories or tools:

```powershell
# Only Terminals and Editors
.\DevTools.ps1 -Category Terminals,Editors

# Specific tools only
.\DevTools.ps1 -ToolName "Git","Neovim","Starship"
```

### Export WinGet Manifest

Generate JSON for WinGet-available tools:

```powershell
.\DevTools.ps1 -ExportWinGetList
```

---

## 🏗️ Architecture Overview

DevTools uses a **bootstrap → controller → registry → installer → validation** model:

* **Bootstrap (`DevToolsBootstrap.ps1`)** Determines execution source (local or online).
* **Controller (`DevTools.ps1`)** Orchestrates filtering, installation, and logging.
* **Tool Registry (`ToolsRegistry/*.ps1`)** Declarative tool definitions including dependencies, installers, and validation.
* **Shared Modules (`Shared/*.ps1`)** Logging, environment checks, dependency resolution, and validation logic.
* **Installers (`Installers/*.ps1`)** Execute installation via WinGet, Chocolatey, or GitHub Releases.

**Project Structure:**

```
DevTools/
├──  Config
│   ├──  categories.ps1
│   └──  defaults.ps1
├──  DevTools.ps1
├──  Installers
│   ├──  Chocolatey.ps1
│   ├──  GitHubRelease.ps1
│   ├──  Install-Tools.ps1
│   └──  WinGet.ps1
├──  Output
│   ├──  DevToolsInstall.log
│   └──  winget-tools.txt
├──  Shared
│   ├──  DependencyResolver.ps1
│   ├──  DocsGenerator.ps1
│   ├──  Environment.ps1
│   ├──  Helpers.ps1
│   ├──  Logging.ps1
│   └──  ToolValidator.ps1
├──  Test-DevTools.ps1
└──  ToolsRegistry
    ├──  BuildTools.ps1
    ├──  CollaborationTools.ps1
    ├──  CoreShell.ps1
    ├──  DataTools.ps1
    ├──  Documentation.ps1
    ├──  Editors.ps1
    ├──  Languages.ps1
    ├──  Multimedia.ps1
    ├──  NetworkToolKit.ps1
    ├──  PromptUI.ps1
    ├──  RemoteAccess.ps1
    ├──  Security.ps1
    ├──  ShellProductivity.ps1
    ├──  SystemUtils.ps1
    ├──  TerminalEmulators.ps1
    └──  VersionControl.ps1
```

---

## 🧩 Tool Categories

| Category           | Description                            | Examples                          |
| ------------------ | -------------------------------------- | --------------------------------- |
| **Editors**        | Code editors & IDEs                    | Neovim, VSCode                    |
| **VersionControl** | Source control & collaboration         | Git, GitHub CLI, lazygit, delta   |
| **Languages**      | Language runtimes & SDKs               | Node.js, Python, Go               |
| **Terminals**      | Terminal emulators & shells            | Windows Terminal, WezTerm         |
| **SystemUtils**    | Productivity & system inspection tools | fastfetch, btop, tldr, glow, vale |

---

## 🛠️ Installation Workflow

1. Bootstrap determines execution source.
2. Shared modules are loaded.
3. Registries are normalized.
4. Filters applied (category/tool name).
5. Dependencies resolved.
6. Installer backend selected (WinGet → Chocolatey → GitHub Releases).
7. Each tool is validated post-install.
8. Results are logged and summarized.

**Example output:**

```text
→ Installing Git
✔ Git already installed
→ Installing Neovim
✔ Neovim installed successfully
```

---

## 🔍 Validation Model

DevTools uses **metadata-driven, installer-agnostic validation** for CLI and GUI tools.

### CLI Tools

```powershell
BinaryCheck = 'git.exe'
Validation = [PSCustomObject]@{
    Type  = 'Command'
    Value = 'git.exe'
}
```

* **Command:** Binary exists in PATH
* **Path:** File or folder exists
* **Script:** Custom PowerShell logic

### GUI Tools

```powershell
BinaryCheck = 'Code.exe'
Validation = [PSCustomObject]@{
    Type  = 'Path'
    Value = @(
        "$env:ProgramFiles\Microsoft VS Code\Code.exe",
        "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"
    )
}
```

* **Path:** Executable or folder exists
* **Shortcut/Start Menu:** Optional
* **Registry (Windows):** Optional

**Notes:**

* Validation is **independent of installer backend**
* Post-install checks confirm success
* Supports CLI, GUI, and hybrid tools

---

## 🔧 Key Commands

| Command                            | Description                       |
| ---------------------------------- | --------------------------------- |
| `.\DevTools.ps1 -DryRun`           | Simulate installations            |
| `.\DevTools.ps1 -Category <cat>`   | Install only specified categories |
| `.\DevTools.ps1 -ToolName <tool>`  | Install only specified tools      |
| `.\DevTools.ps1 -ExportWinGetList` | Export WinGet manifest            |

---

## 🔄 Updates & Maintenance

* DevTools checks for updates to registries and scripts automatically.
* Manual update:

```powershell
# Re-download DevTools scripts
irm https://raw.githubusercontent.com/hetfs/powershell-profile/main/DevTools/DevTools.ps1 | iex
```

* Dry-run recommended before production installation.

---

## ✅ Summary

**DevTools** is a **professional, scalable, reproducible, and automation-friendly toolkit** for developer environments on Windows:

* Declarative tool definitions
* Installer-agnostic workflows
* CI-friendly automation
* Minimal bootstrap friction
