$scriptDir = Join-Path -Path $env:SystemDrive -ChildPath 'scripts'
$appDir = Join-Path -Path $scriptDir -ChildPath "applist"
Set-Location -Path $scriptDir

$time = Get-Date -Format yyyy-MMM-dd_HH-mm-ss
$appsList = New-Item -Path $appDir\$time.txt -ItemType File
$apps = Join-Path -Path $appDir -ChildPath $appsList
Write-Verbose "Created file '$apps'."

$appsInt = choco list --source=ChocolateyInternal | Select-Object -Skip 1 | Select-Object -SkipLast 1 

foreach ($app in $appsInt) {
    $appSplit = $app.split(" ")
    $name =  $appSplit[0]
    $appVersion =  $appSplit[1]
    $chocoRepo = choco info $name --source='chocolatey' | Select-Object -Skip 1 | Select-Object -First 1
    $chocoSplit = ($chocoRepo.ToString()).Split(" ")
    $chocoVersion =  $chocoSplit[1]
        if ($chocoVersion -ne "packages"){
            if ($appVersion -eq $chocoversion) {
                Write-Verbose "$name is up-to-date on version $chocoVersion"
            }
            else {
                Write-Verbose "$name is out-of-date on version $appVersion new version is $chocoVersion adding to list now."
                $name | Out-File -FilePath $apps -Append
            }
        }
        else {
            Write-Output "Failed to download package '$name'"
        }
}