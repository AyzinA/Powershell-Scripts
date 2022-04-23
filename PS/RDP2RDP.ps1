param ($pcname)
if(!$pcname){$pcname = Read-Host "Enter PC Name"};if(!$pcname){return}

$dll = @'
'@

$user = $env:USERDOMAIN + "\" + $env:USERNAME

$userdetails = New-Object System.Security.Principal.NTAccount($user)
$path = "\\" + $pcname + "\C$\Windows\System32\termsrv.dll"

$Acl = Get-Acl $path
$Acl.SetOwner($userdetails)
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$userdetails", "FullControl", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl -Path $path -AclObject $Acl

#DLL
$dllFile = "$env:TEMP\termsrv.dll"
$dllDecode = [System.Convert]::FromBase64String($dll)
[System.IO.File]::WriteAllBytes($dllFile,$dllDecode)

$dateCreated = Get-Date -Format "ddMMyyyy";$timeCreated = Get-Date -Format "HHmmss"

$newName = "termsrv.dll_" + $dateCreated + "_" + $timeCreated + ".bak";

Rename-Item $path $newName
 
$newPath = "\\" + $pcname + "\C$\Windows\System32\"

Copy-Item $dllFile $newPath
	
Get-Service "TermService" -ComputerName $pcname | Restart-Service -PassThru -Force

Write-Host "Done RDP2RDP on PC: $pcname"