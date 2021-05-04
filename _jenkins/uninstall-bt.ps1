$pmAdapter = Get-WmiObject -Namespace root/CIMV2 -ClassName Win32_Product | Where-Object {$_.Name -like "Privilege Management Console Adapter*"}
if ($null -ne $pmAdapter) {
    $pmAdapter.Uninstall().returnvalue
}
else {
    Write-Output "Privilege Management Console Adapter is not installed..."
}

$pmApp = Get-WmiObject -Namespace root/CIMV2 -ClassName Win32_Product | Where-Object {$_.Name -like "Privilege Management for Windows*"}
if ($null -ne $pmApp) {
    $pmApp.Uninstall().returnvalue
}
else {
    Write-Output "Privilege Management for Windows is not installed..."
}