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

Function lop-start-fhv {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$vpn,
		[Parameter(Mandatory=$false)][switch]$zotero
	)
	$fhvFolder = "$Env:FHV\Semester 3"
	
	# start Teams
	Start-Process -FilePath "$startMenuAppData\Microsoft Teams.lnk"
	
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
	
	if($datagrip) {
		# open DataGrip
		Start-Process -FilePath "$startMenuProgramData\JetBrains\DataGrip 2022.1.4.lnk"
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
	Start-Process -FilePath "$startMenuProgramData\Logitech Gaming Software 9.02.lnk" -wait
	Start-Process -FilePath "$startMenuWindowsApps\ArmouryCrate.exe" -wait
	
	if($multi) {
		# open discord
		Start-Process -FilePath "$startMenuAppData\Discord.lnk"
	}
	
	if($riot) {
		# open riot client & Overwolf Plugin
		Start-Process -FilePath "$startMenuProgramData\Riot Games\Riot Client.lnk"
		Start-Process -FilePath "$startMenuAppData\Overwolf\U.GG.lnk"
	}
	
	if($steam) {
		# open steam
		Start-Process -FilePath "$startMenuProgramData\Steam.lnk"
	}
	
	# then close different GUIs
	Write-Host 'Closing GUI of Logitech Gaming Software'
	$logitechProcess = Get-Process 'LCore'
	$logitechProcess.CloseMainWindow()
	
	# Armoury Create has no MainWindow? Stopping process again makes no sense...
	#Write-Host 'Closing GUI of ArmouryCrate'
	#$armourycrateProcess = Get-Process 'ArmouryCrate'
	#Stop-Process $armourycrateProcess
}

Function lop-start-coding {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$android,
		[Parameter(Mandatory=$false)][switch]$vscode,
		[Parameter(Mandatory=$false)][switch]$vs
	)
	$codingFolder = 'C:\Users\phili\Coding-Projects'
	
	# start git
	Start-Process -FilePath "$startMenuProgramData\Git\Git Bash.lnk" -WorkingDirectory $codingFolder
	
	# open folder
	openFolder($codingFolder)
	
	if($android) {
		# open Android Studio
		Start-Process -FilePath "$startMenuProgramData\Android Studio.lnk"
	}
	
	if($vscode) {
		# open Visual Studio Code
		# Path not know, was never installed before
	}
	
	if($vs) {
		# open Visual Studio
		Start-Process -FilePath "$startMenuProgramData\Visual Studio 2022.lnk"
	}
}

Function lop-start-vm {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$ubuntu
	)
	# start Oracle VM VirtualBox
	Start-Process -FilePath "$startMenuProgramData\Oracle VM VirtualBox\Oracle VM VirtualBox.lnk" -wait
	
	if($ubuntu) {
		# open Ubuntu-VM
		VBoxManage startvm "Ubuntu"
	}
}

Function lop-help {
	[CmdletBinding()]
	param()
	
	$functions = @()
	
	$functions += [PSCustomObject]@{
        ModuleName = "lop-start-fhv"
		Parameters = "vpn, zotero, datagrip   "
        Description = "Starts Teams, opens ilias (in Firefox) & opens folder"

    }
	$functions += [PSCustomObject]@{
        ModuleName = "lop-start-gaming   "
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
		Parameters = "ubuntu"
        Description = "Starts VirtualBox"

    }
	$functions += [PSCustomObject]@{
        ModuleName = "lop-help"
		Parameters = "-"
        Description = "Displays all the available functions"

    }
	
	$functions | Sort-Object -Property ModuleName | Format-Table -AutoSize
}