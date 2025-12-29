@(
    # ====================================================
    # Version Control & Collaboration Tools
    # ====================================================

    [PSCustomObject]@{
        Name        = "Git"
        Category    = "VersionControl"
        WinGetId    = "Git.Git"
        ChocoId     = "git"
        GitHubRepo  = "git/git"
        BinaryCheck = "git.exe"
        Dependencies= @()
        Purpose     = "Distributed version control system, core for all Git operations"
    },

    [PSCustomObject]@{
        Name        = "lazygit"
        Category    = "VersionControl"
        WinGetId    = "JesseDuffield.lazygit"
        ChocoId     = "lazygit"
        GitHubRepo  = "jesseduffield/lazygit"
        BinaryCheck = "lazygit.exe"
        Dependencies= @()
        Purpose     = "Terminal UI for Git, simplifies staging, commits, and branches"
    },

    [PSCustomObject]@{
        Name        = "GitHub CLI"
        Category    = "VersionControl"
        WinGetId    = "GitHub.cli"
        ChocoId     = "gh"
        GitHubRepo  = "cli/cli"
        BinaryCheck = "gh.exe"
        Dependencies= @()
        Purpose     = "Command-line interface for GitHub, manage repos, issues, PRs"
    },

    [PSCustomObject]@{
        Name        = "delta"
        Category    = "VersionControl"
        WinGetId    = "dandavison.delta"
        ChocoId     = "delta"
        GitHubRepo  = "dandavison/delta"
        BinaryCheck = "delta.exe"
        Dependencies= @()
        Purpose     = "Syntax-highlighting pager for git and diff output"
    }
)
