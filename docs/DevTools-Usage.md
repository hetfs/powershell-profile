# DevTools Usage

DevTools supports multiple execution modes to install tools, preview actions, validate configuration, export state, and bootstrap remotely.

---

## Basic Execution

```powershell
.\DevTools.ps1
```

**What it does**

* Loads all tool registries
* Resolves dependencies
* Installs missing tools
* Validates each tool after installation

**Use when**

* Provisioning a new machine
* Performing a full environment setup

---

## PowerShell WhatIf Mode

```powershell
.\DevTools.ps1 -WhatIf
```

**What it does**

* Enables PowerShell’s native `WhatIf` behavior
* Shows intended actions for commands that support `ShouldProcess`
* May not fully prevent external installers from running

**Use when**

* Debugging execution flow
* Inspecting high-level behavior

---

## Execution Plan Only

```powershell
.\DevTools.ps1 -Plan
```

**What it does**

* Builds and displays the complete installation plan
* Includes:

  * Selected tools
  * Dependency graph
  * Installer selection
* Makes **no system changes**

**Use when**

* Auditing toolchains
* Reviewing changes before installation
* Documentation and approvals

---

## Verbose WhatIf Mode

```powershell
.\DevTools.ps1 -WhatIf -Verbose
```

**What it does**

* Combines `WhatIf` with detailed diagnostic output
* Displays registry loading, filtering, and decision logic

**Use when**

* Deep troubleshooting
* Registry or installer development

---

## Export Installed Tools (WinGet)

```powershell
.\DevTools.ps1 -ExportWinGetList
# export in DevTools/Output
```

**What it does**

* Exports currently installed WinGet-managed tools
* Generates a WinGet-compatible export file
* Can be used to recreate the same environment on another machine

**Use when**

* Backing up your toolchain
* Migrating to a new system
* Sharing reproducible environments

---

## Test Mode

```powershell
.\Test-DevTools.ps1
```

**What it does**

* Runs internal validation and integrity checks
* Verifies:

  * Registry schema
  * Dependency resolution
  * Installer availability
  * Validation logic

**Use when**

* CI pipelines
* After modifying registries or installers
* Before merging changes

---

## Bootstrap Execution

```powershell
.\DevToolsBootstrap.ps1
```

**What it does**

* Determines whether DevTools runs locally or remotely
* Fetches DevTools if not already present
* Forwards all arguments to `DevTools.ps1`

**Use when**

* First-time setup
* Inline execution (`irm | iex`)
* Automated provisioning

---

## Category-Scoped Installation

```powershell
.\DevTools.ps1 -Category Terminals
```

**What it does**

* Installs tools only from the specified category
* Automatically includes required dependencies

**Use when**

* Minimal or role-based setups
* Focused environment provisioning

---

## Tool-Scoped Installation

```powershell
.\DevTools.ps1 -Tools git,neovim
```

**What it does**

* Installs only the specified tools
* Resolves and installs dependencies as needed
* Skips unrelated categories

**Use when**

* Targeted installs
* Fast updates
* Workflow-specific tooling

---

## Summary of Available Commands

| Command                   | Purpose                 |
| ------------------------- | ----------------------- |
| `.\DevTools.ps1`          | Full installation       |
| `-WhatIf`                 | Preview execution       |
| `-Plan`                   | Show install plan only  |
| `-WhatIf -Verbose`        | Debug execution         |
| `-ExportWinGetList`       | Export WinGet tool list |
| `-Category <name>`        | Install by category     |
| `-Tools <list>`           | Install specific tools  |
| `.\Test-DevTools.ps1`     | Validate DevTools       |
| `.\DevToolsBootstrap.ps1` | Bootstrap execution     |
