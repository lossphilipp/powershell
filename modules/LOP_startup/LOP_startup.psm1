. (Join-Path -Path ($PSScriptRoot | Split-Path) -ChildPath "\LOP_help\LOP_help.ps1")

Function LOP-FHV {
    <#
    .SYNOPSIS
        Starts all FHV related stuff

    .DESCRIPTION
        Opens the FHV folder.
        Starts Firefox to A5 and ilias.
        Opens applications according to the used switches

    .EXAMPLE
        PS> LOP-FHV
        Start FHV stuff

    .EXAMPLE
        PS> LOP-FHV -vpn -zotero -datagrip -teams
        Start FHV stuff

    .EXAMPLE
        PS> LOP-FHV -v -z -d -t
        Start FHV stuff

    .LINK
        https://github.com/lossphilipp/powershell
    #>

    [Cmdletbinding()]
    [OutputType('System.Void')]
    Param (
        # Open Cisco VPN
        # Alias: v
        [Parameter()]
        [Alias("v")]
        [switch]$VPN,
        
        # Open Zotero
        # Alias: z
        [Parameter()]
        [Alias("z")]
        [switch]$Zotero,
        
        # Open DataGrip
        # Alias: d
        [Parameter()]
        [Alias("d")]
        [switch]$DataGrip,
        
        # Open Teams
        # Alias: t
        [Parameter()]
        [Alias("t")]
        [switch]$Teams
    )

    begin {
        $fhvFolder = "$Env:FHV\Master\Semester_3"
        $urls = @("https://a5.fhv.at/de/index.php","https://ilias.fhv.at/")
    }

    process {
        Open-Firefox -URLs $urls
        
        Open-Folder($fhvFolder)
        
        if ($VPN) {
            Start-Process -FilePath "$startMenuProgramData\Cisco\Cisco Secure Client\Cisco Secure Client.lnk"
        }
        
        if ($Zotero) {
            Start-Process -FilePath "$startMenuProgramData\Zotero.lnk"
        }

        if ($Teams) {
            Start-Process -FilePath "$startMenuWindowsApps\ms-teams.exe"
        }
    }

    end {

    }
}

Function LOP-Gaming {
    <#
    .SYNOPSIS
        Starts gaming related stuff

    .DESCRIPTION
        Starts Logitech Gaming Software & ArmouryCrate.
        Opens applications according to the used switches

    .EXAMPLE
        PS> LOP-Gaming
        Start gaming stuff

    .EXAMPLE
        PS> LOP-Gaming -multi -riot -steam
        Start gaming stuff
        
    .EXAMPLE
        PS> LOP-Gaming -m -r -s
        Start gaming stuff

    .LINK
        https://github.com/lossphilipp/powershell
    #>

    [Cmdletbinding()]
    [OutputType('System.Void')]
    Param (
        # Open Discord
        # Alias: d, m
        [Parameter()]
        [Alias("d", "m")]
        [switch]$Multiplayer,
        
        # Open Steam
        # Alias: s
        [Parameter()]
        [Alias("s")]
        [switch]$Steam,

        # Open GOG Galaxy
        # Alias: g
        [Parameter()]
        [Alias("g")]
        [switch]$GOG
    )

    begin {

    }

    process {
        Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "Logitech\Logitech Gaming Software 9.04.lnk") -wait
        Start-Process -FilePath (Join-Path -Path $startMenuWindowsApps -ChildPath "ArmouryCrate.exe") -wait
        Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "AMD Software꞉ Adrenalin Edition\AMD Software꞉ Adrenalin Edition.lnk") -wait

        if ($Multiplayer) {
            Start-Process -FilePath (Join-Path -Path $startMenuAppData -ChildPath "Discord.lnk")
        }

        if ($Steam) {
            Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "Steam\Steam.lnk")
        }

        if ($GOG) {
            Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "GOG.com\GOG Galaxy.lnk")
        }

        Close-GUI 'LCore' 'Logitech Gaming Software'
        Close-GUI 'ArmouryCrate'
        Close-GUI 'RadeonSoftware' 'AMD Adrenaline Software'
    }

    end {

    }
}

Function LOP-Coding {
    <#
    .SYNOPSIS
        Starts coding related stuff

    .DESCRIPTION
        Opens the Coding folder.
        Starts Firefox to GitHub.

    .EXAMPLE
        PS> LOP-Coding
        Start coding stuff

    .EXAMPLE
        PS> LOP-Gaming -vscode -visualStudio -docker
        Start coding stuff
        
    .EXAMPLE
        PS> LOP-Gaming -c -v -d
        Start coding stuff

    .LINK
        https://github.com/lossphilipp/powershell
    #>

    [Cmdletbinding()]
    [OutputType('System.Void')]
    Param (
        # Start Docker Desktop
        # Alias: d
        [Parameter()]
        [Alias("d")]
        [switch]$Docker,

        # Open VS Code
        # Alias: c
        [Parameter()]
        [Alias("c")]
        [switch]$VSCode,

        # Open Visual Studio
        # Alias: v, vs
        [Parameter()]
        [Alias("v", "vs")]
        [switch]$VisualStudio,

        # Open Android Studio
        # Alias: a
        [Parameter(DontShow)]
        [Alias("a")]
        [switch]$Android
    )

    begin {

    }

    process {
        Open-Folder($Env:Coding)

        Open-Firefox -URLs "https://github.com/"

        if ($Docker) {
            LOP-Docker
        }

        if ($VSCode) {
            Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "Visual Studio Code\Visual Studio Code.lnk")
        }

        if ($VisualStudio) {
            Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "Visual Studio 2022.lnk")
        }

        if ($Android) {
            Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "Android Studio.lnk")
        }
    }

    end {

    }
}

Function LOP-Homelab {
    <#
    .SYNOPSIS
        Starts homelab related stuff

    .DESCRIPTION
        Not implemented yet.

    .EXAMPLE
        PS> LOP-Homelab
        Starts homelab related stuff

    .LINK
        https://github.com/lossphilipp/powershell
    #>

    [Cmdletbinding()]
    [OutputType('System.Void')]
    Param ()

    begin {
        $homelabFolder = (Join-Path -Path $Env:Coding -ChildPath "homelab")
        $urls = @("https://proxmox-server:8006/","http://docker-host.proxmox/","http://homeassistant.proxmox:8123/")
    }

    process {
        Open-Firefox -URLs $urls
        Open-Folder($homelabFolder)

        Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "Visual Studio Code\Visual Studio Code.lnk") -ArgumentList "-n $homelabFolder"
    }

    end {

    }
}

Function LOP-Docker {
    <#
    .SYNOPSIS
        Starts Docker Desktop

    .DESCRIPTION
        Starts Docker Desktop from the Start Menu.

    .EXAMPLE
        PS> LOP-Docker
        Starts Docker Desktop

    .LINK
        https://github.com/lossphilipp/powershell
    #>

    [Cmdletbinding()]
    [OutputType('System.Void')]
    Param (
        # The name of the image to start
        # Aliases: Name, i
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true
        )]
        [Alias("Name")]
        [Alias("i")]
        [string]$Image
    )

    begin {

    }

    process {
        Start-Process -FilePath (Join-Path -Path $Env:ProgramData -ChildPath "Microsoft\Windows\Start Menu\Docker Desktop.lnk")

        if ($Image) {
            $foundImage = Get-DockerImage -Name $Image
            if ($foundImage) {
                Start-DockerContainer -Image $foundImage
            } else {
                Write-Error "Docker image ""$($Image)"" not found."
            }
        }
    }

    end {

    }
}