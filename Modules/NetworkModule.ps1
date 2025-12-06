### Network Module

function Get-PubIP { 
    (Invoke-WebRequest http://ifconfig.me/ip).Content 
}

function flushdns {
    Clear-DnsClientCache
    Write-Host "DNS has been flushed"
}

Export-ModuleMember -Function Get-PubIP, flushdns
