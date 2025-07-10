. (Join-Path -Path $PSScriptRoot -ChildPath "LOP_help.ps1")

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

    [OutputType('System.Void')]
    Param ()

    begin {

    }

    process {
        Join-Path -Path ($PSScriptRoot | Split-Path) -ChildPath "\LOP_startup\LOP_startup.psd1" |
        Import-Module -Force

        Get-Help "LOP*"
    }

    end {

    }
}