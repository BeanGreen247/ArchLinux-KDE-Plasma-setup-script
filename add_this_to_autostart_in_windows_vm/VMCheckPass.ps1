Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1

Write-Output "Applying registry tweaks"
Write-Output "Elevating privileges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

Set-Itemproperty "HKLM:\HARDWARE\DESCRIPTION\System" "SystemBiosVersion" "American Megatrends Inc. A.40 09/03/2023"