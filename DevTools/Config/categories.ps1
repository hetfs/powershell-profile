#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
  DevTools category definitions.

.DESCRIPTION
  Defines all supported DevTools categories with metadata.
  Categories are ordered by Priority and returned as a PSCustomObject.

.OUTPUTS
  PSCustomObject
#>

# ------------------------------------------------------------
# Authoring table (unordered, human-friendly)
# ------------------------------------------------------------

$categoryTable = @{
    CoreShell = @{
        Description = 'Core shells and command-line environments'
        Examples    = @('PowerShell', 'OpenSSH', 'WSL', 'Git Bash')
        Priority    = 10
    }

    Terminals = @{
        Description = 'Terminal emulators and shell hosts'
        Examples    = @('Windows Terminal', 'WezTerm')
        Priority    = 20
    }

    Editors = @{
        Description = 'Editors and IDEs'
        Examples    = @('VS Code', 'Neovim', 'Notepad++')
        Priority    = 30
    }

    Languages = @{
        Description = 'Programming language runtimes and SDKs'
        Examples    = @('Python', 'Node.js', 'Go', 'Rust', 'Java')
        Priority    = 40
    }

    VersionControl = @{
        Description = 'Version control and collaboration tools'
        Examples    = @('Git', 'GitHub CLI', 'lazygit')
        Priority    = 50
    }

    ShellProductivity = @{
        Description = 'Shell productivity and navigation tools'
        Examples    = @('fzf', 'ripgrep', 'fd', 'bat', 'eza')
        Priority    = 60
    }

    PromptUI = @{
        Description = 'Prompt engines and shell UI enhancements'
        Examples    = @('starship', 'Terminal-Icons')
        Priority    = 70
    }

    DataTools = @{
        Description = 'Data processing and database tools'
        Examples    = @('jq', 'yq', 'SQLite', 'PostgreSQL')
        Priority    = 80
    }

    Network = @{
        Description = 'Networking, HTTP, and security tooling'
        Examples    = @('curl', 'wget', 'httpie', 'trivy')
        Priority    = 90
    }

    Multimedia = @{
        Description = 'Audio, video, and image tooling'
        Examples    = @('FFmpeg', 'ImageMagick')
        Priority    = 100
    }

    SystemUtils = @{
        Description = 'System utilities and diagnostics'
        Examples    = @('fastfetch', 'btop', '7zip', 'Sysinternals')
        Priority    = 110
    }

    Containers = @{
        Description = 'Containers and virtualization tooling'
        Examples    = @('Docker', 'Podman', 'Kubernetes')
        Priority    = 120
    }

    CloudInfra = @{
        Description = 'Cloud CLIs and infrastructure tooling'
        Examples    = @('AWS CLI', 'Azure CLI', 'Terraform')
        Priority    = 130
    }

    Security = @{
        Description = 'Security, encryption, and auth tools'
        Examples    = @('OpenSSL', 'GnuPG', 'sops')
        Priority    = 140
    }

    Documentation = @{
        Description = 'Documentation and markup tools'
        Examples    = @('Pandoc', 'Vale', 'Markdown')
        Priority    = 150
    }

    TestingQA = @{
        Description = 'Testing and quality assurance tools'
        Examples    = @('Pester', 'Playwright', 'SonarQube')
        Priority    = 160
    }

    BuildTools = @{
        Description = 'Build systems and package tooling'
        Examples    = @('CMake', 'MSBuild', 'NuGet', 'npm')
        Priority    = 170
    }
}

# ------------------------------------------------------------
# Convert to ordered PSCustomObject (priority-driven)
# ------------------------------------------------------------

$orderedCategories = [ordered]@{}

$categoryTable.GetEnumerator() |
    Sort-Object { $_.Value.Priority } |
    ForEach-Object {
        $orderedCategories[$_.Key] = [PSCustomObject]@{
            Name        = $_.Key
            Description = $_.Value.Description
            Examples    = $_.Value.Examples
            Priority    = $_.Value.Priority
        }
    }

return [PSCustomObject]$orderedCategories
