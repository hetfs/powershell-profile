<#
.SYNOPSIS
    Shell productivity and navigation tools for efficient command-line workflows.

.DESCRIPTION
    Defines tools for fuzzy searching, directory navigation, file listing,
    terminal file managers, directory trees, and fast text and file inspection.

    Validation strategy:
    - Command validation is used when binaries are reliably added to PATH.
    - Path validation is used when Windows installers are inconsistent.

    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====================================================
# Category metadata
# ====================================================
$CategoryName        = 'ShellProductivity'
$CategoryDescription = 'Productivity and navigation tools for the shell, including fuzzy finders, directory navigators, file utilities, terminal file managers, and directory trees'

# ====================================================
# Tool definitions
# ====================================================
$Tools = @(

    # ====================================================
    # fzf - Fuzzy Finder
    # ----------------------------------------------------
    # Interactive fuzzy search for files, command history,
    # and text streams.
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'fzf.exe'
        }
    }

    # ====================================================
    # zoxide - Directory Navigator
    # ----------------------------------------------------
    # Fast directory jumping with history-based ranking.
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'zoxide.exe'
        }
    }

    # ====================================================
    # fd - File Search Utility
    # ----------------------------------------------------
    # Recursive file search with regex support.
    # Faster and more user-friendly than find.
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'fd.exe'
        }
    }

    # ====================================================
    # ripgrep - Text Search Utility
    # ----------------------------------------------------
    # High-performance recursive text search.
    # Common replacement for grep.
    # ====================================================
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'rg.exe'
        }
    }

    # ====================================================
    # bat - File Preview Utility
    # ----------------------------------------------------
    # Syntax-highlighted file preview with paging support.
    # ====================================================
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'bat.exe'
        }
    }

    # ====================================================
    # eza - Directory Listing Utility
    # ----------------------------------------------------
    # Modern replacement for ls with colors and icons.
    # ====================================================
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'eza.exe'
        }
    }

    # ====================================================
    # lf - Terminal File Manager
    # ----------------------------------------------------
    # Minimal, keyboard-driven file manager for the terminal.
    # ====================================================
    [PSCustomObject]@{
        Name                = 'lf'
        Category            = $CategoryName
        ToolType            = 'FileManager'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'gokcehan.lf'
        ChocoId             = 'lf'
        GitHubRepo          = 'gokcehan/lf'
        BinaryCheck         = 'lf.exe'
        Dependencies        = @()
        Provides            = @('lf.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'lf.exe'
        }
    }

    # ====================================================
    # tre - Directory Tree Viewer
    # ----------------------------------------------------
    # Displays directory trees in a clean, readable format.
    # ====================================================
    [PSCustomObject]@{
        Name                = 'tre'
        Category            = $CategoryName
        ToolType            = 'DirectoryTree'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'tre-command'
        ChocoId             = 'tre-command'
        GitHubRepo          = 'dduan/tre'
        BinaryCheck         = 'tre.exe'
        Dependencies        = @()
        Provides            = @('tre.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:ProgramFiles\tre-command\bin\tre.exe",
                "$env:ProgramFiles(x86)\tre-command\bin\tre.exe"
            )
        }
    }

)

# ====================================================
# Return tools array safely
# ====================================================
@($Tools)
