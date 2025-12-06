### Core Utility Functions

function Test-CommandExists {
    param($command)
    return $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

function Get-ProfilePath {
    if ($PSVersionTable.PSEdition -eq "Core") {
        return "$env:userprofile\Documents\Powershell"
    }
    elseif ($PSVersionTable.PSEdition -eq "Desktop") {
        return "$env:userprofile\Documents\WindowsPowerShell"
    }
}

# Export module members
Export-ModuleMember -Function Test-CommandExists, Get-ProfilePath
