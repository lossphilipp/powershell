########### Variables ##########

$startMenuProgramData = (Join-Path -Path $Env:ProgramData -ChildPath "Microsoft\Windows\Start Menu\Programs")
$startMenuAppData = (Join-Path -Path $Env:AppData -ChildPath "Microsoft\Windows\Start Menu\Programs")
$startMenuWindowsApps = (Join-Path -Path $Env:USERPROFILE -ChildPath "AppData\Local\Microsoft\WindowsApps")

########### Functions ##########

Function Open-Folder {
    [OutputType('System.Void')]
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string]$Path
    )

    begin {

    }

    process {
        Invoke-Item $Path
        Set-Location $Path
        Get-ChildItem
    }

    end {

    }
}

Function Open-Firefox {
    [OutputType('System.Void')]
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string[]]$URLs
    )

    begin {

    }

    process {
        Start-Process -FilePath (Join-Path -Path $startMenuProgramData -ChildPath "Firefox Developer Edition.lnk") -ArgumentList "-url $($URLs)"
    }

    end {

    }
}

Function Send-MagicPacket {
    [OutputType('System.Void')]
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string]$Mac
    )

    begin {

    }

    process {
        Write-Host "Sending Magic Packet to $($Mac)"
        
        $Mac = $Mac.ToUpper()
        $MacByteArray = $Mac -split "[:-]" | ForEach-Object { [Byte] "0x$_"}
        [Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16)
        
        $UdpClient = New-Object System.Net.Sockets.UdpClient
        # right now port 7 is closed on FritzBox (not even for internal purposes)
        # How to open? See https://fritz.box/#secCheck
        $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),7)
        $UdpClient.Send($MagicPacket,$MagicPacket.Length) > $null
        $UdpClient.Close()
    }

    end {

    }
}

Function Get-UdpPacket {
    [OutputType('System.Void')]
    Param (
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [PSDefaultValue(Help='1998')]
        [string]$port = 1998,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [PSDefaultValue(Help='1 minute')]
        [int]$timeout = 1000 * 60 # 1 minute
    )

    begin {

    }

    process {
        Write-Host "Start listening to UDP..."

        $endpoint = New-Object System.Net.IPEndPoint ([IPAddress]::Any, $port)
        $udpclient = New-Object System.Net.Sockets.UdpClient $port
        $udpclient.Client.ReceiveTimeout = $timeout
        
        try {
            $content = $udpclient.Receive([ref]$endpoint)
        } catch {
            Write-Error -Category OperationTimeout -CategoryReason "Timeout" -CategoryTargetName "Configured Timeout" -CategoryTargetType "$($timeout)" -Message "The waiting for a UDP Message timed out." -RecommendedAction "Check if the server sends the correct data."
            return
        } finally {
            $UdpClient.Close()
        }
        
        $receivetimestamp = Get-Date -Format HH:mm:ss:ff
        Write-Host ""
        Write-Host "Paket received at $($receivetimestamp)"
        Write-Host "Sender: $($endpoint.tostring())"
        Write-Host "---- DATA ------"
        
        [string[]]$parsedContent = [System.Text.Encoding]::ASCII.GetString($content)
        Write-Host $parsedContent
        Write-Host ""
        
        if ($parsedContent -eq 'I am awake!') {
            Write-Host "Data contains the expected content. Now opening PuTTY." -ForegroundColor green
        }
        else {
            Write-Error -Category InvalidData -CategoryReason "No expected content" -CategoryTargetName "Searching for content" -CategoryTargetType " ""I am awake!""" -Message "The data did not contain the expected content. ABORTING FUNCTION" -RecommendedAction "Check if the server sends the correct data."
        }
    }

    end {

    }
}

Function Close-GUI {
    [OutputType('System.Void')]
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$serviceName,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$displayName
    )

    begin {

    }

    process {
        if (-Not $displayName) {
            $displayName = $serviceName
        }

        Write-Host "Closing GUI of $($displayName)"

        try {
            $process = Get-Process $serviceName
            $process.CloseMainWindow()
        } catch {
            Write-Host "No running process found for $($displayName). Skipping..." -ForegroundColor Yellow
        }
    }

    end {

    }
}

Function Get-DockerImage {
    [OutputType('string')]
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string]$Name
    )

    begin {

    }

    process {
        $images = docker images --format '{{.Repository}}:{{.Tag}}' | Where-Object { $_ -like "$Name*" }
        if (-not $images) {
            throw "No Docker images found matching '$Name'."
        } elseif ($images.Count -gt 1) {
            throw "Multiple Docker images found matching '$Name': $($images -join ', '). Please specify a more specific name."
        }

        return $images
    }

    end {

    }
}

Function Start-DockerContainer {
    [OutputType('System.Void')]
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string]$Image
    )

    begin {

    }

    process {
        docker run -d $Image
    }

    end {

    }
}