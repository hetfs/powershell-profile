$categoryTools = @{
    'starship' = @{
        DisplayName = 'Starship'
        WinGetId = 'Starship.Starship'
        ChocolateyId = 'starship'
        GitHubRelease = @{
            Owner = 'starship'
            Repo = 'starship'
            AssetPattern = '^starship-.+-x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\Starship"
            AddToPath = "$InstallPath\Starship"
        }
        TestCommand = 'starship --version'
        PostInstall = {
            if (Test-Path "$InstallPath\Starship\starship.exe") {
                try {
                    & "$InstallPath\Starship\starship.exe" init powershell | Out-String | Invoke-Expression
                } catch {
                    Write-Warning "Failed to initialize starship: $_"
                }
            }
        }
    }
    'terminal-icons' = @{
        DisplayName = 'Terminal-Icons'
        WinGetId = $null
        ChocolateyId = 'terminal-icons.powershell'
        GitHubRelease = $null
        TestCommand = 'Get-Module -ListAvailable Terminal-Icons'
        PostInstall = {
            try {
                Install-Module -Name Terminal-Icons -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
            } catch {
                Write-Warning "Failed to install Terminal-Icons module: $_"
            }
        }
    }
}
