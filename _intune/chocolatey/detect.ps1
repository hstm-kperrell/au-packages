$app = "C:\ProgramData\chocolatey\choco.exe"
$install = Test-Path -Path $app

if ($null -ne $install) {
    $update = choco outdated | Select-String $app
        if ($null -eq $update) {
            Write-Output "Installed"
        }
}