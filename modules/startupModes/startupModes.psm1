$startMenuProgramData = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\'
$startMenuAppData = 'C:\Users\phili\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\'
$startMenuWindowsApps = 'C:\Users\phili\AppData\Local\Microsoft\WindowsApps\'

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
		[Parameter(Mandatory=$false)][switch]$vpn
	)
	$fhvFolder = 'C:\Users\phili\OneDrive\Dokumente\FH Vorarlberg\Semester 1'
	
	# start Teams
	Start-Process -FilePath (-join($startMenuAppData, 'Microsoft Teams.lnk'))
	
	# open Firefox to A5
	Start-Process -FilePath (-join($startMenuProgramData, 'Firefox Developer Edition.lnk')) -ArgumentList '-url https://a5.fhv.at/de/index.php'
	
	# open folder
	openFolder($fhvFolder)
	
	if($vpn) {
		# open Cisco VPN Client
		Start-Process -FilePath (-join($startMenuProgramData, 'Cisco AnyConnect Secure Mobility Client.lnk'))
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
	Start-Process -FilePath (-join($startMenuProgramData, 'Logitech Gaming Software 9.02.lnk')) -wait
	Start-Process -FilePath (-join($startMenuWindowsApps, 'ArmouryCrate.exe')) -wait
	
	if($multi) {
		# open discord
		Start-Process -FilePath (-join($startMenuAppData, 'Discord.lnk'))
	}
	if($riot) {
		# open riot client
		Start-Process -FilePath (-join($startMenuProgramData, 'Riot Games\Riot Client.lnk'))
	}
	if($steam) {
		# open steam
		Start-Process -FilePath (-join($startMenuProgramData, 'Steam.lnk'))
	}
	
	#Then close different GUIs
	Write-Host 'Closing GUI of Logitech Gaming Software'
	$logitechProcess = Get-Process 'LCore'
	$logitechProcess.CloseMainWindow()
	
	Write-Host 'Closing GUI of ArmouryCrate'
	$armourycrateProcess = Get-Process 'ArmouryCrate'
	$armourycrateProcess.CloseMainWindow()
	
	# close powershell
	Stop-Process -Id $PID
}

Function lop-start-coding {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$android,
		[Parameter(Mandatory=$false)][switch]$vscode
	)
	$codingFolder = 'C:\Users\phili\Coding-Projects'
	
	#start git
	Start-Process -FilePath (-join($startMenuProgramData, 'Git\Git Bash.lnk'))
	
	# open folder
	openFolder($codingFolder)
	
	if($android) {
		# open Android Studio
		Start-Process -FilePath (-join($startMenuProgramData, 'Android Studio.lnk'))
	}
	
	if($steam) {
		# VS Code currently not installed
	}
}

Function lop-help {
	[CmdletBinding()]
	param()
	
	$functions = @()
	
	$functions += [PSCustomObject]@{
        ModuleName = "lop-start-fhv"
		Parameters = "vpn"
        Description = "Starts Teams, opens ilias & changes folder (also in powershell)"

    }
	$functions += [PSCustomObject]@{
        ModuleName = "lop-start-gaming   "
		Parameters = "multi, riot, steam   "
        Description = "Starts Logitech Gaming software & Armoury Crate"

    }
	$functions += [PSCustomObject]@{
        ModuleName = "lop-start-coding"
		Parameters = "android, vscode"
        Description = "Starts Git & changes folder (also in powershell)"

    }
	$functions += [PSCustomObject]@{
        ModuleName = "lop-help"
		Parameters = "-"
        Description = "Displays all the available functions"

    }
	
	$functions | Sort-Object -Property ModuleName | Format-Table -AutoSize
}