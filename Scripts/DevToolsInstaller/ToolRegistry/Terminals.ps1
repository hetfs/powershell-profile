$categoryTools = @{
    'wezterm' = @{
        DisplayName = 'WezTerm'
        WinGetId = 'wez.wezterm'
        ChocolateyId = $null
        GitHubRelease = @{
            Owner = 'wez'
            Repo = 'wezterm'
            AssetPattern = '^WezTerm-.+-setup\.exe$'
            IsZip = $false
            InstallerArgs = @('/S')  # Silent install
        }
        TestCommand = 'wezterm --version'
    }
    'windows-terminal' = @{
        DisplayName = 'Windows Terminal'
        WinGetId = 'Microsoft.WindowsTerminal'
        ChocolateyId = 'microsoft-windows-terminal'
        GitHubRelease = $null
        TestCommand = { Test-Path "$env:LocalAppData\Microsoft\WindowsApps\wt.exe" }
    }
}
