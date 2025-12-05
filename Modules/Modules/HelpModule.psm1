### Help Module

function Show-Help {
    $helpText = @"
$($PSStyle.Foreground.Cyan)PowerShell Profile Help$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)

$($PSStyle.Foreground.Green)Profile Management:$($PSStyle.Reset)
  Update-Profile      - Checks for profile updates
  Update-PowerShell   - Checks for PowerShell updates
  Edit-Profile (ep)   - Opens profile for editing
  reload-profile      - Reloads the profile

$($PSStyle.Foreground.Green)Git Shortcuts:$($PSStyle.Reset)
  gs    - git status
  ga    - git add .
  gc    - git commit -m <message>
  gpush - git push
  gpull - git pull
  gcom  - git add . && git commit -m <message>
  lazyg - git add . && git commit -m <message> && git push

$($PSStyle.Foreground.Green)Navigation:$($PSStyle.Reset)
  docs  - Go to Documents folder
  dtop  - Go to Desktop folder
  mkcd  - Create and change to directory
  g     - Go to GitHub directory (via zoxide)

$($PSStyle.Foreground.Green)System:$($PSStyle.Reset)
  uptime    - Show system uptime
  sysinfo   - Get system information
  admin/su  - Run as administrator
  winutil   - Open WinUtil
  winutildev - Open WinUtil (dev)

$($PSStyle.Foreground.Green)Network:$($PSStyle.Reset)
  Get-PubIP - Get public IP address
  flushdns  - Clear DNS cache

$($PSStyle.Foreground.Green)Utilities:$($PSStyle.Reset)
  ff    - Find files by name
  grep  - Search with regex
  la    - List files (detailed)
  ll    - List all files (including hidden)
  k9    - Kill process by name
  cpy   - Copy to clipboard
  pst   - Paste from clipboard
  Clear-Cache - Clear system cache
  hb    - Upload to hastebin

$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)
Use '$($PSStyle.Foreground.Magenta)Show-Help$($PSStyle.Reset)' to display this help message.
"@
    Write-Host $helpText
}

Export-ModuleMember -Function Show-Help
