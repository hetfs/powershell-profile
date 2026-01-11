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
        # Core shells and CLI environments for local and remote use
        Description = 'Core shells and command-line environments'
        Examples    = @('gsudo', 'OpenSSH', 'ShellCheck', 'direnv', 'mise-en-place', 'aliae')
        Priority    = 10
    }

    TerminalEmulators = @{
        # Terminal emulators for running shells with enhanced UX
        Description = 'Terminal emulators and shell hosts'
        Examples    = @('Windows Terminal', 'WezTerm')
        Priority    = 20
    }

    Editors = @{
        # Text editors and IDEs for code authoring
        Description = 'Editors and IDEs'
        Examples    = @('VS Code', 'Neovim', 'Notepad++')
        Priority    = 30
    }

    Languages = @{
        # Programming language runtimes and SDKs
        Description = 'Programming language runtimes and SDKs'
        Examples    = @('Python', 'Node.js', 'Go', 'Rust', 'Java')
        Priority    = 40
    }

    VersionControl = @{
        # Tools for version control and code collaboration
        Description = 'Version control and collaboration tools'
        Examples    = @('Git', 'GitHub CLI', 'lazygit')
        Priority    = 50
    }

    ShellProductivity = @{
        # CLI productivity and file navigation utilities
        Description = 'Shell productivity and navigation tools'
        Examples    = @('fzf', 'ripgrep', 'fd', 'bat', 'eza')
        Priority    = 60
    }

    PromptUI = @{
        # Shell prompts and UI enhancement engines
        Description = 'Prompt engines and shell UI enhancements'
        Examples    = @('starship', 'Oh my posh')
        Priority    = 70
    }

    DataTools = @{
        # Data processing, transformation, and database tools
        Description = 'Data processing and database tools'
        Examples    = @('jq', 'yq', 'SQLite', 'PostgreSQL')
        Priority    = 80
    }

    NetworkToolKit = @{
        # Networking utilities, HTTP clients, and security scanning
        Description = 'Networking, HTTP, and security tooling'
        Examples    = @('curl', 'wget', 'httpie', 'trivy')
        Priority    = 90
    }

    Multimedia = @{
        # Audio, video, image, and media processing
        Description = 'Audio, video, and image tooling'
        Examples    = @('FFmpeg', 'ImageMagick')
        Priority    = 100
    }

    SystemUtils = @{
        # System utilities, resource monitoring, and archiving
        Description = 'System utilities and diagnostics'
        Examples    = @('fastfetch', 'btop4win', 'Task', 'tar', 'Sysinternals')
        Priority    = 110
    }

    Containers = @{
        # Containerization and virtualization tooling
        Description = 'Containers and virtualization tooling'
        Examples    = @('Docker', 'Podman', 'Kubernetes')
        Priority    = 120
    }

    CloudInfra = @{
        # Cloud infrastructure CLIs and management tools
        Description = 'Cloud CLIs and infrastructure tooling'
        Examples    = @('AWS CLI', 'Azure CLI', 'Terraform')
        Priority    = 130
    }

    Security = @{
        # Secrets management, encryption, and cryptography tooling
        Description = 'Manage Secrets & Protect Sensitive Data, encryption, and auth tools'
        Examples    = @('Vault', 'age','rage', 'OpenSSL', 'GnuPG', 'sops', 'transcrypt')
        Priority    = 140
    }

    Documentation = @{
        # Documentation generation and markup tools
        Description = 'Documentation and markup tools'
        Examples    = @('Pandoc', 'Vale', 'Markdown')
        Priority    = 150
    }

    TestingQA = @{
        # Testing frameworks and QA automation
        Description = 'Testing and quality assurance tools'
        Examples    = @('Pester', 'Playwright', 'SonarQube')
        Priority    = 160
    }

    BuildTools = @{
        # Build automation, package management, and CI/CD helpers
        Description = 'Build systems and package tooling'
        Examples    = @('CMake', 'Ninja', 'MSBuild', 'NuGet', 'npm')
        Priority    = 170
    }

    CollaborationTools = @{
        # Team communication, private & open-source communities, async & real-time
        Description = 'Collaboration and team communication platforms'
        Examples    = @('Discord', 'Slack', 'Mattermost', 'Matrix', 'Zulip')
        Priority    = 180
    }

    RemoteAccess = @{
        # Remote access and cross-platform desktop management
        Description = 'Remote desktop and remote access tools'
        Examples    = @('RustDesk', 'AnyDesk', 'TigerVNC', 'Remmina')
        Priority    = 190
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
