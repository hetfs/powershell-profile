$categoryTools = @{
    'httpie' = @{
        DisplayName = 'HTTPie'
        WinGetId = 'httpie.httpie'
        ChocolateyId = 'httpie'
        GitHubRelease = @{
            Owner = 'httpie'
            Repo = 'cli'
            AssetPattern = '^httpie-.+windows-amd64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\HTTPie"
            AddToPath = "$InstallPath\HTTPie"
        }
        TestCommand = 'http --version'
    }
    'httptoolkit' = @{
        DisplayName = 'HTTP Toolkit'
        WinGetId = 'httptoolkit'
        ChocolateyId = $null
        GitHubRelease = $null
        TestCommand = { Test-Path "$env:LocalAppData\Programs\HTTP Toolkit\HTTP Toolkit.exe" }
    }
    'globalping' = @{
        DisplayName = 'Globalping'
        WinGetId = 'jsdelivr.globalping'
        ChocolateyId = 'globalping'
        GitHubRelease = @{
            Owner = 'jsdelivr'
            Repo = 'globalping-cli'
            AssetPattern = '^globalping-windows-amd64\.exe$'
            IsZip = $false
            InstallPath = "$InstallPath\globalping.exe"
            AddToPath = $InstallPath
        }
        TestCommand = 'globalping --version'
    }
    'dog' = @{
        DisplayName = 'dog'
        WinGetId = 'ogham.dog'
        ChocolateyId = 'dog'
        GitHubRelease = @{
            Owner = 'ogham'
            Repo = 'dog'
            AssetPattern = '^dog-.+-x86_64-pc-windows-msvc\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\dog"
            AddToPath = "$InstallPath\dog"
        }
        TestCommand = 'dog --version'
    }
    'trivy' = @{
        DisplayName = 'Trivy'
        WinGetId = 'AquaSecurity.Trivy'
        ChocolateyId = 'trivy'
        GitHubRelease = @{
            Owner = 'aquasecurity'
            Repo = 'trivy'
            AssetPattern = '^trivy_.+_Windows-64bit\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\trivy"
            AddToPath = "$InstallPath\trivy"
        }
        TestCommand = 'trivy --version'
    }
    'step' = @{
        DisplayName = 'Smallstep CLI'
        WinGetId = 'smallstep.step'
        ChocolateyId = 'step-cli'
        GitHubRelease = @{
            Owner = 'smallstep'
            Repo = 'cli'
            AssetPattern = '^step_windows_.+_amd64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\step"
            AddToPath = "$InstallPath\step\bin"
        }
        TestCommand = 'step --version'
    }
}
