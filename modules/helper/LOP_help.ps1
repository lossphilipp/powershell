########### Variables ##########

$startMenuProgramData = "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\"
$startMenuAppData = "$Env:AppData\Microsoft\Windows\Start Menu\Programs\"
$startMenuWindowsApps = "$Env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\"

########### Functions ##########

Function Open-Folder {
    param (
        [string]$Path
    )
    
    Invoke-Item $Path
    Set-Location $Path
    Get-ChildItem
}

Function Send-MagicPacket {
    param (
        [string]$Mac
    )
    
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

Function Listen-UDP {
    param (
        [string]$port = 1998,
        [int]$timeout = 1000 * 60 # 1 minute
    )
    Write-Host "Start listening to UDP..."

    $endpoint = New-Object System.Net.IPEndPoint ([IPAddress]::Any, $port)
    $udpclient = New-Object System.Net.Sockets.UdpClient $port
    $udpclient.Client.ReceiveTimeout = $timeout
    
    try {
        $content = $udpclient.Receive([ref]$endpoint)
        $UdpClient.Close()
    }
    catch {
        $UdpClient.Close()
        Write-Error -Category OperationTimeout -CategoryReason "Timeout" -CategoryTargetName "Configured Timeout" -CategoryTargetType "$($timeout)" -Message "The waiting for a UDP Message timed out." -RecommendedAction "Check if the server sends the correct data."
    }
    
    if ($content) {
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
}

Function Close-GUI {
    param (
        [Parameter(Mandatory=$true)][string]$serviceName,
        [Parameter(Mandatory=$false)][string]$displayName
    )
    
    if (-Not $displayName) {
        $displayName = $serviceName
    }
    
    Write-Host "Closing GUI of $($displayName)"
    $process = Get-Process $serviceName
    $process.CloseMainWindow()
}