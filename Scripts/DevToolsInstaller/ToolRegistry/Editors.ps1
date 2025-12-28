$categoryTools = @{
    # --- YAML/JSON CLI Tools ---
    'jq' = @{
        DisplayName = 'jq'
        WinGetId = 'jqlang.jq'
        ChocolateyId = 'jq'
        GitHubRelease = @{
            Owner = 'jqlang'
            Repo = 'jq'
            AssetPattern = '^jq-windows-amd64\.exe$'
            IsZip = $false
            InstallPath = "$InstallPath\jq.exe"
            AddToPath = $InstallPath
        }
        TestCommand = 'jq --version'
    }
    'yq' = @{
        DisplayName = 'yq'
        WinGetId = 'MikeFarah.yq'
        ChocolateyId = 'yq'
        GitHubRelease = @{
            Owner = 'mikefarah'
            Repo = 'yq'
            AssetPattern = '^yq_windows_amd64\.exe$'
            IsZip = $false
            InstallPath = "$InstallPath\yq.exe"
            AddToPath = $InstallPath
        }
        TestCommand = 'yq --version'
    }
    'ytt' = @{
        DisplayName = 'ytt'
        WinGetId = 'Carvel.ytt'
        ChocolateyId = 'ytt'
        GitHubRelease = @{
            Owner = 'carvel-dev'
            Repo = 'ytt'
            AssetPattern = '^ytt_windows_amd64\.exe$'
            IsZip = $false
            InstallPath = "$InstallPath\ytt.exe"
            AddToPath = $InstallPath
        }
        TestCommand = 'ytt --version'
    }

    # --- Editors ---
    'neovim' = @{
        DisplayName = 'Neovim'
        WinGetId = 'Neovim.Neovim'
        ChocolateyId = 'neovim'
        GitHubRelease = @{
            Owner = 'neovim'
            Repo = 'neovim'
            AssetPattern = '^nvim-win64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\Neovim"
            AddToPath = "$InstallPath\Neovim\bin"
        }
        TestCommand = 'nvim --version'
        PostInstall = {
            $nvimConfig = "$env:LocalAppData\nvim"
            if (-not (Test-Path $nvimConfig)) {
                New-Item -ItemType Directory -Path $nvimConfig -Force | Out-Null
            }
        }
    }

    # --- ShellCheck ---
    'shellcheck' = @{
        DisplayName = 'ShellCheck'
        WinGetId = 'ShellCheck.ShellCheck'
        ChocolateyId = 'shellcheck'
        GitHubRelease = @{
            Owner = 'koalaman'
            Repo = 'shellcheck'
            AssetPattern = '^shellcheck-v\d+\.\d+\.\d+-win64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\ShellCheck"
            AddToPath = "$InstallPath\ShellCheck"
        }
        TestCommand = 'shellcheck --version'
        PostInstall = $null
    }
}
