$categoryTools = @{
    'rust' = @{
        DisplayName = 'Rust'
        WinGetId = 'Rustlang.Rustup'
        ChocolateyId = 'rustup.install'
        GitHubRelease = @{
            Owner = 'rust-lang'
            Repo = 'rustup'
            AssetPattern = '^rustup-init\.exe$'
            IsZip = $false
            InstallerArgs = @('-y')
        }
        TestCommand = 'rustc --version'
    }
    'go' = @{
        DisplayName = 'Go'
        WinGetId = 'GoLang.Go'
        ChocolateyId = 'golang'
        GitHubRelease = @{
            Owner = 'golang'
            Repo = 'go'
            AssetPattern = '^go.+windows-amd64\.msi$'
            IsZip = $false
            InstallerArgs = @('/quiet', '/norestart')
        }
        TestCommand = 'go version'
    }
    'python' = @{
        DisplayName = 'Python'
        WinGetId = 'Python.Python.3'
        ChocolateyId = 'python'
        GitHubRelease = $null
        TestCommand = 'python --version'
        SkipIf = { $isAdmin -eq $false }
    }
    'lua' = @{
        DisplayName = 'Lua'
        WinGetId = 'DEVCOM.Lua'
        ChocolateyId = $null
        GitHubRelease = @{
            Owner = 'lua'
            Repo = 'lua'
            AssetPattern = '^lua-.+_Win64_bin\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\Lua"
            AddToPath = "$InstallPath\Lua"
        }
        TestCommand = 'lua -v'
    }
    'lua-language-server' = @{
        DisplayName = 'Lua Language Server'
        WinGetId = 'LuaLS.lua-language-server'
        ChocolateyId = $null
        GitHubRelease = @{
            Owner = 'LuaLS'
            Repo = 'lua-language-server'
            AssetPattern = '^lua-language-server-.+-win32-x64\.zip$'
            IsZip = $true
            ExtractPath = "$InstallPath\lua-language-server"
            AddToPath = "$InstallPath\lua-language-server"
        }
        TestCommand = 'lua-language-server --version'
    }
    'perl' = @{
        DisplayName = 'Perl'
        WinGetId = $null
        ChocolateyId = 'strawberryperl'
        GitHubRelease = $null
        TestCommand = 'perl --version'
    }
}
