$path = "$env:USERPROFILE\Desktop\UserList.txt"
$password = ConvertTo-SecureString -AsPlainText “Aa123456!” -Force 

ForEach ($user in Get-Content -Path $path) 
{
    Get-ADUser $user | Set-ADAccountPassword -NewPassword $password -Reset
    Get-ADUser $user | Set-AdUser -ChangePasswordAtLogon $true
} 