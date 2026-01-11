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

# -----------------------------
# Category metadata
# -----------------------------
$CategoryName        = 'Terminals'
$CategoryDescription = 'Terminal emulators and interactive shell environments.'

# -----------------------------
# Terminal definitions
# -----------------------------
$Tools = @(

    # ====================================================
    # GPU-accelerated terminal emulators
    # ====================================================
    [PSCustomObject]@{
        Name                = 'WezTerm'
        Category            = $CategoryName
        ToolType            = 'TerminalEmulator'
        CategoryDescription = 'GPU-accelerated, cross-platform, highly configurable terminal emulator.'
        WinGetId            = 'wez.wezterm'
        ChocoId             = 'wezterm'
        GitHubRepo          = 'wez/wezterm'
        BinaryCheck         = 'wezterm.exe'
        Dependencies        = @()
        Provides            = @('wezterm.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='wezterm.exe' }
    }

    # ====================================================
    # Windows-native terminal
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Windows Terminal'
        Category            = $CategoryName
        ToolType            = 'TerminalEmulator'
        CategoryDescription = 'Modern, tabbed terminal for Windows with multiple shells support.'
        WinGetId            = 'Microsoft.WindowsTerminal'
        ChocoId             = 'microsoft-windows-terminal'
        GitHubRepo          = 'microsoft/terminal'
        BinaryCheck         = 'wt.exe'
        Dependencies        = @()
        Provides            = @('wt.exe')
        Validation          = [PSCustomObject]@{ Type='Command'; Value='wt.exe' }
    }
)

# -----------------------------
# Return tools array safely for dot-sourcing
# -----------------------------
@($Tools)
