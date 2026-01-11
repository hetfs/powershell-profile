<#
.SYNOPSIS
    System utilities, search, automation, and archiving tools.

.DESCRIPTION
    Defines system information fetchers, CLI helpers, automation tools,
    search utilities, and archive/compression tools.

    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -----------------------------
# Category metadata
# -----------------------------
$CategoryName        = 'SystemUtils'
$CategoryDescription = 'System utilities, diagnostics, automation, and archiving tools.'

# -----------------------------
# Tool definitions
# -----------------------------
$Tools = @(

    # ====================================================
    # System Information
    # ====================================================
    [PSCustomObject]@{
        Name                = 'fastfetch'
        Category            = $CategoryName
        ToolType            = 'SystemInfo'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'fastfetch-cli.fastfetch'
        ChocoId             = 'fastfetch'
        GitHubRepo          = 'fastfetch-cli/fastfetch'
        BinaryCheck         = 'fastfetch.exe'
        Dependencies        = @()
        Provides            = @('fastfetch.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='fastfetch.exe' }
    }

    [PSCustomObject]@{
        Name                = 'btop4win'
        Category            = $CategoryName
        ToolType            = 'ResourceMonitor'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'aristocratos.btop4win'
        ChocoId             = 'btop4win'
        GitHubRepo          = 'aristocratos/btop'
        BinaryCheck         = 'btop.exe'
        Dependencies        = @()
        Provides            = @('btop.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='btop.exe' }
    }

    # ====================================================
    # Archiving & Compression
    # ====================================================
    [PSCustomObject]@{
        Name                = 'tar'
        Category            = $CategoryName
        ToolType            = 'Archiver'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'GnuWin32.Tar'
        ChocoId             = 'tar'
        GitHubRepo          = 'libarchive/libarchive'
        BinaryCheck         = 'tar.exe'
        Dependencies        = @()
        Provides            = @('tar.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='tar.exe' }
    }


    # ====================================================
    # Task & Automation
    # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'Task'
    #     Category            = $CategoryName
    #     ToolType            = 'TaskRunner'
    #     CategoryDescription = $CategoryDescription
    #     WinGetId            = 'GoTask.Task'
    #     ChocoId             = 'go-task'
    #     GitHubRepo          = 'go-task/task'
    #     BinaryCheck         = 'task.exe'
    #     Dependencies        = @()
    #     Provides            = @('task.exe')
    #     Validation          = [PSCustomObject]@{ Type='Command'; Value='task.exe' }
    # }

    # [PSCustomObject]@{
    #     Name                = 'unzip'
    #     Category            = $CategoryName
    #     ToolType            = 'Extractor'
    #     CategoryDescription = $CategoryDescription
    #     WinGetId            = 'GnuWin32.Unzip'
    #     ChocoId             = 'unzip'
    #     GitHubRepo          = 'madler/unzip'
    #     BinaryCheck         = 'unzip.exe'
    #     Dependencies        = @()
    #     Provides            = @('unzip.exe')
    #     Validation          = [PSCustomObject]@{ Type='Command'; Value='unzip.exe' }
    # }
)

# -----------------------------
# Return tools array safely for dot-sourcing
# -----------------------------
@($Tools)
