$app = "forticlientvpn"
$install = choco list -localonly | Select-String $app

if ($null -ne $install) {
    $update = choco outdated | Select-String $app
        if ($null -eq $update) {
            Write-Output "Updated"
        }
}