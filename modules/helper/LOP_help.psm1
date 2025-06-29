. "$PSScriptRoot\LOP_help.ps1"

Function LOP-Help {
    <#
    .SYNOPSIS
        Displays this help message

    .DESCRIPTION
        Displays the help message for the LOP module

    .EXAMPLE
        PS> LOP-Help
        Displays this help message

    .LINK
        https://github.com/lossphilipp/powershell
    #>

    Param ()

    begin {

    }

    process {
        Import-Module "$PSScriptRoot\startup\LOP_startup.psm1" -Force

        Get-Help "LOP*"
    }

    end {

    }
}