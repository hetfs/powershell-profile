$categoryTools = @{
    'powershell' = @{
        DisplayName    = 'PowerShell Core'
        WinGetId       = 'Microsoft.PowerShell'
        ChocolateyId   = 'powershell-core'
        GitHubRelease  = @{
            Owner        = 'PowerShell'
            Repo         = 'PowerShell'
            AssetPattern = '^PowerShell-.+-win-x64\.msi$'
            IsZip        = $false
            InstallerArgs = @('/quiet','/norestart')
        }
        TestCommand    = 'pwsh --version'
        PostInstall    = {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        }
    }
    'psreadline' = @{
        DisplayName    = 'PSReadLine'
        WinGetId       = 'Microsoft.PowerShell.PSReadLine'
        ChocolateyId   = 'psreadline'
        GitHubRelease  = $null
        TestCommand    = 'Get-Module -ListAvailable PSReadLine'
        PostInstall    = {
            try {
                Install-Module -Name PSReadLine -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
            } catch {
                Write-Warning "Failed to install PSReadLine module: $_"
            }
        }
    }
    'clink' = @{
        DisplayName    = 'Clink'
        WinGetId       = 'chrisant996.Clink'
        ChocolateyId   = 'clink'
        GitHubRelease  = @{
            Owner        = 'chrisant996'
            Repo         = 'clink'
            AssetPattern = '^clink\.zip$'
            IsZip        = $true
            ExtractPath  = Join-Path $InstallPath 'Clink'
            AddToPath    = Join-Path $InstallPath 'Clink'
        }
        TestCommand    = 'clink --version'
        PostInstall    = $null
    }
    'clink-completions' = @{
        DisplayName    = 'Clink Completions'
        WinGetId       = $null
        ChocolateyId   = 'clink-completions'
        GitHubRelease  = @{
            Owner        = 'vladimir-kotikov'
            Repo         = 'clink-completions'
            AssetPattern = '^master\.zip$'
            IsZip        = $true
            ExtractPath  = Join-Path $env:LocalAppData 'clink'
        }
        TestCommand    = { Test-Path (Join-Path $env:LocalAppData 'clink\clink-completions') }
        PostInstall    = {
            $extractedDir = Join-Path $env:LocalAppData 'clink\clink-completions-master'
            $targetDir    = Join-Path $env:LocalAppData 'clink\clink-completions'
            if (Test-Path $extractedDir) {
                if (Test-Path $targetDir) { Remove-Item $targetDir -Recurse -Force -ErrorAction SilentlyContinue }
                Move-Item $extractedDir $targetDir -Force -ErrorAction SilentlyContinue
            }
        }
    }
    'openssh' = @{
        DisplayName    = 'OpenSSH Client'
        WinGetId       = 'Microsoft.OpenSSH'
        ChocolateyId   = 'openssh'
        GitHubRelease  = $null
        TestCommand    = 'ssh -V'
        SkipIf         = { -not $isAdmin }
        PostInstall    = $null
    }
}
