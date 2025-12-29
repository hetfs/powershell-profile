@(
    # ====================================================
    # Programming Languages & Runtimes
    # ====================================================

    [PSCustomObject]@{
        Name        = "Rust"
        Category    = "Languages"
        WinGetId    = "Rustlang.Rustup"
        ChocoId     = "rustup.install"
        GitHubRepo  = "rust-lang/rust"
        BinaryCheck = "rustc.exe"
        Dependencies= @()
        Purpose     = "Systems programming language, compiled, fast, safe, and concurrent"
    },

    [PSCustomObject]@{
        Name        = "Go"
        Category    = "Languages"
        WinGetId    = "GoLang.Go"
        ChocoId     = "golang"
        GitHubRepo  = "golang/go"
        BinaryCheck = "go.exe"
        Dependencies= @()
        Purpose     = "Statically typed compiled language, optimized for concurrency and simplicity"
    },

    [PSCustomObject]@{
        Name        = "Python"
        Category    = "Languages"
        WinGetId    = "Python.Python.3"
        ChocoId     = "python"
        GitHubRepo  = "python/cpython"
        BinaryCheck = "python.exe"
        Dependencies= @()
        Purpose     = "High-level interpreted language, widely used for automation, data science, and development"
    },

    [PSCustomObject]@{
        Name        = "Lua"
        Category    = "Languages"
        WinGetId    = "DEVCOM.Lua"
        ChocoId     = $null
        GitHubRepo  = "lua/lua"
        BinaryCheck = "lua.exe"
        Dependencies= @()
        Purpose     = "Lightweight scripting language for configuration, game development, and embedded use"
    },

    [PSCustomObject]@{
        Name        = "Lua Language Server"
        Category    = "Languages"
        WinGetId    = "LuaLS.lua-language-server"
        ChocoId     = $null
        GitHubRepo  = "LuaLS/lua-language-server"
        BinaryCheck = "lua-language-server.exe"
        Dependencies= @()
        Purpose     = "Language server for Lua, provides autocompletion, diagnostics, and IDE integration"
    },

    [PSCustomObject]@{
        Name        = "Perl (Strawberry)"
        Category    = "Languages"
        WinGetId    = "StrawberryPerl.StrawberryPerl"
        ChocoId     = "strawberryperl"
        GitHubRepo  = "strawberryperl/strawberry-perl"
        BinaryCheck = "perl.exe"
        Dependencies= @()
        Purpose     = "Perl programming language distribution for Windows, includes compiler, libraries, and tools"
    }
)
