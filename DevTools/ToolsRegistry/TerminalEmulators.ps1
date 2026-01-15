<#
.SYNOPSIS
    Terminal emulators for enhanced shell experiences.

.DESCRIPTION
    Defines terminal emulators supported by DevTools, including GPU-accelerated
    and native Windows terminals.

    Returns a stable array of PSCustomObjects for DevTools installer
    and validator consumption.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====================================================
# Category metadata
# ====================================================
$CategoryName        = 'TerminalEmulators'
$CategoryDescription = 'Terminal emulators and interactive shell environments.'

# ====================================================
# Terminal definitions
# ====================================================
$Tools = @(

    # ====================================================
    # WezTerm - GPU-accelerated terminal emulator
    # ----------------------------------------------------
    # Modern terminal with GPU acceleration, ligature support,
    # and cross-platform compatibility.
    # ====================================================
    [PSCustomObject]@{
        Name                = 'WezTerm'
        Category            = $CategoryName
        ToolType            = 'TerminalEmulator'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'wez.wezterm'
        ChocoId             = 'wezterm'
        GitHubRepo          = 'wez/wezterm'
        BinaryCheck         = 'wezterm.exe'
        Dependencies        = @()
        Provides            = @('wezterm.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'wezterm.exe'
        }
    }

    # ====================================================
    # Windows Terminal - Native Windows terminal
    # ----------------------------------------------------
    # Microsoft’s native terminal with tabs, profiles,
    # and deep integration into Windows ecosystem.
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Windows Terminal'
        Category            = $CategoryName
        ToolType            = 'TerminalEmulator'
        CategoryDescription = $CategoryDescription
        WinGetId            = 'Microsoft.WindowsTerminal'
        ChocoId             = 'microsoft-windows-terminal'
        GitHubRepo          = 'microsoft/terminal'
        BinaryCheck         = 'wt.exe'
        Dependencies        = @()
        Provides            = @('wt.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'wt.exe'
        }
    }
)

# ====================================================
# Return tools array safely
# ====================================================
@($Tools)
