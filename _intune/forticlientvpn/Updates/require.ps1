$app = "forticlientvpn"
$update = choco outdated | Select-String $app

if ($null -ne $update) {
    Write-Output "Out-of-Date"
}