$relativeModulePath = "\StartupModes"

$Elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ( -not $Elevated ) {
    throw "This script requires that PowerShell is running with admin rights!"
}

Function AddRootToPSModulePath {
    $CurrentValue = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
    $pathToAdd = ($PSScriptRoot) + $relativeModulePath

    if(($CurrentValue -like "*$($pathToAdd)*") -ne $true) {
        [Environment]::SetEnvironmentVariable("PSModulePath", $CurrentValue + [System.IO.Path]::PathSeparator + ($PSScriptRoot) + $relativeModulePath, "Machine")
        #reload path variables for current session (no need to restart powershell) does not work as the modules also have to be reloaded... sad :(
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
		Write-Host "Done. Please restart PowerShell!" -ForegroundColor Green
    } else {
        Write-Host "Current path is already part of PSModulePath -> skip"
    }
}

AddRootToPSModulePath