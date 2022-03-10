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
		[Parameter(Mandatory=$false)][switch]$vpn,
		[Parameter(Mandatory=$false)][switch]$zotero
	)
	$fhvFolder = 'C:\Users\phili\OneDrive\Dokumente\FH Vorarlberg\Semester 2'
	
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
	
	#Then close different GUIs
	Write-Host 'Closing GUI of Logitech Gaming Software'
	$logitechProcess = Get-Process 'LCore'
	$logitechProcess.CloseMainWindow()
	
	#Armoury Create has no MainWindow so stopping Process of the GUI
	Write-Host 'Closing GUI of ArmouryCrate'
	$armourycrateProcess = Get-Process 'ArmouryCrate'
	Stop-Process $armourycrateProcess
}

Function lop-start-coding {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)][switch]$android,
		[Parameter(Mandatory=$false)][switch]$vscode,
		[Parameter(Mandatory=$false)][switch]$visual
	)
	$codingFolder = 'C:\Users\phili\Coding-Projects'
	
	#start git
	Start-Process -FilePath "$startMenuProgramData\Git\Git Bash.lnk" -WorkingDirectory $codingFolder
	
	# open folder
	openFolder($codingFolder)
	
	if($android) {
		# open Android Studio
		Start-Process -FilePath "$startMenuProgramData\Android Studio.lnk"
	}
	
	if($vscode) {
		# VS Code currently not installed
	}
	
	if($visual) {
		# open Visual Studio
		Start-Process -FilePath "$startMenuProgramData\Visual Studio 2022.lnk"
	}
}

Function lop-help {
	[CmdletBinding()]
	param()
	
	$functions = @()
	
	$functions += [PSCustomObject]@{
        ModuleName = "lop-start-fhv"
		Parameters = "vpn, zotero"
        Description = "Starts Teams, opens ilias (in Firefox) & opens folder"

    }
	$functions += [PSCustomObject]@{
        ModuleName = "lop-start-gaming"
		Parameters = "multi, riot, steam"
        Description = "Starts Logitech Gaming software & Armoury Crate"

    }
	$functions += [PSCustomObject]@{
        ModuleName = "lop-start-coding   "
		Parameters = "android, vscode, visual   "
        Description = "Starts Git & opens folder"

    }
	$functions += [PSCustomObject]@{
        ModuleName = "lop-help"
		Parameters = "-"
        Description = "Displays all the available functions"

    }
	
	$functions | Sort-Object -Property ModuleName | Format-Table -AutoSize
}