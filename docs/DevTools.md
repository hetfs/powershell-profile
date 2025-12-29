# DevTools Guide

## Overview

**DevTools** is a collection of essential tools designed to enhance development productivity, streamline setup processes, and ensure seamless integration across various platforms. This project leverages powerful tools for managing system environments, automating installations, and optimizing workflows.

This guide provides detailed instructions for setting up, configuring, and using **DevTools** to install and manage a wide variety of essential tools for development, from shell utilities to editors and more.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Core Shells & Enhancements](#core-shells--enhancements)
3. [Data & CLI Tools](#data--cli-tools)
4. [Code Editors](#code-editors)
5. [Installation Process](#installation-process)
6. [Contributing](#contributing)
7. [Licenses & Acknowledgments](#licenses--acknowledgments)

---

## Getting Started

### Requirements

Before using **DevTools**, ensure your system meets the following requirements:

* **PowerShell** 7.x or higher.
* **WinGet** (Windows Package Manager).
* **Chocolatey** (optional, for additional tool management).
* **GitHub** access for manual installations if required.

### Installation

1. **Clone the Repository**

   Clone the DevTools repository to your local machine:

   ```bash
   git clone https://github.com/yourusername/DevTools.git
   cd DevTools
   ```

2. **Run the Script**

   To begin the installation process, execute the `DevTools.ps1` script:

   ```powershell
   .\DevTools.ps1
   ```

   This script will automatically begin installing the listed tools.

---

## Core Shells & Enhancements

**DevTools** includes several powerful shells and enhancements designed to improve your command-line experience.

### Tools

* **PowerShell Core**

  * **WinGet ID**: `Microsoft.Powershell`
  * **Purpose**: The core PowerShell terminal with cross-platform support.
* **OpenSSH**

  * **WinGet ID**: `Microsoft.OpenSSH`
  * **Purpose**: Secure Shell (SSH) for remote connections.

### Installation Message

```powershell
Write-Host "→ Installing Core Shells & Enhancements tools..." -ForegroundColor Cyan
```

### Example Tools List

```powershell
@(
    [PSCustomObject]@{
        Name        = "PowerShell"
        Category    = "CoreShell"
        WinGetId    = "Microsoft.Powershell"
        ChocoId     = "powershell-core"
        GitHubRepo  = "PowerShell/PowerShell"
        BinaryCheck = "pwsh.exe"
        PSModule    = $null
        Dependencies= @()
    },

    [PSCustomObject]@{
        Name        = "OpenSSH"
        Category    = "CoreShell"
        WinGetId    = "Microsoft.OpenSSH"
        ChocoId     = "openssh"
        GitHubRepo  = "PowerShell/openssh-portable"
        BinaryCheck = "ssh.exe"
        PSModule    = $null
        Dependencies= @()
    }
)
```

---

## Data & CLI Tools

This category includes essential tools for data processing and command-line usage.

### Tools

* **jq**: Command-line JSON processor.
* **yq**: Command-line YAML processor.
* **ytt**: YAML templating tool for configuration management.
* **Node.js**: JavaScript runtime for scripting and tooling.

### Installation Message

```powershell
Write-Host "→ Installing Data & CLI Tools..." -ForegroundColor Cyan
```

### Example Tools List

```powershell
@(
    [PSCustomObject]@{
        Name        = "jq"
        Category    = "DataTools"
        WinGetId    = "jqlang.jq"
        ChocoId     = "jq"
        GitHubRepo  = "jqlang/jq"
        BinaryCheck = "jq.exe"
        PSModule    = $null
        Dependencies= @()
        Purpose     = "Command-line JSON processor"
    },

    [PSCustomObject]@{
        Name        = "yq"
        Category    = "DataTools"
        WinGetId    = "MikeFarah.yq"
        ChocoId     = "yq"
        GitHubRepo  = "mikefarah/yq"
        BinaryCheck = "yq.exe"
        PSModule    = $null
        Dependencies= @()
        Purpose     = "Command-line YAML processor"
    }
)
```

---

## Code Editors

**DevTools** provides several popular code editors to streamline coding workflows.

### Tools

* **Neovim**: Hyperextensible terminal-based text editor.
* **Vim**: Classic terminal text editor (optional).
* **Visual Studio Code**: Lightweight, extensible, cross-platform code editor (optional).
* **Sublime Text**: Fast, lightweight GUI code editor (optional).

### Installation Message

```powershell
Write-Host "→ Installing Code Editors..." -ForegroundColor Cyan
```

### Example Tools List

```powershell
@(
    [PSCustomObject]@{
        Name        = "Neovim"
        Category    = "Editors"
        WinGetId    = "Neovim.Neovim"
        ChocoId     = "neovim"
        GitHubRepo  = "neovim/neovim"
        BinaryCheck = "nvim.exe"
        PSModule    = $null
        Dependencies= @()
        Purpose     = "Hyperextensible terminal-based text editor"
    }
)
```

---

## Installation Process

### Running the Script

1. **Execute the Main Script**

   After downloading or cloning the repository, navigate to the `Scripts` directory and run the `DevTools.ps1` script to begin the tool installations.

   ```powershell
   .\DevTools.ps1
   ```

2. **Installation Output**

   The script will display messages indicating which tools are being installed. Each tool will be installed through WinGet, Chocolatey, or GitHub, depending on its configuration.

   Example output:

   ```powershell
   → Installing PowerShell Core...
   ✔ PowerShell Core already installed
   ```

3. **Manual Interventions**

   In some cases, tools may require additional configuration or intervention. If this happens, the script will notify you with a warning message.

---

## Contributing

**DevTools** is open-source and contributions are welcome. To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-name`).
5. Open a pull request.

---

## Licenses & Acknowledgments

**DevTools** is licensed under the [MIT License](LICENSE).

We would like to acknowledge the creators of the tools included in this repository, including the maintainers of:

* PowerShell
* jq
* yq
* Neovim
* and many others.

---

## Conclusion

By using **DevTools**, you streamline the process of installing and managing development tools on your machine. Whether you're setting up a fresh environment or enhancing your existing workflow, this guide ensures you can quickly and efficiently access the right tools for the job.

Feel free to explore the various categories, contribute, or adjust the configuration to meet your specific needs. Happy coding!
