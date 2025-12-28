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
            $exePath = "$InstallPath\Starship\starship.exe"
            if (Test-Path $exePath) {
                Write-Log "Initializing Starship prompt for PowerShell..." -Level INFO
                try {
                    & $exePath init powershell | Out-String | Invoke-Expression
                    Write-Log "Starship prompt initialized successfully" -Level SUCCESS
                } catch {
                    Write-Log "Failed to initialize Starship: $_" -Level WARN
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
            Write-Log "Installing Terminal-Icons PowerShell module..." -Level INFO
            try {
                Install-Module -Name Terminal-Icons -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
                Write-Log "✓ Terminal-Icons module installed successfully" -Level SUCCESS
            } catch {
                Write-Log "Failed to install Terminal-Icons module: $_" -Level WARN
            }
        }
    }
}
