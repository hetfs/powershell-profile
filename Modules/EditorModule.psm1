### Editor Module

# Editor Configuration
if (Test-Path variable:EDITOR_Override) {
    $EDITOR = $EDITOR_Override
} else {
    $EDITOR = if (Test-CommandExists nvim) { 'nvim' }
          elseif (Test-CommandExists pvim) { 'pvim' }
          elseif (Test-CommandExists vim) { 'vim' }
          elseif (Test-CommandExists vi) { 'vi' }
          elseif (Test-CommandExists code) { 'code' }
          elseif (Test-CommandExists codium) { 'codium' }
          elseif (Test-CommandExists notepad++) { 'notepad++' }
          elseif (Test-CommandExists sublime_text) { 'sublime_text' }
          else { 'notepad' }
}

Set-Alias -Name vim -Value $EDITOR

# Profile editing
function Edit-Profile {
    & $EDITOR $PROFILE.CurrentUserAllHosts
}

Set-Alias -Name ep -Value Edit-Profile

Export-ModuleMember -Function Edit-Profile
Export-ModuleMember -Alias vim, ep
