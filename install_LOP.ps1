$relativeModulePath = "\modules"

$elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-Not $elevated) {
    throw "This script requires that PowerShell is running with admin rights!"
}

Function Add-RootToPSModulePath {
    $PSModulesString = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
    $currentPSModules = $PSModulesString -split [System.IO.Path]::PathSeparator

    $pathToAdd = (Join-Path -Path $PSScriptRoot -ChildPath $relativeModulePath)

    # Delete any existing PVM paths, to make sure this is the only one
    $currentPSModules = $currentPSModules | Where-Object { $_ -notlike "*$relativeModulePath" }

    $currentPSModules += $pathToAdd
    $newPSModulesString = $currentPSModules -join [System.IO.Path]::PathSeparator

    Write-Host "Adding current path to environment variable ""PSModulePath""...`n"
    [Environment]::SetEnvironmentVariable("PSModulePath", $newPSModulesString, "Machine")
    $env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
}

function Test-ModuleImports {
    Import-Module -Name LOP_startup -Force -DisableNameChecking
    Import-Module -Name LOP_help -Force -DisableNameChecking

    Get-Help "LOP*" | Out-Default
}

Add-RootToPSModulePath
Test-ModuleImports