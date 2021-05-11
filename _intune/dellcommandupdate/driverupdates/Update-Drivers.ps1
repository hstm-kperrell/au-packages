function Write-Log {
    param (
        [String]$level,
        [string]$message
    )
    switch ($level) {
        "info" { Write-Host $message -ForegroundColor White  }
        "success" { Write-Host $message -ForegroundColor Green }
        "error" { Write-Host $message -ForegroundColor Red }
        "warning" { Write-Host $message -ForegroundColor Yellow }
    }
    $message | Out-File -FilePath $log -Append
}
function Set-ConsoleTitle {
	Param ([String]$Title)
	$host.ui.RawUI.WindowTitle = $Title
}
function Get-CommandUpdate {
	#Declare Local Variables
	Set-Variable -Name CommandUpdate -Scope Local -Force
	
    $dcu64 = "$env:ProgramFiles\Dell\CommandUpdate\dcu-cli.exe"
    $dcu86 = "${env:ProgramFiles(x86)}\Dell\CommandUpdate\dcu-cli.exe"
    
    if((Test-Path -Path $dcu64) -eq $true) {
        $CommandUpdate = $dcu64
    }

    if((Test-Path -Path $dcu86) -eq $true) {
        $CommandUpdate = $dcu86
    }

	Return $CommandUpdate
	
	#Cleanup Local Variables
	#Remove-Variable -Name CommandUpdate -Scope Local -Force
}
function Install-Updates {
	Param (
        [String]$DisplayName,
		[String]$Executable,
		[String]$Switches)
	
	#Declare Local Variables
	Set-Variable -Name ErrCode -Scope Local -Force
	
    Write-Log -level info "[INFO]: $DisplayName"
	if ((Test-Path $Executable) -eq $true) {
        Write-Log -level info "[INFO]: Starting the $Executable process."
		$ErrCode = (Start-Process -FilePath $Executable -ArgumentList $Switches -Wait -Passthru).ExitCode
	} 
    else {
		$ErrCode = 1
        Write-Log -level error "[ERROR]: Failed to start $executable"
	}
	if (($ErrCode -eq 0) -or ($ErrCode -eq 3010) -or ($ErrCode -eq 500) -or ($ErrCode -eq 104)) {
		Write-Log -level success "[SUCCESS]: Process finihed with code: $ErrCode"
	} 
    elseif ($ErrCode -eq 5) {
        Write-Log -level warning "[WARNING]: A reboot is pending on this system finished with code: $ErrCode"
    }
    else {
        Write-Log -level error "[ERROR]: Failed with error code $ErrCode"
	}
	
	#Cleanup Local Variables
	#Remove-Variable -Name ErrCode -Scope Local -Force
}

$title          = "Dell Command Update Configuration"
$ext            = (Split-Path -Path $MyInvocation.MyCommand.Path -Leaf) -replace '\.ps1'
$time           = Get-Date -Format yyyy-MM-dd_HH-mm-ss_Local
$logDir         = "C:\PowerShell\Logs\"
$file           = '{0}_{1}_{2}.log' -f $serialNumber, $ext, $time
$log            = Join-Path -Path $logDir -ChildPath $file
$CommandUpdate  = Get-CommandUpdate
$regKey         = "HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG"
$regValue       = "ShowSetupPopUp"
$dellLogDir     = "C:\Dell\Logs"
$dellLogFile    = "C:\Dell\Logs\DellCommandUpdate.log"
$configure      = "/configure -scheduleAction=DownloadInstallAndNotify -scheduleAuto -autoSuspendBitLocker=enable -scheduledReboot=60 -lockSettings=enable"
$scan           = "/scan -silent -outputLog=$dellLogFile"
$update         = "/applyUpdates -silent -outputLog=$dellLogFile"

try {
    Write-Log -level info "[INFO]: ========== START OF LOG =========="
    Write-Log -level info "[INFO]: Looking for the directory $logDir"
    Get-Item -Path $logDir -ErrorAction Stop
    Write-Log -level success "[SUCCESS]: Found directory $logDir"
} # Looking for directory.

catch [System.Exception] {
    New-Item -Path $logDir -ItemType Directory
    Write-Log -level warning "[WARNING]: $logDir is missing."
    Write-Log -level info "[INFO]: Creating directory $logDir"
    Write-Log -level success "[SUCCESS]: Created $logDir"
} # Directory missing creating the directory
    
finally {
    Write-Log -level success "[SUCCESS]: Logging check and working directory setup is completed"
    Write-Log -level info "=============================="
    Set-ConsoleTitle -Title $title
    Write-Log -level info "[INFO]: $title is starting now."
    Write-Log -level info "[INFO]: Checking if Dell Command Update is installed."
    if ($null -ne $CommandUpdate) {
        Write-Log -level info "[INFO]: Checking $regKey\$regValue"
        if ((Get-ItemProperty -Path Registry::$regKey -Name $regValue -ErrorAction SilentlyContinue) -eq 0) {
            Write-Log -level info "[INFO]: $regValue is already set to 0."
        }
        else {
            Write-Log -level info "[WARNING]: $regValue is not set to 0."
            Write-Log -level info "[WARNING]: Setting $regValue to 0."
            New-ItemProperty -Path Registry::$regKey -Name $regValue -PropertyType "DWORD" -Value "0" -Force
            Write-Log -level success "[SUCCESS]: $regValue is now set to 0."
        }
        Write-Log -level info "[INFO]: Checking for the Dell Logs Directory."
        if((Test-Path -Path $dellLogDir) -eq $true) {
            if ((Test-Path -Path $dellLogFile) -eq $true) {
                Remove-Item -Path $dellLogFile -Force
            }
            Install-Updates -DisplayName "Dell Command Updates | Updates" -Executable $CommandUpdate -Switches $configure
            Install-Updates -DisplayName "Dell Command Updates | Updates" -Executable $CommandUpdate -Switches $scan
            Install-Updates -DisplayName "Dell Command Updates | Updates" -Executable $CommandUpdate -Switches $update

        }
        else {
            New-Item -Path $dellLogDir -ItemType Directory -Force
            Install-Updates -DisplayName "Dell Command Updates | Updates" -Executable $CommandUpdate -Switches $configure
            Install-Updates -DisplayName "Dell Command Updates | Updates" -Executable $CommandUpdate -Switches $scan
            Install-Updates -DisplayName "Dell Command Updates | Updates" -Executable $CommandUpdate -Switches $update
        
        }
        if ((Test-Path -Path $dellLogFile) -eq $true) {
            Write-Log -level success "[SUCCESS]: $title as finished a reboot is required."
            [System.Environment]::Exit(3010)
        }
        else {
            Write-Log -level error "[ERROR]: $title has failed."
            [System.Environment]::Exit(1)
        }
    }
    else {
        Write-Log -level error "[ERROR]: Dell Command Update is missing from this system."
        [System.Environment]::Exit(1)
    }
}