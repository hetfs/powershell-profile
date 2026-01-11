    # ====================================================
    # Development Environments
    # ====================================================

    [PSCustomObject]@{
        Name                = 'WSL'
        Category            = 'CoreShell'
        CategoryDescription = $CategoryDescription
        ToolType            = 'Environment'
        WinGetId            = 'Microsoft.WSL'
        ChocoId             = ''
        GitHubRepo          = 'microsoft/WSL'
        BinaryCheck         = 'wsl.exe'
        Dependencies        = @()
        Provides            = @('wsl.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'wsl.exe'
        }
    }
)
