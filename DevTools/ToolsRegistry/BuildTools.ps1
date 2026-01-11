<#
.SYNOPSIS
    Build tools and language servers (Windows only).

.DESCRIPTION
    Defines Windows-supported build systems, toolchains,
    and language servers for DevTools.
    Returns a stable array of PSCustomObjects for installation and validation.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'BuildTools'
$CategoryDescription = 'Build systems, toolchains, and language servers'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # Language Servers
    # ====================================================

    # ---------- CLANGD ----------
    [PSCustomObject]@{
        Name                = 'clangd'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'LSP'
        WinGetId            = 'LLVM.clangd'
        ChocoId             = 'llvm'
        GitHubRepo          = 'llvm/llvm-project'
        BinaryCheck         = 'clangd.exe'
        Dependencies        = @('LLVM')
        Provides            = @('clangd.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'clangd.exe'
        }
    }

    # ====================================================
    # Build Systems
    # ====================================================

    # ---------- CMAKE ----------
    [PSCustomObject]@{
        Name                = 'CMake'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'BuildTool'
        WinGetId            = 'Kitware.CMake'
        ChocoId             = 'cmake'
        GitHubRepo          = 'Kitware/CMake'
        BinaryCheck         = 'cmake.exe'
        Dependencies        = @()
        Provides            = @('cmake.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'cmake.exe'
        }
    }

    # ---------- NINJA ----------
    [PSCustomObject]@{
        Name                = 'Ninja'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'BuildTool'
        WinGetId            = 'Ninja-build.Ninja'
        ChocoId             = 'ninja'
        GitHubRepo          = 'ninja-build/ninja'
        BinaryCheck         = 'ninja.exe'
        Dependencies        = @('CMake')
        Provides            = @('ninja.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'ninja.exe'
        }
    }

    # ---------- CCACHE ----------
    [PSCustomObject]@{
        Name                = 'Ccache'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'BuildTool'
        WinGetId            = 'Ccache.Ccache'
        ChocoId             = 'ccache'
        GitHubRepo          = 'ccache/ccache'
        BinaryCheck         = 'ccache.exe'
        Dependencies        = @()
        Provides            = @('ccache.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'ccache.exe'
        }
    }
)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
