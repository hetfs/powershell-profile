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

# ====================================================
    # Terminal-native | Power users
    # Recommended for SSH environments, servers,
    # and distraction-free workflows.
    # https://distanthought.wordpress.com/2011/01/23/enjoy-weechat-on-windows/
    # ====================================================
    [PSCustomObject]@{
        Name                = 'WeeChat'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'ChatClient'
        WinGetId            = 'weechat.weechat'
        ChocoId             = 'weechat' # Optional fallback
        GitHubRepo          = 'https://github.com/weechat/weechat'
        BinaryCheck         = 'weechat.exe'
        Dependencies        = @()
        Provides            = @('weechat.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'weechat.exe'
        }
    }

