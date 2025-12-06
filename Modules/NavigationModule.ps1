### Navigation Module

function docs { 
    $docs = if(([Environment]::GetFolderPath("MyDocuments"))) {
        ([Environment]::GetFolderPath("MyDocuments"))
    } else {
        $HOME + "\Documents"
    }
    Set-Location -Path $docs
}

function dtop { 
    $dtop = if ([Environment]::GetFolderPath("Desktop")) {
        [Environment]::GetFolderPath("Desktop")
    } else {
        $HOME + "\Documents"
    }
    Set-Location -Path $dtop
}

function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

function g { __zoxide_z github }

Export-ModuleMember -Function docs, dtop, mkcd, g
