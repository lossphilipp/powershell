Function NeedsElevation {
    $Elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ( -not $Elevated ) {
        throw "This Script requires that PowerShell is running with admin rights!"
    }
}

$nonGamingProcesses = @(
	"Calculator",
	"Cortana",
	"OfficeClickToRun",
	"SearchIndexer",
	"Microsoft.Photos",
	"SearchApp",
	"spoolsv",
	"vpnagent"
)

# services from old laptop. Outdated?
$nonGamingServices = @(
	"AarSvc_6fa65",
	"CDPUserSvc_6fa65",
	"bthserv",
	"vpnagent",
	"DiagTrack",
	"DoSvc",
	"lfsvc",
	"ibtsiva",
	"Spooler",
	"ss_conn_service",
	"ss_conn_service2",
	"OneSyncSvc_6fa65",
	"UsoSvc",
	"wuauserv"
)

Function buschGaming {
	param(
		[Parameter(Mandatory=$true)][switch]$startOrStop
	)
	
	if($startOrStop-mode -eq 'start') {
		Write-Host "Computer gets prepared for gaming mode. Please wait..."
		
		$processesToKill = @()
		foreach($nonGamingProcess in $nonGamingProcesses) {
			Get-Process | Where-Object { $_.Name.Equals($nonGamingProcess) } | ForEach-Object {
				$processesToKill += $_.Id
				Write-Host $processesToKill
			}
		}
		foreach($process in $processesToKill) {
			Write-Host "Killing Process $($process)..."
			Stop-Process -Id $process -Force -Confirm:$false -ErrorAction SilentlyContinue
		}
		
		foreach($service in $nonGamingServices) {
			Write-Host "Stopping Service $($service.name)..."
			Stop-Service -Name $service.name -Force -Confirm:$false -ErrorAction SilentlyContinue
		}

		Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Green
		Write-Host "Everything finished! Let's start gaming!" -ForegroundColor Green
		Write-Host "Don't forget to stop this mode afterwards!" -ForegroundColor Red
	} elseif($startOrStop-mode -eq 'stop') {
		Write-Host "Computer safety option will be restored. Please wait..."

		foreach($service in $nonGamingServices) {
			Write-Host "Starting Service $($service)..."
			Start-Service -Name $service -Confirm:$false -ErrorAction SilentlyContinue
		}
		
		foreach($process in $nonGamingProcesses) {
			Write-Host "Starting Process $($process)..."
			Start-Process -Id $process -Confirm:$false -ErrorAction SilentlyContinue
		}

		Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Green
		Write-Host "Everything finished! Computer integrity restored." -ForegroundColor Green
	} else {
		Write-Host "No valid argument added. Possible values are ""start"" and ""stop""."
	}
}