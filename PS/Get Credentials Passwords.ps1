function Get-PasswordVaultCredentials {

#initilize empty array
$CRED_MANAGER_CREDS_LST = @()

try
{
#Load the WinRT projection for the PasswordVault
$Script:vaultType = [Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
$Script:vault = new-object Windows.Security.Credentials.PasswordVault -ErrorAction silentlycontinue

$Results = $Script:vault.RetrieveAll()
foreach($credentry in $Results)
{
$credobject = $Script:vault.Retrieve( $credentry.Resource, $credentry.UserName )
$obj = New-Object PSObject 
Add-Member -inputObject $obj -memberType NoteProperty -name "Username" -value "$($credobject.UserName)" 
Add-Member -inputObject $obj -memberType NoteProperty -name "Hostname" -value "$($credobject.Resource)" # URI need to be sanitised
Add-Member -inputObject $obj -memberType NoteProperty -name "Password" -value "$($credobject.Password)" 
$CRED_MANAGER_CREDS_LST += $obj 
}
}
catch
{
Write-Host "Failed to instantiate passwordvault class. $($_.InvocationInfo.PositionMessage)"
}
return $CRED_MANAGER_CREDS_LST
}
echo "OK"
Get-PasswordVaultCredentials
