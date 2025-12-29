@(
    # ====================================================
    # Prompt, Shell UI & Theming Tools
    # ====================================================

    [PSCustomObject]@{
        Name        = "Starship Prompt"
        Category    = "PromptUI"
        WinGetId    = "Starship.Starship"
        ChocoId     = "starship"
        GitHubRepo  = "starship/starship"
        BinaryCheck = "starship.exe"
        Dependencies= @()
        Purpose     = "Cross-shell prompt with minimal configuration, fast, highly customizable"
    },

    [PSCustomObject]@{
        Name        = "Terminal-Icons"
        Category    = "PromptUI"
        WinGetId    = $null
        ChocoId     = "terminal-icons.powershell"
        GitHubRepo  = "devblackops/Terminal-Icons"
        BinaryCheck = $null
        Dependencies= @()
        Purpose     = "Adds file & folder icons in PowerShell for improved terminal UX"
    }
)
