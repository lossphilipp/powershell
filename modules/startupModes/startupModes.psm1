$startMenuProgramData = "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\"
$startMenuAppData = "$Env:AppData\Microsoft\Windows\Start Menu\Programs\"
$startMenuWindowsApps = "$Env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\"

Function openFolder {
	param (
		[string]$Path
	)
	
	Invoke-Item $Path
	cd $Path
	ls
}

Function sendMagicPacket {
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

Function listenToUDP {
	param (
		[string]$port = 1998,
		[int]$timeout = 1000 * 60 # 1 minute
	)
	# 192.168.178.56 → 192.168.178.255
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

Function lop-start-serverconnection {
	[CmdletBinding()]
	param()
	
	sendMagicPacket -Mac 'EC:8E:B5:7B:C9:5C'
	
	$ping = Test-Connection -ComputerName 192.168.178.56 -Quiet -Count 1
	if ($ping) {
		Write-Host 'Ping succeded. Skip listening to UDP...'
	}
	else {
		listenToUDP
	}
	
	putty.exe -load 'ubuntu-server'
}

Function lop-start-fhv {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$vpn,
		[Parameter(Mandatory=$false)][switch]$zotero,
		[Parameter(Mandatory=$false)][switch]$datagrip
	)
	$fhvFolder = "$Env:FHV\Semester 5"
	
	# start Teams
	Start-Process -FilePath "$startMenuAppData\Microsoft Teams classic (work or school).lnk"
	
	# open Firefox to A5
	Start-Process -FilePath "$startMenuProgramData\Firefox Developer Edition.lnk" -ArgumentList '-url https://a5.fhv.at/de/index.php'
	
	# open folder
	openFolder($fhvFolder)
	
	if($vpn) {
		# open Cisco VPN Client
		Start-Process -FilePath "$startMenuProgramData\Cisco AnyConnect Secure Mobility Client.lnk"
	}
	
	if($zotero) {
		# open Zotero
		Start-Process -FilePath "$startMenuProgramData\Zotero.lnk"
	}
}

Function lop-start-gaming {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$multi,
		[Parameter(Mandatory=$false)][switch]$riot,
		[Parameter(Mandatory=$false)][switch]$steam
	)
	
	# start those programs: Logitech Gaming software & Armoury Crate
	Start-Process -FilePath "$startMenuProgramData\Logitech Gaming Software.lnk" -wait
	Start-Process -FilePath "$startMenuWindowsApps\ArmouryCrate.exe" -wait
	
	if($multi) {
		# open discord
		Start-Process -FilePath "$startMenuAppData\Discord.lnk"
	}
	
	if($riot) {
		# open riot client & U.GG Plugin
		Start-Process -FilePath "$startMenuProgramData\Riot Games\Riot Client.lnk"
		Start-Process -FilePath "$startMenuAppData\U.GG.lnk"
	}
	
	if($steam) {
		# open steam
		Start-Process -FilePath "$startMenuProgramData\Steam\Steam.lnk"
	}
	
	# then close different GUIs
	Write-Host 'Closing GUI of Logitech Gaming Software'
	$logitechProcess = Get-Process 'LCore'
	$logitechProcess.CloseMainWindow()
	
	Write-Host 'Closing GUI of ArmouryCrate'
	$armourycrateProcess = Get-Process 'ArmouryCrate'
	$armourycrateProcess.CloseMainWindow()
}

Function lop-start-coding {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$android,
		[Parameter(Mandatory=$false)][switch]$vscode,
		[Parameter(Mandatory=$false)][switch]$vs,
		[Parameter(Mandatory=$false)][switch]$docker
	)
	
	# start Git via Windows Terminal
	wt -p "Git Bash" -d $Env:Coding
	
	# open folder
	openFolder($Env:Coding)
	
	if($android) {
		# open Android Studio
		Start-Process -FilePath "$startMenuProgramData\Android Studio.lnk"
	}
	
	if($vscode) {
		# open Visual Studio Code
		Start-Process -FilePath "$startMenuProgramData\Visual Studio Code.lnk"
	}
	
	if($vs) {
		# open Visual Studio
		Start-Process -FilePath "$startMenuProgramData\Visual Studio 2022.lnk"
	}

	if($docker) {
		# open Docker Desktop
		Start-Process -FilePath "$Env:ProgramData\Microsoft\Windows\Start Menu\Docker Desktop.lnk"
	}
}

Function lop-start-vm {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$ubuntu,
		[Parameter(Mandatory=$false)][switch]$kali,
		[Parameter(Mandatory=$false)][switch]$whonix
	)
	# start Oracle VM VirtualBox
	Start-Process -FilePath "$startMenuProgramData\Oracle VM VirtualBox\Oracle VM VirtualBox.lnk" -wait
	
	if($ubuntu) {
		# open Ubuntu-VM
		VBoxManage startvm "Ubuntu"
	}

	if($kali) {
		# open Kali-Linux-VM
		VBoxManage startvm "Kali-Linux"
	}

	if($whonix) {
		# open Whonix incl. Gateway
		VBoxManage startvm "Whonix-Gateway-Xfce"
		VBoxManage startvm "Whonix-Workstation-Xfce"
	}
}

Function lop-start-ClubCompanion {
	[CmdletBinding()]
	param()

	# open Docker Desktop
	Start-Process -FilePath "$Env:ProgramData\Microsoft\Windows\Start Menu\Docker Desktop.lnk"

	# Open solution
	Start-Process -FilePath "$Env:Coding\clubcompanion_backend\server\ClubCompanion.sln"

	# open Firefox to Github Repository
	Start-Process -FilePath "$startMenuProgramData\Firefox Developer Edition.lnk" -ArgumentList '-url https://github.com/manuel-stadelmann/clubcompanion_backend'

	# run Postgres Container (docker daemon hopefully runs until now)
	docker start postgres-db
}

Function lop-start-Bachelorarbeit {
	[CmdletBinding()]
	param()

	$fhvFolder = "$Env:FHV\Bachelorarbeit"
	
	# start Teams
	Start-Process -FilePath "$startMenuAppData\Microsoft Teams classic (work or school).lnk"
	
	# start Word
	Start-Process -FilePath "$($fhvFolder)\Dispositionspapier_Bachelorarbeit.docx"
	
	# open Zotero
	Start-Process -FilePath "$startMenuProgramData\Zotero.lnk"

	# open folder
	openFolder($fhvFolder)
}

Function lop-help {
	[CmdletBinding()]
	param()
	
	$functions = @()
		$functions += [PSCustomObject]@{
		ModuleName = "lop-start-serverconnection   "
		Parameters = "-"
		Description = "Starts the server and opens a Putty session, as soon as it is booted."
	}

	$functions += [PSCustomObject]@{
		ModuleName = "lop-start-fhv"
		Parameters = "vpn, zotero, datagrip"
		Description = "Starts Teams, opens ilias (in Firefox) & opens folder"
	}

	$functions += [PSCustomObject]@{
		ModuleName = "lop-start-gaming"
		Parameters = "multi, riot, steam"
		Description = "Starts Logitech Gaming software & Armoury Crate"
	}

	$functions += [PSCustomObject]@{
		ModuleName = "lop-start-coding"
		Parameters = "android, vscode, vs"
		Description = "Starts Git & opens folder"
	}

	$functions += [PSCustomObject]@{
		ModuleName = "lop-start-vm"
		Parameters = "ubuntu, kali, whonix"
		Description = "Starts VirtualBox"
	}

	$functions += [PSCustomObject]@{
		ModuleName = "lop-start-ClubCompanion"
		Parameters = "-"
		Description = "Starts Docker (incl. Postgres Container), opens backend solution & opens Github repo"
	}
	
	$functions += [PSCustomObject]@{
		ModuleName = "lop-start-Bachelorarbeit"
		Parameters = "-"
		Description = "Opens the Word-document & Zotero and opens the folder"
	}

	$functions += [PSCustomObject]@{
		ModuleName = "lop-help"
		Parameters = "-"
		Description = "Displays all the available functions"
	}

	$functions | Sort-Object -Property ModuleName | Format-Table -AutoSize
}