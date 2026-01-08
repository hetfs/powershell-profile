<#
.SYNOPSIS
    Programming languages, compilers, build tools, language servers,
    and development environments (Windows only).

.DESCRIPTION
    Defines Windows-supported language runtimes, compilers, build systems,
    language servers, and development environments for DevTools.
    Returns a stable array of PSCustomObjects for installation and validation.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Category metadata
# ==============================
$CategoryName        = 'Languages'
$CategoryDescription = 'Programming languages, compilers, build tools, and development environments'

# ==============================
# Tool definitions
# ==============================
$Tools = @(

    # ====================================================
    # Compiled Languages
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Rust'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Compiler'
        WinGetId            = 'Rustlang.Rustup'
        ChocoId             = 'rustup.install'
        GitHubRepo          = 'rust-lang/rust'
        BinaryCheck         = 'rustc.exe'
        Dependencies        = @()
        Provides            = @('rustc.exe','cargo.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'rustc.exe'
        }
    }

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
            Type  = 'Command'
            Value = 'go.exe'
        }
    }

    # ====================================================
    # Interpreted Languages
    # ====================================================
    [PSCustomObject]@{
        Name                = 'Python'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Interpreter'
        WinGetId            = 'Python.Python.3'
        ChocoId             = 'python'
        GitHubRepo          = 'python/cpython'
        BinaryCheck         = 'python.exe'
        Dependencies        = @()
        Provides            = @('python.exe','pip.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'python.exe'
        }
    }

    [PSCustomObject]@{
        Name                = 'Lua'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Interpreter'
        WinGetId            = 'DEVCOM.Lua'
        ChocoId             = ''
        GitHubRepo          = 'lua/lua'
        BinaryCheck         = 'lua.exe'
        Dependencies        = @()
        Provides            = @('lua.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'lua.exe'
        }
    }

    [PSCustomObject]@{
        Name                = 'Perl (Strawberry)'
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
            Type  = 'Command'
            Value = 'perl.exe'
        }
    }

    # # ====================================================
    # # Language Servers
    # # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'clangd'
    #     Category            = $CategoryName
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'LSP'
    #     WinGetId            = 'LLVM.LLVM'
    #     ChocoId             = 'llvm'
    #     GitHubRepo          = 'llvm/llvm-project'
    #     BinaryCheck         = 'clangd.exe'
    #     Dependencies        = @('LLVM')
    #     Provides            = @('clangd.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'clangd.exe'
    #     }
    # }

    # # ====================================================
    # # Build Tools
    # # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'LLVM'
    #     Category            = 'BuildTools'
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'Compiler'
    #     WinGetId            = 'LLVM.LLVM'
    #     ChocoId             = 'llvm'
    #     GitHubRepo          = 'llvm/llvm-project'
    #     BinaryCheck         = 'clang.exe'
    #     Dependencies        = @('CMake','Ninja')
    #     Provides            = @(
    #         'clang.exe',
    #         'clang++.exe',
    #         'lld.exe',
    #         'lldb.exe',
    #         'clangd.exe',
    #         'clang-format.exe',
    #         'clang-tidy.exe'
    #     )
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'clang.exe'
    #     }
    # }

    [PSCustomObject]@{
        Name                = 'CMake'
        Category            = 'BuildTools'
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

    [PSCustomObject]@{
        Name                = 'Ninja'
        Category            = 'BuildTools'
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

    # [PSCustomObject]@{
    #     Name                = 'Meson'
    #     Category            = 'BuildTools'
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'BuildTool'
    #     WinGetId            = 'MesonBuildSystem.Meson'
    #     ChocoId             = 'meson'
    #     GitHubRepo          = 'mesonbuild/meson'
    #     BinaryCheck         = 'meson.exe'
    #     Dependencies        = @('Python')
    #     Provides            = @('meson.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'meson.exe'
    #     }
    # }

    [PSCustomObject]@{
        Name                = 'ccache'
        Category            = 'BuildTools'
        CategoryDescription = $CategoryDescription
        ToolType            = 'BuildTool'
        WinGetId            = 'ccache.ccache'
        ChocoId             = 'ccache'
        GitHubRepo          = 'ccache/ccache'
        BinaryCheck         = 'ccache.exe'
        Dependencies        = @('CMake')
        Provides            = @('ccache.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'ccache.exe'
        }
    }

    # # ====================================================
    # # Development Environments
    # # ====================================================
    # [PSCustomObject]@{
    #     Name                = 'MSYS2'
    #     Category            = 'CoreShell'
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'Environment'
    #     WinGetId            = 'MSYS2.MSYS2'
    #     ChocoId             = 'msys2'
    #     GitHubRepo          = 'msys2/msys2-installer'
    #     BinaryCheck         = 'msys2.exe'
    #     Dependencies        = @()
    #     Provides            = @('gcc.exe','g++.exe','make.exe','gdb.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'msys2.exe'
    #     }
    # }

    # [PSCustomObject]@{
    #     Name                = 'WSL Toolchain Integration'
    #     Category            = 'CoreShell'
    #     CategoryDescription = $CategoryDescription
    #     ToolType            = 'Environment'
    #     WinGetId            = 'Microsoft.WSL'
    #     ChocoId             = ''
    #     GitHubRepo          = 'microsoft/WSL'
    #     BinaryCheck         = 'wsl.exe'
    #     Dependencies        = @()
    #     Provides            = @('wsl.exe')
    #     Validation          = [PSCustomObject]@{
    #         Type  = 'Command'
    #         Value = 'wsl.exe'
    #     }
    # }
)

# ==============================
# Return tools array safely
# ==============================
@($Tools)
