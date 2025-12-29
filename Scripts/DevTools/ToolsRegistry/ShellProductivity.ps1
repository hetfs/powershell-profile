@(
    # ====================================================
    # Shell Productivity & Navigation Tools
    # ====================================================

    [PSCustomObject]@{
        Name        = "fzf"
        Category    = "ShellProductivity"
        WinGetId    = "junegunn.fzf"
        ChocoId     = "fzf"
        GitHubRepo  = "junegunn/fzf"
        BinaryCheck = "fzf.exe"
        Dependencies= @()
        Purpose     = "Fuzzy finder for quick file, directory, and history search"
    },

    [PSCustomObject]@{
        Name        = "zoxide"
        Category    = "ShellProductivity"
        WinGetId    = "ajeetdsouza.zoxide"
        ChocoId     = "zoxide"
        GitHubRepo  = "ajeetdsouza/zoxide"
        BinaryCheck = "zoxide.exe"
        Dependencies= @()
        Purpose     = "Smart directory jumping, replacing 'cd' commands with heuristics"
    },

    [PSCustomObject]@{
        Name        = "fd"
        Category    = "ShellProductivity"
        WinGetId    = "sharkdp.fd"
        ChocoId     = "fd"
        GitHubRepo  = "sharkdp/fd"
        BinaryCheck = "fd.exe"
        Dependencies= @()
        Purpose     = "Fast and user-friendly alternative to 'find'"
    },

    [PSCustomObject]@{
        Name        = "ripgrep"
        Category    = "ShellProductivity"
        WinGetId    = "BurntSushi.ripgrep.MSVC"
        ChocoId     = "ripgrep"
        GitHubRepo  = "BurntSushi/ripgrep"
        BinaryCheck = "rg.exe"
        Dependencies= @()
        Purpose     = "Recursive text search with regex support (like grep)"
    },

    [PSCustomObject]@{
        Name        = "bat"
        Category    = "ShellProductivity"
        WinGetId    = "sharkdp.bat"
        ChocoId     = "bat"
        GitHubRepo  = "sharkdp/bat"
        BinaryCheck = "bat.exe"
        Dependencies= @()
        Purpose     = "Enhanced 'cat' with syntax highlighting"
    },

    [PSCustomObject]@{
        Name        = "eza"
        Category    = "ShellProductivity"
        WinGetId    = "eza-community.eza"
        ChocoId     = "eza"
        GitHubRepo  = "eza-community/eza"
        BinaryCheck = "eza.exe"
        Dependencies= @()
        Purpose     = "Modern 'ls' replacement with colors and icons"
    },

    [PSCustomObject]@{
        Name        = "tre"
        Category    = "ShellProductivity"
        WinGetId    = "tre-command"
        ChocoId     = "tre-command"
        GitHubRepo  = "dduan/tre"
        BinaryCheck = "tre.exe"
        Dependencies= @()
        Purpose     = "Directory tree viewer for quick directory structure visualization"
    }
)
