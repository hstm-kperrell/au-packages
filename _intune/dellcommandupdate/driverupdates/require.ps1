$make = (Get-CimInstance -Namespace root/CIMV2 -ClassName Win32_ComputerSystem | Select-Object Manufacturer).Manufacturer

if ($make -like "*Dell*") {
    Write-Output "Dell"
}