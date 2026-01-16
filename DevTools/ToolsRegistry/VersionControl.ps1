<#
.SYNOPSIS
    Version control and collaboration tools for DevTools.

.DESCRIPTION
    Defines version control systems, Git tooling, and collaboration CLIs
    supported by DevTools.

    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====================================================
# Category metadata
# ====================================================
$CategoryName        = 'VersionControl'
$CategoryDescription = 'Version control systems, Git tooling, and collaboration CLIs.'

# ====================================================
# Tool definitions
# ====================================================
$Tools = @(

    # ====================================================
    # Git - Core version control system
    # ----------------------------------------------------
    # Distributed VCS for code and content management
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Git'
        Category            = $CategoryName
        ToolType            = 'VCS'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'Git.Git'
        ChocoId             = 'git'
        GitHubRepo          = 'git/git'
        BinaryCheck         = 'git.exe'
        Dependencies        = @()
        Provides            = @('git.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'git.exe'
        }
    }

    # ====================================================
    # LazyGit - Terminal-based Git UI
    # ----------------------------------------------------
    # Interactive TUI for browsing and managing Git repositories
    # ====================================================
    [PSCustomObject]@{
        Name                = 'lazygit'
        Category            = $CategoryName
        ToolType            = 'GitUI'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'JesseDuffield.lazygit'
        ChocoId             = 'lazygit'
        GitHubRepo          = 'jesseduffield/lazygit'
        BinaryCheck         = 'lazygit.exe'
        Dependencies        = @('Git')
        Provides            = @('lazygit.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'lazygit.exe'
        }
    }

    # ====================================================
    # GitHub CLI - Repository and issue management
    # ----------------------------------------------------
    # Manage GitHub repos, issues, pull requests, and actions via CLI
    # ====================================================
    [PSCustomObject]@{
        Name                = 'GitHub CLI'
        Category            = $CategoryName
        ToolType            = 'GitHubCLI'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'GitHub.cli'
        ChocoId             = 'gh'
        GitHubRepo          = 'cli/cli'
        BinaryCheck         = 'gh.exe'
        Dependencies        = @('Git')
        Provides            = @('gh.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'gh.exe'
        }
    }

    # ====================================================
    # Delta - Git diff pager
    # ----------------------------------------------------
    # Syntax-highlighting pager for Git diffs and code review
    # ====================================================
    [PSCustomObject]@{
        Name                = 'delta'
        Category            = $CategoryName
        ToolType            = 'GitDiffPager'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'dandavison.delta'
        ChocoId             = 'delta'
        GitHubRepo          = 'dandavison/delta'
        BinaryCheck         = 'delta.exe'
        Dependencies        = @('Git')
        Provides            = @('delta.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'delta.exe'
        }
    }

    # ====================================================
    # Git-cliff - Changelog generator
    # ----------------------------------------------------
    # Generate changelogs from Git commit history
    # Official docs: https://git-cliff.org/docs/configuration
    # ====================================================
    [PSCustomObject]@{
        Name                = 'git-cliff'
        Category            = $CategoryName
        ToolType            = 'ChangelogGenerator'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'git-cliff.git-cliff'
        ChocoId             = 'git-cliff'
        GitHubRepo          = 'orhun/git-cliff'
        BinaryCheck         = 'git-cliff.exe'
        Dependencies        = @('Git')
        Provides            = @('git-cliff.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'git-cliff.exe'
        }
    }

)

# ====================================================
# Return tools array safely
# ====================================================
@($Tools)
