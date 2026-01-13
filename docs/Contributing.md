# 🤝 Contributing Guide

Thank you for your interest in contributing to **PowerShell Profile & DevTools** 🎉
This project delivers a **clean, modular, reproducible, and professional PowerShell environment** for developers.

We welcome all contributions—code, documentation, ideas, and bug reports.

---

## Development Guidelines

1. **Maintain Override System** Always support `_Override` functions.
2. **Error Handling** Include `try/catch` blocks for robustness.
3. **Documentation** Comment code and update help text.
4. **Backward Compatibility** Avoid breaking existing functionality.
5. **Testing** Verify changes in both Windows PowerShell and PowerShell 7+.

---

## Module Structure Principles

* **Single Responsibility** Each section handles a single concern.
* **Clear Dependencies** Document load order and dependencies.
* **Override Support** Always allow safe user customization.
* **Error Resilience** Fail gracefully with helpful messages.

---

## 📌 Project Scope

This repository provides:

* A **modular PowerShell profile**
* **DevTools**, a data-driven tool installer and validator
* Cross-platform awareness (Windows-first, Linux/macOS friendly)
* CI-safe and non-interactive execution
* No hardcoded users, paths, or machine-specific assumptions

---

## 🧭 Ways to Contribute

You can contribute by:

* Fixing bugs
* Adding new tools to DevTools
* Improving validation logic (CLI or GUI)
* Enhancing documentation
* Refactoring for clarity or reliability
* Reporting issues or proposing features

---

## 🛠 Development Requirements

### Required

* **PowerShell 7+**
* **Git**
* Windows (for full DevTools testing)

### Optional but Recommended

* WinGet
* Chocolatey
* GitHub CLI
* VS Code or Neovim

---

## 📁 Repository Structure (Simplified)

```
powershell-profile/
├── DevTools/
│   ├── DevTools.ps1
│   ├── DevToolsBootstrap.ps1
│   ├── Shared/
│   ├── Config/
│   ├── Installers/
│   └── ToolsRegistry/
├── Profile/
├── docs/CONTRIBUTING.md
├── setprofile.ps1
├── setup.ps1
└── README.md
```

---

## ➕ Adding a New Tool (DevTools)

All tools must be defined as **pure data objects**.

### Rules

* No logic inside tool definitions
* No hardcoded usernames or absolute paths
* Validation must be explicit and reliable

### Example Tool Definition

```powershell
[PSCustomObject]@{
    Name                = 'ExampleTool'
    Category            = 'Core'
    CategoryDescription = 'Essential developer tools'
    ToolType            = 'CLI'
    WinGetId            = 'Vendor.ExampleTool'
    ChocoId             = 'exampletool'
    GitHubRepo          = 'vendor/exampletool'
    BinaryCheck         = 'example.exe'
    Dependencies        = @()
    Provides            = @('example.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Command'
        Value = 'example.exe'
    }
}
```

---

## ✅ Validation Model

DevTools supports **CLI and GUI validation**, as well as informational entries.

### CLI Validation

```powershell
Validation = @{
    Type  = 'Command'
    Value = 'git.exe'
}
```

### GUI Validation (Path-based)

```powershell
Validation = @{
    Type  = 'Path'
    Value = @(
        "$env:ProgramFiles\App\App.exe",
        "$env:LOCALAPPDATA\App\App.exe"
    )
}
```

### Informational (Non-installable on Windows)

```powershell
Validation = @{
    Type  = 'Info'
    Value = 'Linux-only service'
}
```

---

## 🚫 What Not to Do

❌ Do not hardcode:

* `C:\Users\Username`
* Machine-specific paths
* Personal preferences

❌ Do not:

* Embed install logic in tool definitions
* Break backward compatibility without discussion
* Introduce silent breaking changes

---

## 🧪 Testing Your Changes

Before submitting:

```powershell
.\DevTools\Test-DevTools.ps1
```

Ensure:

* No validation failures
* All directories exist
* No uncaught exceptions
* Clean logs

---

## 🧾 Commit Guidelines

Use **clear, conventional commits**:

```
feat: add RustDesk remote access tool
fix: correct HexChat GUI validation path
docs: improve DevTools validation guide
refactor: simplify bootstrap source detection
```

---

## 🔁 Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a pull request to `main`
5. Include in your description:

   * What you changed
   * Why it matters
   * How it was tested

---

## 🐞 Reporting Issues

Include the following when opening an issue:

* PowerShell version
* OS version
* Command used
* Full error message
* Relevant logs (if available)

👉 Issues: [https://github.com/hetfs/powershell-profile/issues](https://github.com/hetfs/powershell-profile/issues)

---

## 📐 Design Principles

This project follows:

* **Declarative over imperative**
* **Data-driven, not script-driven**
* **Safe by default**
* **CI-first**
* **Readable over clever**

---

## 📜 License

By contributing, you agree that your contributions are licensed under the project’s existing license.

---

## 🙌 Thank You

Every contribution small or large helps improve this project.
We appreciate your time, expertise, and feedback.

**Happy hacking 🚀**
