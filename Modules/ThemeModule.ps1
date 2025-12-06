### Theme Module

function Get-Theme {
    if (Test-Path function:Get-Theme_Override) {
        Get-Theme_Override
        return
    }
    
    # Commented out Oh My Posh initialization
    # oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
    
    # Starship prompt (if installed)
    if (Test-CommandExists starship) {
        Invoke-Expression (&starship init powershell)
    } else {
        Write-Warning "Starship not found. Please install it for prompt theming."
    }
}

Get-Theme

Export-ModuleMember -Function Get-Theme
