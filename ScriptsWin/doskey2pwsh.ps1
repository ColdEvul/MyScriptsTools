$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ( !($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host "You are not Administrator" -ForegroundColor Red
    exit 1
}

if ( !(Test-Path "$env:userprofile\.batch_aliases.cmd" -PathType leaf) ) { Write-Host "No DOSKEY alieases can be descovered" -ForegroundColor Red; exit 1 }

$dosaliases = Get-Content $env:userprofile\.batch_aliases.cmd |
    Where-Object {$_ -match 'DOSKEY'}

if ( !(Test-Path "$env:userprofile\Documents\PowerShell\profile_aliases.ps1" -PathType leaf) ) {
    New-Item "$env:userprofile\Documents\PowerShell\profile_aliases.ps1"
}

"# This file is autogenerated based on the BATCH_ALIASES $(Get-Date)" | Out-File -FilePath "$env:userprofile\Documents\PowerShell\profile_aliases.ps1"
foreach ($element in $dosaliases) {
    $element = $element.replace("DOSKEY", "")
    $element = $element.replace("`$*", "")
    $element = $element.replace(" `$T", ";")
    $element = $element.Trim()
    $element = $element.split("=")
    
    $isSingleCommand = $element[1].split(" ")
    if ( $isSingleCommand.Count -eq 1 ) {
        Write-Host "Making global alias out of $($element[0]) => $($element[1])"
        "Set-Alias -Name $($element[0]) -value $($element[1]) -Scope 'Global'" | Out-File -FilePath "$env:userprofile\Documents\PowerShell\profile_aliases.ps1" -Append
    } else {
        Write-Host "Making global function for $($element[0]) => { $($element[1]) }"
        "`nfunction global:$($element[0])(`$arguments) {
    $($element[1]) `$arguments
}
#Set-Alias -Name $($element[0]) -value $($element[0]) -Scope 'Global'" | Out-File -FilePath "$env:userprofile\Documents\PowerShell\profile_aliases.ps1" -Append
    }
}

if ( !(Test-Path "$env:userprofile\.pwsh_aliases" -PathType leaf) ) {
    Write-Host "Setting up .pwsh_aliases..." -ForegroundColor Blue
    New-Item -itemtype SymbolicLink -path "$Env:userprofile" -name ".pwsh_aliases" -value "$Env:userprofile\Documents\PowerShell\profile_aliases.ps1" >$null 2>&1
    (Get-Item $Env:userprofile\.pwsh_aliases).Attributes += 'Hidden'
}
Write-Host "Aliases succsessfully cloned and functions are created..." -ForegroundColor Blue
