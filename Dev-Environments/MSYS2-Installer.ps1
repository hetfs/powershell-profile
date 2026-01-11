
    # ====================================================
    # Development Environments
    # ====================================================
    [PSCustomObject]@{
        Name                = 'MSYS2 Installer '
        Category            = 'CoreShell'
        CategoryDescription = $CategoryDescription
        ToolType            = 'Environment'
        WinGetId            = 'MSYS2.MSYS2'
        ChocoId             = 'msys2'
        GitHubRepo          = 'msys2/msys2-installer'
        BinaryCheck         = 'msys2_shell.cmd'
        Dependencies        = @()
        Provides            = @('bash.exe','gcc.exe','make.exe','gdb.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'msys2_shell.cmd'
        }
    }
