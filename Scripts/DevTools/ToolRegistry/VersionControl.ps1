$categoryTools = @{
    'git' = @{
        DisplayName = 'Git'
        WinGetId = 'Git.Git'
        ChocolateyId = 'git'
        GitHubRelease = @{
            Owner = 'git-for-windows'
            Repo = 'git'
            AssetPattern = '^Git-.+-64-bit\.exe$'
            IsZip = $false
            InstallerArgs = @('/VERYSILENT', '/NORESTART', '/NOCANCEL', '/SP-', '/CLOSEAPPLICATIONS', '/RESTARTAPPLICATIONS')
        }
        TestCommand = 'git --version'
        PostInstall = {
            git config --global --add safe.directory '*'
            git config --global init.defaultBranch main
        }
    }
    'lazygit' = @{
        DisplayName = 'Lazygit'
        WinGetId = 'JesseDuffield.lazygit'
        ChocolateyId = 'lazygit'
        GitHubRelease = @{
            Owner = 'jesseduffield'
            Repo = 'lazygit'
            AssetPattern = '^lazygit_.+_Windows_x86_64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\lazygit"
            AddToPath = "$InstallPath\lazygit"
        }
        TestCommand = 'lazygit --version'
    }
    'gh' = @{
        DisplayName = 'GitHub CLI'
        WinGetId = 'GitHub.cli'
        ChocolateyId = 'gh'
        GitHubRelease = @{
            Owner = 'cli'
            Repo = 'cli'
            AssetPattern = '^gh_.+_windows_amd64\.msi$'
            IsZip = $false
            InstallerArgs = @('/quiet', '/norestart')
        }
        TestCommand = 'gh --version'
    }
    'git-cliff' = @{
        DisplayName = 'git-cliff'
        WinGetId = 'orhun.git-cliff'
        ChocolateyId = $null
        GitHubRelease = @{
            Owner = 'orhun'
            Repo = 'git-cliff'
            AssetPattern = '^git-cliff_.+_x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\git-cliff"
            AddToPath = "$InstallPath\git-cliff"
        }
        TestCommand = 'git-cliff --version'
    }
    'posh-git' = @{
        DisplayName = 'Posh-Git'
        WinGetId = $null
        ChocolateyId = 'poshgit'
        GitHubRelease = $null
        TestCommand = 'Get-Module -ListAvailable posh-git'
        PostInstall = {
            try {
                Install-Module -Name posh-git -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
            } catch {
                Write-Warning "Failed to install posh-git module: $_"
            }
        }
    }
    'delta' = @{
        DisplayName = 'Delta'
        WinGetId = 'dandavison.delta'
        ChocolateyId = 'delta'
        GitHubRelease = @{
            Owner = 'dandavison'
            Repo = 'delta'
            AssetPattern = '^delta-.+-x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\delta"
            AddToPath = "$InstallPath\delta"
        }
        TestCommand = 'delta --version'
    }
}
