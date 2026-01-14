# Interpreter Validation on Windows

**Command-Based · Version-Aware · Linted**

This guide defines the **standard, enforced way** to validate interpreters on Windows in DevTools, including **Python, Node.js, Go, and Java**.

It is designed for **modern Windows**, **automation tools** (Winget, Chocolatey), and **multi-version environments**.

---

## Validation Strategies (In Order of Preference)

1. **Command-based validation** (default)
2. **Command-based validation with version constraints** (recommended)
3. **Path-based validation** (restricted and linted)

---

## 1. Command-Based Validation (Default)

### What it is

Validation checks whether an interpreter can be executed by name via `PATH`.

This matches:

* How users invoke tools
* How CI systems work
* How Winget and Chocolatey validate installs

### Example

```powershell
Get-Command python -ErrorAction Stop
python --version
```

### DevTools validation block

```powershell
Validation = @{
    Type  = 'command'
    Value = 'python'
}
```

### Why this is the default

* Works across installers and install scopes
* Survives upgrades
* No hard-coded paths
* Automation-safe
* User-realistic

Use this for **all interpreters and CLIs** unless you have a strong reason not to.

---

## 2. Command-Based Validation with Version Control (Recommended)

Modern systems often have **multiple versions installed side by side**. Validation must express **version intent**, not filesystem locations.

### 2.1 Minimum Version (Most Common)

Ensures an interpreter exists and meets a baseline.

```powershell
Validation = @{
    Type       = 'command'
    Value      = 'python'
    MinVersion = '3.11'
}
```

Benefits:

* Safe with multiple installs
* Prevents accidental use of outdated versions
* Upgrade-friendly

---

### 2.2 Exact Version Using a Launcher (Python Only)

Windows includes `py.exe`, designed for multi-version Python environments.

```powershell
Validation = @{
    Type           = 'command'
    Value          = 'py'
    ExactVersion   = '3.14'
    PreferLauncher = $true
}
```

Use this when:

* Version precision matters
* Preview and stable versions coexist
* PATH order must not decide behavior

---

## 3. Path-Based Validation (Restricted)

### What it is

Checks for a specific executable path on disk.

```powershell
Test-Path "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe"
```

### DevTools block

```powershell
Validation = @{
    Type  = 'path'
    Value = @(
        Join-Path $env:LOCALAPPDATA 'Programs\Python\Python314\python.exe'
    )
}
```

### When it is allowed

Path validation is acceptable **only** when:

* Using embedded or portable runtimes
* Building golden images or offline systems
* The environment is fully controlled
* PATH usage is not desired

### Why it is discouraged

* Breaks on upgrades
* Breaks across users
* Fails with Microsoft Store installs
* High maintenance cost

---

## 4. Interpreter Rule (Lint-Enforced)

> **Interpreters must not use path-based validation.**

If a tool is executed by name, it **must be validated by command**.

DevTools enforces this with a lint rule that blocks:

```powershell
ToolType = 'Interpreter'
Validation.Type = 'path'
```

Failures happen at **load time**, not runtime.

---

## 5. Supported Interpreters

| Interpreter | Command         | Version Flag |
| ----------- | --------------- | ------------ |
| Python      | `python` / `py` | `--version`  |
| Node.js     | `node`          | `--version`  |
| Go          | `go`            | `version`    |
| Java        | `java`          | `-version`   |

All are validated by **command execution**, never by paths.

---

## 6. Recommended Tool Definitions

### Python

```powershell
ToolType   = 'Interpreter'
Validation = @{
    Type           = 'command'
    Value          = 'python'
    MinVersion     = '3.11'
    PreferLauncher = $true
}
```

### Node.js

```powershell
ToolType   = 'Interpreter'
Validation = @{
    Type       = 'command'
    Value      = 'node'
    MinVersion = '18.0'
}
```

### Go

```powershell
ToolType   = 'Interpreter'
Validation = @{
    Type       = 'command'
    Value      = 'go'
    MinVersion = '1.21'
}
```

### Java

```powershell
ToolType   = 'Interpreter'
Validation = @{
    Type       = 'command'
    Value      = 'java'
    MinVersion = '17'
}
```

---

## 7. Optional Hardening

After installation in the same PowerShell session, refresh `PATH` once:

```powershell
$env:Path =
    [Environment]::GetEnvironmentVariable('Path','User') + ';' +
    [Environment]::GetEnvironmentVariable('Path','Machine')
```

This prevents false negatives immediately after install.

---

## Final Rules (Non-Negotiable)

* Default to **command-based validation**
* Use **MinVersion or ExactVersion**, not paths
* Prefer **launchers** where available
* Block path validation for interpreters
* Centralize validation logic
* Fail fast with clear diagnostics

---

## References

* Python on Windows
  [https://learn.microsoft.com/windows/python](https://learn.microsoft.com/windows/python)
* Python Launcher
  [https://docs.python.org/3/using/windows.html#launcher](https://docs.python.org/3/using/windows.html#launcher)
* Winget
  [https://learn.microsoft.com/windows/package-manager/winget](https://learn.microsoft.com/windows/package-manager/winget)
* Node.js
  [https://nodejs.org](https://nodejs.org)
* Go
  [https://go.dev/doc/install](https://go.dev/doc/install)
* Java
  [https://learn.microsoft.com/java/openjdk](https://learn.microsoft.com/java/openjdk)
