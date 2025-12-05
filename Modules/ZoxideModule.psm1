### Zoxide Module

function Initialize-Zoxide {
    if (Test-CommandExists zoxide) {
        Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
    } else {
        Write-Host "zoxide command not found. Attempting to install via winget..."
        try {
            winget install -e --id ajeetdsouza.zoxide
            Write-Host "zoxide installed successfully. Initializing..."
            Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
        } catch {
            Write-Error "Failed to install zoxide. Error: $_"
        }
    }
}

Initialize-Zoxide

Export-ModuleMember -Function Initialize-Zoxide
