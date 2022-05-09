param ($pcname);if(!$pcname){$pcname = Read-Host "Enter PC Name"};if(!$pcname){return}

$user = $env:USERDOMAIN + "\" + $env:USERNAME
$userdetails = New-Object System.Security.Principal.NTAccount($user)

#
Get-Service UmRdpService -ComputerName $pcname | Stop-Service -PassThru -Force
Get-Service TermService -ComputerName $pcname | Stop-Service -PassThru -Force

$path = ("\\" + $pcname + "\C$\Windows\System32\termsrv.dll")
$termsrv_dll_acl = Get-Acl $path
Copy-Item $path ($path + ".copy")

$termsrv_dll_acl = Get-Acl $path
$termsrv_dll_acl.SetOwner($userdetails)
$termsrv_dll_ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$userdetails", "FullControl", "Allow")
$termsrv_dll_acl.SetAccessRule($termsrv_dll_ar)
Set-Acl $path $termsrv_dll_acl

#
$dll_as_bytes = Get-Content $path -Raw -Encoding byte
$dll_as_text = $dll_as_bytes.forEach('ToString', 'X2') -join ' ' 
$patternregex = ([regex]'39 81 3C 06 00 00(\s\S\S){6}')
$patch = 'B8 00 01 00 00 89 81 38 06 00 00 90'
$checkPattern=Select-String -Pattern $patternregex -InputObject $dll_as_text
If ($checkPattern -ne $null) {
$dll_as_text_replaced = $dll_as_text -replace $patternregex, $patch
}
Elseif (Select-String -Pattern $patch -InputObject $dll_as_text) {
Get-Service UmRdpService -ComputerName $pcname | Start-Service -PassThru
Get-Service TermService -ComputerName $pcname | Start-Service -PassThru
Write-Output 'The termsrv.dll file is already patch, exiting'
Exit
}
else {
Get-Service UmRdpService -ComputerName $pcname | Start-Service -PassThru
Get-Service TermService -ComputerName $pcname | Start-Service -PassThru
Write-Output "Pattern not found"
Exit
}

#
[byte[]] $dll_as_bytes_replaced = -split $dll_as_text_replaced -replace '^', '0x'
Set-Content ($path + ".patched") -Encoding Byte -Value $dll_as_bytes_replaced

#
fc.exe /b ($path + ".patched") $path

#
Rename-Item $path ("\\" + $pcname + "\C$\Windows\System32\termsrv.dll.original") -Force
Copy-Item ($path + ".patched") ($path +".rename") -Force
Rename-Item ($path +".rename") $path -Force
Set-Acl $path $termsrv_dll_acl

#
Get-Service UmRdpService -ComputerName $pcname | Start-Service -PassThru
Get-Service TermService -ComputerName $pcname | Start-Service -PassThru

#
Write-Host "Done RDP2RDP on PC: $pcname"
