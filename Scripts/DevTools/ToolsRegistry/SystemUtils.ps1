@(
    # ====================================================
    # System Utilities & Information Tools
    # ====================================================

    [PSCustomObject]@{
        Name        = "fastfetch"
        Category    = "SystemUtils"
        WinGetId    = "fastfetch-cli.fastfetch"
        ChocoId     = "fastfetch"
        GitHubRepo  = "fastfetch-cli/fastfetch"
        BinaryCheck = "fastfetch.exe"
        Dependencies= @()
        Purpose     = "Fast system information fetcher for terminal overview"
    },

    [PSCustomObject]@{
        Name        = "btop4win"
        Category    = "SystemUtils"
        WinGetId    = "aristocratos.btop4win"
        ChocoId     = "btop4win"
        GitHubRepo  = "aristocratos/btop4win"
        BinaryCheck = "btop.exe"
        Dependencies= @()
        Purpose     = "Resource monitor, improved over top/htop for Windows"
    },

    [PSCustomObject]@{
        Name        = "tldr"
        Category    = "SystemUtils"
        WinGetId    = "tldr-pages.tldr"
        ChocoId     = "tldr"
        GitHubRepo  = "tldr-pages/tldr"
        BinaryCheck = "tldr.exe"
        Dependencies= @()
        Purpose     = "Simplified man pages for common commands"
    },

    [PSCustomObject]@{
        Name        = "glow"
        Category    = "SystemUtils"
        WinGetId    = "charmbracelet.glow"
        ChocoId     = "glow"
        GitHubRepo  = "charmbracelet/glow"
        BinaryCheck = "glow.exe"
        Dependencies= @()
        Purpose     = "Markdown rendering directly in terminal"
    },

    [PSCustomObject]@{
        Name        = "Vale"
        Category    = "SystemUtils"
        WinGetId    = "errata-ai.Vale"
        ChocoId     = "vale"
        GitHubRepo  = "errata-ai/vale"
        BinaryCheck = "vale.exe"
        Dependencies= @()
        Purpose     = "Linting for prose, Markdown, and docs"
    },

    [PSCustomObject]@{
        Name        = "Task"
        Category    = "SystemUtils"
        WinGetId    = "GoTask.Task"
        ChocoId     = "go-task"
        GitHubRepo  = "go-task/task"
        BinaryCheck = "task.exe"
        Dependencies= @()
        Purpose     = "Task runner for build, CI/CD, automation tasks"
    },

    [PSCustomObject]@{
        Name        = "Silver Searcher (ag)"
        Category    = "SystemUtils"
        WinGetId    = "The Silver Searcher"
        ChocoId     = "ag"
        GitHubRepo  = "ggreer/the_silver_searcher"
        BinaryCheck = "ag.exe"
        Dependencies= @()
        Purpose     = "Ultra-fast code search, alternative to grep"
    },

    [PSCustomObject]@{
        Name        = "tar"
        Category    = "SystemUtils"
        WinGetId    = "GnuWin32.Tar"
        ChocoId     = "tar"
        GitHubRepo  = "GnuWin32/wget"  # Placeholder repo for Windows tar binaries
        BinaryCheck = "tar.exe"
        Dependencies= @()
        Purpose     = "File archiving and extraction (tarballs)"
    },

    [PSCustomObject]@{
        Name        = "unzip"
        Category    = "SystemUtils"
        WinGetId    = "GnuWin32.Unzip"
        ChocoId     = "unzip"
        GitHubRepo  = "GnuWin32/unzip"
        BinaryCheck = "unzip.exe"
        Dependencies= @()
        Purpose     = "Extract files from zip archives"
    }
)
