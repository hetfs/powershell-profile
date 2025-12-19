$categoryTools = @{
    'direnv' = @{
        DisplayName = 'direnv'
        WinGetId = 'direnv.direnv'
        ChocolateyId = 'direnv'
        GitHubRelease = @{
            Owner = 'direnv'
            Repo = 'direnv'
            AssetPattern = '^direnv\.windows-amd64\.exe$'
            IsZip = $false
            InstallPath = "$InstallPath\direnv.exe"
            AddToPath = $InstallPath
        }
        TestCommand = 'direnv --version'
    }
    'mise' = @{
        DisplayName = 'mise'
        WinGetId = 'jdx.mise'
        ChocolateyId = 'mise'
        GitHubRelease = @{
            Owner = 'jdx'
            Repo = 'mise'
            AssetPattern = '^mise\.windows\.exe$'
            IsZip = $false
            InstallPath = "$InstallPath\mise.exe"
            AddToPath = $InstallPath
        }
        TestCommand = 'mise --version'
    }
    'aliae' = @{
        DisplayName = 'Aliae'
        WinGetId = 'JanDeDobbeleer.Aliae'
        ChocolateyId = $null
        GitHubRelease = @{
            Owner = 'JanDeDobbeleer'
            Repo = 'aliae'
            AssetPattern = '^aliae_windows_amd64\.exe$'
            IsZip = $false
            InstallPath = "$InstallPath\aliae.exe"
            AddToPath = $InstallPath
        }
        TestCommand = 'aliae --version'
    }
    'fzf' = @{
        DisplayName = 'fzf'
        WinGetId = 'junegunn.fzf'
        ChocolateyId = 'fzf'
        GitHubRelease = @{
            Owner = 'junegunn'
            Repo = 'fzf'
            AssetPattern = '^fzf-.+-windows_amd64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\fzf"
            AddToPath = "$InstallPath\fzf"
        }
        TestCommand = 'fzf --version'
    }
    'zoxide' = @{
        DisplayName = 'zoxide'
        WinGetId = 'ajeetdsouza.zoxide'
        ChocolateyId = 'zoxide'
        GitHubRelease = @{
            Owner = 'ajeetdsouza'
            Repo = 'zoxide'
            AssetPattern = '^zoxide-.+-x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\zoxide"
            AddToPath = "$InstallPath\zoxide"
        }
        TestCommand = 'zoxide --version'
    }
    'fd' = @{
        DisplayName = 'fd'
        WinGetId = 'sharkdp.fd'
        ChocolateyId = 'fd'
        GitHubRelease = @{
            Owner = 'sharkdp'
            Repo = 'fd'
            AssetPattern = '^fd-.+-x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\fd"
            AddToPath = "$InstallPath\fd"
        }
        TestCommand = 'fd --version'
    }
    'ripgrep' = @{
        DisplayName = 'ripgrep'
        WinGetId = 'BurntSushi.ripgrep.MSVC'
        ChocolateyId = 'ripgrep'
        GitHubRelease = @{
            Owner = 'BurntSushi'
            Repo = 'ripgrep'
            AssetPattern = '^ripgrep-.+-x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\ripgrep"
            AddToPath = "$InstallPath\ripgrep"
        }
        TestCommand = 'rg --version'
    }
    'bat' = @{
        DisplayName = 'bat'
        WinGetId = 'sharkdp.bat'
        ChocolateyId = 'bat'
        GitHubRelease = @{
            Owner = 'sharkdp'
            Repo = 'bat'
            AssetPattern = '^bat-.+-x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\bat"
            AddToPath = "$InstallPath\bat"
        }
        TestCommand = 'bat --version'
    }
    'eza' = @{
        DisplayName = 'eza'
        WinGetId = 'eza-community.eza'
        ChocolateyId = 'eza'
        GitHubRelease = @{
            Owner = 'eza-community'
            Repo = 'eza'
            AssetPattern = '^eza-.+-windows-x86_64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\eza"
            AddToPath = "$InstallPath\eza"
        }
        TestCommand = 'eza --version'
    }
    'tre' = @{
        DisplayName = 'tre'
        WinGetId = 'tre-command'
        ChocolateyId = 'tre-command'
        GitHubRelease = @{
            Owner = 'dduan'
            Repo = 'tre'
            AssetPattern = '^tre-.+-windows-x86_64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\tre"
            AddToPath = "$InstallPath\tre"
        }
        TestCommand = 'tre --version'
    }
    'yazi' = @{
        DisplayName = 'yazi'
        WinGetId = 'sxyazi.yazi'
        ChocolateyId = 'yazi'
        GitHubRelease = @{
            Owner = 'sxyazi'
            Repo = 'yazi'
            AssetPattern = '^yazi-.+-x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\yazi"
            AddToPath = "$InstallPath\yazi"
        }
        TestCommand = 'yazi --version'
    }
}
