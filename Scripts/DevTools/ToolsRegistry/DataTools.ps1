@(
    # ====================================================
    # Data & CLI Tools
    # ====================================================

    [PSCustomObject]@{
        Name        = "jq"
        Category    = "DataTools"
        WinGetId    = "jqlang.jq"             # Correct WinGet ID for jq
        ChocoId     = "jq"                    # Correct Chocolatey ID for jq
        GitHubRepo  = "jqlang/jq"
        BinaryCheck = "jq.exe"
        Dependencies= @()
        Purpose     = "Command-line JSON processor"
    },

    [PSCustomObject]@{
        Name        = "yq"
        Category    = "DataTools"
        WinGetId    = "MikeFarah.yq"           # Correct WinGet ID for yq
        ChocoId     = "yq"                    # Correct Chocolatey ID for yq
        GitHubRepo  = "mikefarah/yq"
        BinaryCheck = "yq.exe"
        Dependencies= @()
        Purpose     = "Command-line YAML processor"
    },

    [PSCustomObject]@{
        Name        = "ytt"
        Category    = "DataTools"
        WinGetId    = "Carvel.ytt"            # Correct WinGet ID for ytt
        ChocoId     = "ytt"                   # Correct Chocolatey ID for ytt
        GitHubRepo  = "carvel-dev/ytt"
        BinaryCheck = "ytt.exe"
        Dependencies= @()
        Purpose     = "YAML templating tool for configuration management"
    },

    [PSCustomObject]@{
        Name        = "Node.js"
        Category    = "DataTools"
        WinGetId    = "OpenJS.NodeJS"         # Correct WinGet ID for Node.js
        ChocoId     = "nodejs"                # Correct Chocolatey ID for Node.js
        GitHubRepo  = "nodejs/node"
        BinaryCheck = "node.exe"
        Dependencies= @()
        Purpose     = "JavaScript runtime for scripting and data tooling"
    }
)
