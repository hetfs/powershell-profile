$categoryTools = @{
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
    'yank-note' = @{
        DisplayName = 'Yank Note'
        WinGetId = 'purocean.YankNote'
        ChocolateyId = $null
        GitHubRelease = $null
        TestCommand = { Test-Path "$env:LocalAppData\Programs\yank-note\Yank Note.exe" }
    }
    'editorconfig-checker' = @{
        DisplayName = 'EditorConfig Checker'
        WinGetId = 'EditorConfig-Checker.EditorConfig-Checker'
        ChocolateyId = $null
        GitHubRelease = @{
            Owner = 'editorconfig-checker'
            Repo = 'editorconfig-checker'
            AssetPattern = '^editorconfig-checker_.+_windows_amd64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\editorconfig-checker"
            AddToPath = "$InstallPath\editorconfig-checker"
        }
        TestCommand = 'editorconfig-checker --version'
    }
    'config-validator' = @{
        DisplayName = 'Config Validator'
        WinGetId = 'Boeing.config-file-validator'
        ChocolateyId = $null
        GitHubRelease = $null
        TestCommand = 'config-file-validator --version'
    }
}
