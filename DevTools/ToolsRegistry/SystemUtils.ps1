<#
.SYNOPSIS
    System utilities, diagnostics, automation, and archiving tools.

.DESCRIPTION
    Defines system information utilities, diagnostic helpers, automation tools,
    search utilities, and archive and compression tools.

    Validation strategy:
    - Command validation is used when installers reliably expose binaries in PATH
    - Path validation is used when installers may not update PATH consistently

    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====================================================
# Category metadata
# ====================================================
$CategoryName        = 'SystemUtils'
$CategoryDescription = 'System utilities, diagnostics, automation, and archiving tools'

# ====================================================
# Tool definitions
# ====================================================
$Tools = @(

    # ====================================================
    # fastfetch - System Information
    # ----------------------------------------------------
    # Fast system information display for terminal output
    # and scripting use cases.
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'fastfetch.exe'
        }
    }

    # ====================================================
    # btop4win - Resource Monitor
    # ----------------------------------------------------
    # Interactive terminal-based system resource monitor
    # for CPU, memory, disk, and process inspection.
    # ====================================================
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'btop.exe'
        }
    }

    # ====================================================
    # tar - Archiving and Compression
    # ----------------------------------------------------
    # Archive creation and extraction using tar format.
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
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'tar.exe'
        }
    }

    # ====================================================
    # Task - Task Runner and Automation
    # ----------------------------------------------------
    # Declarative task runner for automating workflows,
    # build steps, and repeatable scripts.
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Task'
        Category            = $CategoryName
        ToolType            = 'TaskRunner'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'GoTask.Task'
        ChocoId             = 'go-task'
        GitHubRepo          = 'go-task/task'
        BinaryCheck         = 'task.exe'
        Dependencies        = @()
        Provides            = @('task.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:ProgramFiles\task\task.exe",
                "$env:ProgramFiles(x86)\task\task.exe",
                "$env:ProgramData\chocolatey\bin\task.exe"
            )
        }
    }

    # ====================================================
    # unzip - Extraction Utility
    # ----------------------------------------------------
    # Command-line utility for extracting ZIP archives.
    # ====================================================
    [PSCustomObject]@{
        Name                = 'unzip'
        Category            = $CategoryName
        ToolType            = 'Extractor'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'GnuWin32.Unzip'
        ChocoId             = 'unzip'
        GitHubRepo          = 'madler/unzip'
        BinaryCheck         = 'unzip.exe'
        Dependencies        = @()
        Provides            = @('unzip.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Path'
            Value = @(
                "$env:ProgramFiles\GnuWin32\bin\unzip.exe",
                "$env:ProgramFiles(x86)\GnuWin32\bin\unzip.exe",
                "$env:ProgramData\chocolatey\bin\unzip.exe"
            )
        }
    }

)

# ====================================================
# Return tools array safely
# ====================================================
@($Tools)
