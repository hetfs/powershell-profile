@(
    # ====================================================
    # Terminal Emulators
    # ====================================================

    [PSCustomObject]@{
        Name        = "WezTerm"
        Category    = "Terminals"
        WinGetId    = "wez.wezterm"
        ChocoId     = "wezterm"
        GitHubRepo  = "wez/wezterm"
        BinaryCheck = "wezterm.exe"
        Dependencies= @()
        Purpose     = "GPU-accelerated, highly configurable terminal emulator for modern workflows"
    },

    [PSCustomObject]@{
        Name        = "Windows Terminal"
        Category    = "Terminals"
        WinGetId    = "Microsoft.WindowsTerminal"
        ChocoId     = "microsoft-windows-terminal"
        GitHubRepo  = "microsoft/terminal"
        BinaryCheck = "wt.exe"
        Dependencies= @()
        Purpose     = "Modern tabbed terminal for Windows supporting PowerShell, CMD, WSL, and Azure Cloud Shell"
    }
)
