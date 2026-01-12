# Architecture Overview

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

DevTools uses a **generic validation pipeline** to ensure tools are installed and accessible. Each tool defines how it should be validated using metadata, which can be either **CLI-based** or **GUI/application-based**.

### CLI Tool Validation

Most developer tools are CLI executables. Validation ensures the binary exists and is runnable.

**Example metadata for CLI tools:**

```powershell
# Git CLI
BinaryCheck = 'git.exe'
Validation = [PSCustomObject]@{
    Type  = 'Command'   # Checks for presence in PATH
    Value = 'git.exe'
}

# age encryption tool
BinaryCheck = 'age.exe'
Validation = [PSCustomObject]@{
    Type  = 'Command'   # Uses Get-Command internally
    Value = 'age.exe'
}
```

**Validation methods for CLI tools:**

* **Command:** Checks if the executable is available in the system PATH
* **Path:** Checks for a specific file path on disk
* **Custom Script:** Any PowerShell script logic for advanced verification

---

### GUI Tool Validation

Some developer tools are GUI applications. Validation ensures the **installation folder or executable** exists.

**Example metadata for GUI tools:**

```powershell
# Visual Studio Code
BinaryCheck = 'Code.exe'
Validation = [PSCustomObject]@{
    Type  = 'Path'   # Explicit installation path check
    Value = @(
        "$env:ProgramFiles\Microsoft VS Code\Code.exe",
        "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"
    )
}

# RustDesk
BinaryCheck = 'rustdesk.exe'
Validation = [PSCustomObject]@{
    Type  = 'Path'
    Value = @(
        "$env:ProgramFiles\RustDesk\rustdesk.exe",
        "$env:LocalAppData\Programs\RustDesk\rustdesk.exe"
    )
}
```

**Validation methods for GUI tools:**

* **Path:** Looks for the executable or main application folder
* **Shortcut/Start Menu:** Optional check for shortcuts
* **Registry (Windows):** Optional check for installed applications

---

### Notes

* **Installer-agnostic:** Validation is independent of WinGet, Chocolatey, or GitHub Release installers
* **Post-install check:** Every tool runs validation after installation to confirm success
* **Flexible:** Supports CLI, GUI, and hybrid tools (CLI + optional GUI)

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
