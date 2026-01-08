<#
.SYNOPSIS
    Shell productivity and navigation tools for efficient command-line workflows.

.DESCRIPTION
    Defines tools for fuzzy searching, directory navigation, file listing,
    and fast text or file inspection.

    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -----------------------------
# Category metadata
# -----------------------------
$CategoryName        = 'ShellProductivity'
$CategoryDescription = 'Productivity and navigation tools for the shell, including fuzzy finders, directory navigators, and file utilities'

# -----------------------------
# Tool definitions
# -----------------------------
$Tools = @(

    # ====================================================
    # Fuzzy Finders
    # ====================================================
    [PSCustomObject]@{
        Name                = 'fzf'
        Category            = $CategoryName
        ToolType            = 'FuzzyFinder'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'junegunn.fzf'
        ChocoId             = 'fzf'
        GitHubRepo          = 'junegunn/fzf'
        BinaryCheck         = 'fzf.exe'
        Dependencies        = @()
        Provides            = @('fzf.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='fzf.exe' }
    }

    # ====================================================
    # Directory Navigation
    # ====================================================
    [PSCustomObject]@{
        Name                = 'zoxide'
        Category            = $CategoryName
        ToolType            = 'DirectoryNavigator'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'ajeetdsouza.zoxide'
        ChocoId             = 'zoxide'
        GitHubRepo          = 'ajeetdsouza/zoxide'
        BinaryCheck         = 'zoxide.exe'
        Dependencies        = @()
        Provides            = @('zoxide.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='zoxide.exe' }
    }

    # ====================================================
    # File and Text Utilities
    # ====================================================
    [PSCustomObject]@{
        Name                = 'fd'
        Category            = $CategoryName
        ToolType            = 'FileSearch'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'sharkdp.fd'
        ChocoId             = 'fd'
        GitHubRepo          = 'sharkdp/fd'
        BinaryCheck         = 'fd.exe'
        Dependencies        = @()
        Provides            = @('fd.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='fd.exe' }
    }

    [PSCustomObject]@{
        Name                = 'ripgrep'
        Category            = $CategoryName
        ToolType            = 'TextSearch'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'BurntSushi.ripgrep.MSVC'
        ChocoId             = 'ripgrep'
        GitHubRepo          = 'BurntSushi/ripgrep'
        BinaryCheck         = 'rg.exe'
        Dependencies        = @()
        Provides            = @('rg.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='rg.exe' }
    }

    [PSCustomObject]@{
        Name                = 'bat'
        Category            = $CategoryName
        ToolType            = 'FilePreview'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'sharkdp.bat'
        ChocoId             = 'bat'
        GitHubRepo          = 'sharkdp/bat'
        BinaryCheck         = 'bat.exe'
        Dependencies        = @()
        Provides            = @('bat.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='bat.exe' }
    }

    [PSCustomObject]@{
        Name                = 'eza'
        Category            = $CategoryName
        ToolType            = 'DirectoryListing'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'eza-community.eza'
        ChocoId             = 'eza'
        GitHubRepo          = 'eza-community/eza'
        BinaryCheck         = 'eza.exe'
        Dependencies        = @()
        Provides            = @('eza.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='eza.exe' }
    }

    # ====================================================
    # Directory Visualization
    # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'tre'
    #     Category            = $CategoryName
    #     ToolType            = 'DirectoryTree'
    #     CategoryDescription = $CategoryDescription
    #     WinGetId            = $null
    #     ChocoId             = 'tre-command'
    #     GitHubRepo          = 'jeffreytse/tre'
    #     BinaryCheck         = 'tre.exe'
    #     Dependencies        = @()
    #     Provides            = @('tre.exe')
    #     Validation          = [PSCustomObject]@{ Type='Command'; Value='tre.exe' }
    # }
)

# -----------------------------
# Return tools array safely
# -----------------------------
@($Tools)
