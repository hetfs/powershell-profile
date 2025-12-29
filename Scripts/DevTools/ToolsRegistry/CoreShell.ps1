@(
    # ====================================================
    # Core Shells & Enhancements
    # ====================================================

    # ----------------------
    # PowerShell Core
    # ----------------------
    [PSCustomObject]@{
        Name        = "PowerShell"
        Category    = "CoreShell"
        WinGetId    = "Microsoft.Powershell"         # Correct WinGet ID for PowerShell Core
        ChocoId     = "powershell-core"
        GitHubRepo  = "PowerShell/PowerShell"
        BinaryCheck = "pwsh.exe"
        Dependencies= @()
        Purpose     = "Cross-platform shell and scripting environment"
    },

    # ----------------------
    # OpenSSH Client
    # ----------------------
    [PSCustomObject]@{
        Name        = "OpenSSH"
        Category    = "CoreShell"
        WinGetId    = "Microsoft.OpenSSH"     # Correct WinGet ID for OpenSSH
        ChocoId     = "openssh"
        GitHubRepo  = "PowerShell/openssh-portable"
        BinaryCheck = "ssh.exe"
        Dependencies= @()
        Purpose     = "Open source implementation of the SSH protocol"
    },

    # ====================================================
    # Shell Productivity Tools
    # ====================================================
    [PSCustomObject]@{
        Name        = "direnv"
        Category    = "CoreShell"
        WinGetId    = "direnv.direnv"
        ChocoId     = "direnv"
        GitHubRepo  = "direnv/direnv"
        BinaryCheck = "direnv.exe"
        Dependencies= @()
        Purpose     = "Per-directory environment variable management"
    },

    [PSCustomObject]@{
        Name        = "mise-en-place"
        Category    = "CoreShell"
        WinGetId    = "jdx.mise"
        ChocoId     = $null                 # Chocolatey version is currently outdated
        GitHubRepo  = "jdx/mise"
        BinaryCheck = "mise.exe"
        Dependencies= @()
        Purpose     = "Toolchain and runtime manager"
    },

    [PSCustomObject]@{
        Name        = "aliae"
        Category    = "CoreShell"
        WinGetId    = "JanDeDobbeleer.Aliae"
        ChocoId     = $null
        GitHubRepo  = "JanDeDobbeleer/aliae"
        BinaryCheck = "aliae.exe"
        Dependencies= @()
        Purpose     = "Alias management for shell"
    }
)
