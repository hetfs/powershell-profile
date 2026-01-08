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

# -----------------------------
# Category metadata
# -----------------------------
$CategoryName        = 'VersionControl'
$CategoryDescription = 'Version control systems, Git tooling, and collaboration CLIs.'

# -----------------------------
# Tool definitions
# -----------------------------
$Tools = @(

    # ====================================================
    # Core Version Control Systems
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Git'
        Category            = $CategoryName
        ToolType            = 'VCS'
        CategoryDescription = 'Distributed version control system for code and content.'
        WinGetId            = 'Git.Git'
        ChocoId             = 'git'
        GitHubRepo          = 'git/git'
        BinaryCheck         = 'git.exe'
        Dependencies        = @()
        Provides            = @('git.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='git.exe' }
    }

    # ====================================================
    # Terminal UIs for Git
    # ====================================================
    [PSCustomObject]@{
        Name                = 'lazygit'
        Category            = $CategoryName
        ToolType            = 'GitUI'
        CategoryDescription = 'Terminal-based UI for Git repositories.'
        WinGetId            = 'JesseDuffield.lazygit'
        ChocoId             = 'lazygit'
        GitHubRepo          = 'jesseduffield/lazygit'
        BinaryCheck         = 'lazygit.exe'
        Dependencies        = @('Git')
        Provides            = @('lazygit.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='lazygit.exe' }
    }

    # ====================================================
    # GitHub CLI tooling
    # ====================================================
    [PSCustomObject]@{
        Name                = 'GitHub CLI'
        Category            = $CategoryName
        ToolType            = 'GitHubCLI'
        CategoryDescription = 'Manage GitHub repositories, issues, and pull requests from CLI.'
        WinGetId            = 'GitHub.cli'
        ChocoId             = 'gh'
        GitHubRepo          = 'cli/cli'
        BinaryCheck         = 'gh.exe'
        Dependencies        = @('Git')
        Provides            = @('gh.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='gh.exe' }
    }

    # ====================================================
    # Git Diff & Pager Tools
    # ====================================================
    [PSCustomObject]@{
        Name                = 'delta'
        Category            = $CategoryName
        ToolType            = 'GitDiffPager'
        CategoryDescription = 'Syntax-highlighting pager for Git diffs and code review.'
        WinGetId            = 'dandavison.delta'
        ChocoId             = 'delta'
        GitHubRepo          = 'dandavison/delta'
        BinaryCheck         = 'delta.exe'
        Dependencies        = @('Git')
        Provides            = @('delta.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='delta.exe' }
    }
)

# -----------------------------
# Return tools array safely for dot-sourcing
# -----------------------------
@($Tools)
