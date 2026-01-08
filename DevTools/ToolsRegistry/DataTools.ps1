<#
.SYNOPSIS
    Data & CLI Tools

.DESCRIPTION
    Defines data processing tools such as JSON and YAML processors,
    JavaScript runtimes, and associated tooling.
    Returns a stable array of PSCustomObjects for installers,
    validators, and documentation generators.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====================================================
# Category metadata
# ====================================================
$CategoryName        = 'DataTools'
$CategoryDescription = 'Database and data processing tools'

# ====================================================
# Tool definitions
# ====================================================
$Tools = @(

    # ------------------------------------------------
    # Node.js — JavaScript runtime
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'Node.js'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'Runtime'
        WinGetId            = 'OpenJS.NodeJS'
        ChocoId             = 'nodejs'
        GitHubRepo          = 'https://github.com/nodejs/node'
        BinaryCheck         = 'node.exe'
        Dependencies        = @()
        Provides            = @('node.exe', 'npm.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'node.exe'
        }
    }

    # ------------------------------------------------
    # jq — JSON processor
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'jq'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'JSONProcessor'
        WinGetId            = 'jqlang.jq'
        ChocoId             = 'jq'
        GitHubRepo          = 'https://github.com/jqlang/jq'
        BinaryCheck         = 'jq.exe'
        Dependencies        = @()
        Provides            = @('jq.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'jq.exe'
        }
    }

    # ------------------------------------------------
    # yq — YAML processor
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'yq'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'YAMLProcessor'
        WinGetId            = 'MikeFarah.yq'
        ChocoId             = 'yq'
        GitHubRepo          = 'https://github.com/mikefarah/yq'
        BinaryCheck         = 'yq.exe'
        Dependencies        = @()
        Provides            = @('yq.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'yq.exe'
        }
    }

    # ------------------------------------------------
    # ytt — YAML templating tool
    # ------------------------------------------------
    [PSCustomObject]@{
        Name                = 'ytt'
        Category            = $CategoryName
        CategoryDescription = $CategoryDescription
        ToolType            = 'YAMLTemplating'
        WinGetId            = 'Carvel.ytt'
        ChocoId             = 'ytt'
        GitHubRepo          = 'https://github.com/carvel-dev/ytt'
        BinaryCheck         = 'ytt.exe'
        Dependencies        = @()
        Provides            = @('ytt.exe')
        Validation          = [PSCustomObject]@{
            Type  = 'Command'
            Value = 'ytt.exe'
        }
    }

)

# ====================================================
# Return tools array safely
# ====================================================
@($Tools)
