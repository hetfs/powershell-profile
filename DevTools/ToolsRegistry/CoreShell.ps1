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

[PSCustomObject]@{
    Name                = 'gsudo'
    Category            = 'SystemUtils'
    CategoryDescription = 'Sudo-like privilege elevation for Windows'
    ToolType            = 'PrivilegeElevation'
    WinGetId            = 'gerardog.gsudo'
    ChocoId             = 'gsudo'
    GitHubRepo          = 'https://github.com/gerardog/gsudo'
    BinaryCheck         = Join-Path $env:ProgramFiles 'gsudo\Current\gsudo.exe'
    Dependencies        = @()
    Provides            = @('gsudo.exe')
    Validation          = [PSCustomObject]@{
        Type  = 'Path'
        Value = Join-Path $env:ProgramFiles 'gsudo\Current\gsudo.exe'
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
    # direnv — manage environment variables per directory
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
    # mise-en-place — runtime manager
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'mise-en-place'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'RuntimeManager'
        WinGetId            = 'jdx.mise'
        ChocoId             = $null
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
    # aliae — CLI productivity tool
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'aliae'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'ShellProductivity'
        WinGetId            = 'JanDeDobbeleer.Aliae'
        ChocoId             = $null
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
