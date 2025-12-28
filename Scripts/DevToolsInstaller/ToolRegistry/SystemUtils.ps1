$categoryTools = @{
    'fastfetch' = @{
        DisplayName = 'fastfetch'
        WinGetId = 'fastfetch-cli.fastfetch'
        ChocolateyId = 'fastfetch'
        GitHubRelease = @{
            Owner = 'fastfetch-cli'
            Repo = 'fastfetch'
            AssetPattern = '^fastfetch-.+-windows-x64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\fastfetch"
            AddToPath = "$InstallPath\fastfetch"
        }
        TestCommand = 'fastfetch --version'
    }
    'btop4win' = @{
        DisplayName = 'btop4win'
        WinGetId = 'aristocratos.btop4win'
        ChocolateyId = 'btop4win'
        GitHubRelease = @{
            Owner = 'aristocratos'
            Repo = 'btop4win'
            AssetPattern = '^btop4win-.+-x64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\btop4win"
            AddToPath = "$InstallPath\btop4win"
        }
        TestCommand = 'btop --version'
    }
    'tldr' = @{
        DisplayName = 'tldr'
        WinGetId = 'tldr-pages.tldr'
        ChocolateyId = 'tldr'
        GitHubRelease = @{
            Owner = 'tldr-pages'
            Repo = 'tldr'
            AssetPattern = '^tldr-.+-windows-x86_64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\tldr"
            AddToPath = "$InstallPath\tldr"
        }
        TestCommand = 'tldr --version'
    }
    'glow' = @{
        DisplayName = 'glow'
        WinGetId = 'charmbracelet.glow'
        ChocolateyId = 'glow'
        GitHubRelease = @{
            Owner = 'charmbracelet'
            Repo = 'glow'
            AssetPattern = '^glow_.+_windows_x86_64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\glow"
            AddToPath = "$InstallPath\glow"
        }
        TestCommand = 'glow --version'
    }
    'ag' = @{
        DisplayName = 'Silver Searcher'
        WinGetId = $null
        ChocolateyId = 'ag'
        GitHubRelease = @{
            Owner = 'ggreer'
            Repo = 'the_silver_searcher'
            AssetPattern = '^ag_.+_x64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\ag"
            AddToPath = "$InstallPath\ag"
        }
        TestCommand = 'ag --version'
    }
    'vale' = @{
        DisplayName = 'Vale'
        WinGetId = 'errata-ai.Vale'
        ChocolateyId = 'vale'
        GitHubRelease = @{
            Owner = 'errata-ai'
            Repo = 'vale'
            AssetPattern = '^vale_.+_Windows_64-bit\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\vale"
            AddToPath = "$InstallPath\vale"
        }
        TestCommand = 'vale --version'
    }
    'task' = @{
        DisplayName = 'Task'
        WinGetId = 'GoTask.Task'
        ChocolateyId = 'go-task'
        GitHubRelease = @{
            Owner = 'go-task'
            Repo = 'task'
            AssetPattern = '^task_windows_amd64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\task"
            AddToPath = "$InstallPath\task"
        }
        TestCommand = 'task --version'
    }
}
