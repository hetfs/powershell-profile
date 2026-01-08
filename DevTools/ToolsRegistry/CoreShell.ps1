<#
.SYNOPSIS
    Core shell and CLI environments

.DESCRIPTION
    Defines cross-platform shells and core command-line environments.
    Returns a stable array of PSCustomObjects for installers, validators,
    and documentation generators.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====================================================
# Category metadata
# ====================================================
$CategoryName        = 'CoreShell'
$CategoryDescription = 'Cross-platform shells and core command-line environments'

# ====================================================
# Tool definitions
# ====================================================
$Tools = @(

    # ------------------------------------------------
    # PowerShell
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'PowerShell'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Shell'
        WinGetId            = 'Microsoft.PowerShell'
        ChocoId             = ''
        GitHubRepo          = 'https://github.com/PowerShell/PowerShell'
        BinaryCheck         = 'pwsh.exe'
        Dependencies        = @()
        Provides            = @('pwsh.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'pwsh.exe'
        }
    }

    # ------------------------------------------------
    # OpenSSH
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'OpenSSH'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'SSHClient'
        WinGetId            = 'OpenSSH.Client'
        ChocoId             = ''
        GitHubRepo          = 'https://github.com/PowerShell/openssh-portable'
        BinaryCheck         = 'ssh.exe'
        Dependencies        = @()
        Provides            = @('ssh.exe', 'scp.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'ssh.exe'
        }
    }

    # ------------------------------------------------
    # ShellCheck — shell script linting
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'ShellCheck'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Linter'
        WinGetId            = 'koalaman.shellcheck'
        ChocoId             = 'shellcheck'
        GitHubRepo          = 'https://github.com/koalaman/shellcheck'
        BinaryCheck         = 'shellcheck.exe'
        Dependencies        = @()
        Provides            = @('shellcheck.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'shellcheck.exe'
        }
    }

    # ------------------------------------------------
    # direnv
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'direnv'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'ShellProductivity'
        WinGetId            = 'direnv.direnv'
        ChocoId             = 'direnv'
        GitHubRepo          = 'https://github.com/direnv/direnv'
        BinaryCheck         = 'direnv.exe'
        Dependencies        = @()
        Provides            = @('direnv.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'direnv.exe'
        }
    }

    # ------------------------------------------------
    # mise-en-place
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'mise-en-place'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'RuntimeManager'
        WinGetId            = 'jdx.mise'
        ChocoId             = ''
        GitHubRepo          = 'https://github.com/jdx/mise'
        BinaryCheck         = 'mise.exe'
        Dependencies        = @()
        Provides            = @('mise.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'mise.exe'
        }
    }

    # ------------------------------------------------
    # aliae
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'aliae'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'ShellProductivity'
        WinGetId            = 'JanDeDobbeleer.Aliae'
        ChocoId             = ''
        GitHubRepo          = 'https://github.com/JanDeDobbeleer/aliae'
        BinaryCheck         = 'aliae.exe'
        Dependencies        = @()
        Provides            = @('aliae.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'aliae.exe'
        }
    }
)

# ====================================================
# Return tools array safely
# ====================================================
@($Tools)
