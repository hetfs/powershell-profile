@(
    # ====================================================
    # Code Editors
    # ====================================================

    [PSCustomObject]@{
        Name        = "Neovim"
        Category    = "Editors"
        WinGetId    = "Neovim.Neovim"
        ChocoId     = "neovim"
        GitHubRepo  = "neovim/neovim"
        BinaryCheck = "nvim.exe"
        Dependencies= @()
        Purpose     = "Hyperextensible terminal-based text editor"
    },

    # Optional Editors (uncomment if desired)
    # [PSCustomObject]@{
    #     Name        = "Vim"
    #     Category    = "Editors"
    #     WinGetId    = "Vim.Vim"
    #     ChocoId     = "vim"
    #     GitHubRepo  = "vim/vim"
    #     BinaryCheck = "vim.exe"
    #     Dependencies= @()
    #     Purpose     = "Classic terminal text editor, widely used for scripting and coding"
    # },

    # [PSCustomObject]@{
    #     Name        = "Visual Studio Code"
    #     Category    = "Editors"
    #     WinGetId    = "Microsoft.VisualStudioCode"
    #     ChocoId     = "vscode"
    #     GitHubRepo  = "microsoft/vscode"
    #     BinaryCheck = "Code.exe"
    #     Dependencies= @()
    #     Purpose     = "Lightweight, extensible, cross-platform code editor"
    # },

    # [PSCustomObject]@{
    #     Name        = "Sublime Text"
    #     Category    = "Editors"
    #     WinGetId    = "SublimeHQ.SublimeText"
    #     ChocoId     = "sublimetext3"
    #     GitHubRepo  = "sublimehq/sublime_text"
    #     BinaryCheck = "sublime_text.exe"
    #     Dependencies= @()
    #     Purpose     = "Fast, lightweight GUI code editor with extensibility"
    # },

    # ====================================================
    # Code Validation & Shell Tools
    # ====================================================

    [PSCustomObject]@{
        Name        = "EditorConfig Checker"
        Category    = "Editors"
        WinGetId    = "editorconfig-checker.editorconfig-checker"
        ChocoId     = "editorconfig-checker"
        GitHubRepo  = "editorconfig-checker/editorconfig-checker"
        BinaryCheck = "ec.exe"
        Dependencies= @()
        Purpose     = "Validates .editorconfig files for consistent coding styles"
    },

    [PSCustomObject]@{
        Name        = "Config Validator"
        Category    = "Editors"
        WinGetId    = "config-validator.config-validator"
        ChocoId     = "config-validator"
        GitHubRepo  = "config-validator/config-validator"
        BinaryCheck = "config-validator.exe"
        Dependencies= @()
        Purpose     = "Validates JSON/YAML configuration files"
    },

    [PSCustomObject]@{
        Name        = "ShellCheck"
        Category    = "Editors"
        WinGetId    = "koalaman.shellcheck"
        ChocoId     = "shellcheck"
        GitHubRepo  = "koalaman/shellcheck"
        BinaryCheck = "shellcheck.exe"
        Dependencies= @()
        Purpose     = "Shell script static analysis tool for best practices and error detection"
    },

    [PSCustomObject]@{
        Name        = "Yank Note"
        Category    = "Editors"
        WinGetId    = "yank-note.yank-note"
        ChocoId     = "yank-note"
        GitHubRepo  = "yank-note/yank-note"
        BinaryCheck = "yank-note.exe"
        Dependencies= @()
        Purpose     = "CLI note-taking editor for managing quick notes efficiently"
    }
)
