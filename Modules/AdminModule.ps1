### Admin Module

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Custom Prompt
function prompt {
    if ($isAdmin) { 
        "[" + (Get-Location) + "] # " 
    } else { 
        "[" + (Get-Location) + "] $ " 
    }
}

# Window Title
$adminSuffix = if ($isAdmin) { " [ADMIN]" } else { "" }
$Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

# Admin function
function admin {
    if ($args.Count -gt 0) {
        $argList = $args -join ' '
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}

Set-Alias -Name su -Value admin

Export-ModuleMember -Function prompt, admin
Export-ModuleMember -Alias su
