$categoryTools = @{
    'jq' = @{
        DisplayName    = 'jq'
        WinGetId       = 'jqlang.jq'
        ChocolateyId   = 'jq'
        GitHubRelease  = @{
            Owner        = 'jqlang'
            Repo         = 'jq'
            AssetPattern = '^jq-windows-amd64\.exe$'
            IsZip        = $false
            InstallPath  = Join-Path $InstallPath 'jq.exe'
            AddToPath    = $InstallPath
        }
        TestCommand    = 'jq --version'
        PostInstall    = $null
    }
    'yq' = @{
        DisplayName    = 'yq'
        WinGetId       = 'MikeFarah.yq'
        ChocolateyId   = 'yq'
        GitHubRelease  = @{
            Owner        = 'mikefarah'
            Repo         = 'yq'
            AssetPattern = '^yq_windows_amd64\.exe$'
            IsZip        = $false
            InstallPath  = Join-Path $InstallPath 'yq.exe'
            AddToPath    = $InstallPath
        }
        TestCommand    = 'yq --version'
        PostInstall    = $null
    }
    'ytt' = @{
        DisplayName    = 'ytt'
        WinGetId       = 'Carvel.ytt'
        ChocolateyId   = 'ytt'
        GitHubRelease  = @{
            Owner        = 'carvel-dev'
            Repo         = 'ytt'
            AssetPattern = '^ytt_windows_amd64\.exe$'
            IsZip        = $false
            InstallPath  = Join-Path $InstallPath 'ytt.exe'
            AddToPath    = $InstallPath
        }
        TestCommand    = 'ytt --version'
        PostInstall    = $null
    }
}
