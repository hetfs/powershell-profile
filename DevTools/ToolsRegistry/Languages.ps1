<#
.SYNOPSIS
    Programming languages and compilers (Windows only).

.DESCRIPTION
    Defines Windows-supported programming languages and compilers for DevTools.
    Returns a stable array of PSCustomObjects for installation and validation.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'Languages'
$CategoryDescription = 'Programming languages and compilers'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # Compiled Languages
    # ====================================================

    # ---------- LLVM (WinLibs) ----------
    [PSCustomObject]@{
        Name                = 'LLVM'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Compiler'
        WinGetId            = 'BrechtSanders.WinLibs.POSIX.MSVCRT.LLVM'
        ChocoId             = 'winlibs-llvm'
        GitHubRepo          = 'brechtsanders/winlibs_mingw'
        BinaryCheck         = 'clang++.exe'
        Dependencies        = @()
        Provides            = @(
            'clang.exe',
            'clang++.exe',
            'lld.exe',
            'lldb.exe',
            'clang-format.exe',
            'clang-tidy.exe'
        )
        Validation          = [PSCustomObject]@{
            Type  = 'command'
            Value = 'clang++'
        }
    },

    # ---------- Rust ----------
    [PSCustomObject]@{
        Name                = 'Rust'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Compiler'
        WinGetId            = 'Rustlang.Rust.MSVC'
        ChocoId             = 'rustup.install'
        GitHubRepo          = 'rust-lang/rust'
        BinaryCheck         = 'rustc.exe'
        Dependencies        = @()
        Provides            = @('rustc.exe','cargo.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'command'
            Value = 'rustc'
        }
    },

    # ---------- Go ----------
    [PSCustomObject]@{
        Name                = 'Go'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Compiler'
        WinGetId            = 'GoLang.Go'
        ChocoId             = 'golang'
        GitHubRepo          = 'golang/go'
        BinaryCheck         = 'go.exe'
        Dependencies        = @()
        Provides            = @('go.exe')
        Validation          = [PSCustomObject]@{
            Type       = 'command'
            Value      = 'go'
            MinVersion = '1.21'
        }
    },

    # ====================================================
    # Interpreted Languages
    # ====================================================

    # ---------- Python ----------
    [PSCustomObject]@{
        Name                = 'Python'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Interpreter'
        WinGetId            = 'Python.Python.3.14'
        ChocoId             = $null
        GitHubRepo          = 'python/cpython'
        BinaryCheck         = 'python.exe'
        Dependencies        = @()
        Provides            = @('python.exe','pip.exe','py.exe')
        Validation          = [PSCustomObject]@{
            Type           = 'command'
            Value          = 'python'
            MinVersion     = '3.11'
            PreferLauncher = $true
        }
    },

    # ---------- Lua ----------
    [PSCustomObject]@{
        Name                = 'Lua'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Interpreter'
        WinGetId            = 'DEVCOM.Lua'
        ChocoId             = 'lua'
        GitHubRepo          = 'lua/lua'
        BinaryCheck         = 'lua.exe'
        Dependencies        = @()
        Provides            = @('lua.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'command'
            Value = 'lua'
        }
    },

    # ---------- Strawberry Perl ----------
    [PSCustomObject]@{
        Name                = 'Strawberry Perl'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Interpreter'
        WinGetId            = 'StrawberryPerl.StrawberryPerl'
        ChocoId             = 'strawberryperl'
        GitHubRepo          = 'StrawberryPerl/Perl-Dist-Strawberry'
        BinaryCheck         = 'perl.exe'
        Dependencies        = @()
        Provides            = @('perl.exe','cpan.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'command'
            Value = 'perl'
        }
    }
)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
