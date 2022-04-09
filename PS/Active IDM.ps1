param ($name)
if(!$name){$name = Read-Host "Enter: User ID,Username,Email,User Full Name"};if(!$name){return}
$userID ="";$userIDa ="";$userIDb ="";
if($name -and [Int32]::TryParse($name,[ref]$userID)){$userIDa = $name.Substring(0,$name.Length -1);$userIDb = $name.Substring($name.Length -1)}else{$userIDa = $name;$userIDb = "*"}
foreach ($dm in (Get-ADForest).Domains){
try{$data = Get-ADUser -Server $dm -filter { SamAccountName -like $name -or displayname -like $name -or EmailAddress -like $name -or (extensionAttribute15 -like $userIDa -and extensionAttribute14 -like $userIDb) } -Properties *
if($data){

$ou = $data.CanonicalName.split('/')[1];if ($ou -eq 'Mehozot' -or $ou -eq 'Mokdim' -or $ou -eq 'Mosadot'){$ou = $data.CanonicalName.split('/')[2]}

$userData = @{
'User Type' = if($data.UserTypeName -eq "internal"){"Internal"}else{"External"}
'Full Name' = $data.CN
'User ID' = ($data.extensionAttribute15 + $data.extensionAttribute14)
'Username' =$data.SamAccountName
'OU' = $data.CanonicalName
'Domain' = `
if($ou -eq 'Center') {""}
else{$ou}
'Email' = $data.EmailAddress
'ACcount Enable' = if($data.Enabled -eq "True"){"true"}else{"false"}
'Account Locked' = if($data.LockedOut -eq "True"){"true"}else{"false"}
'HR Status' = $data.LastActivityName
'Password Expaierd' = if($data.PasswordExpired -eq "True"){"true"}else{"false"}
'Last Logon Date' = $data.LastLogonDate
'Home Directory' = $data.HomeDirectory
'Can be Found in Outlook' = if($data.showInAddressBook){"Can be Found"}else{if($data.EmailAddress){"Cannot be Found"}else{"user has no mail"}}
'Telephone' = $data.mobile
'Office Phone' = $data.OfficePhone
'KVS (mamber of)' = if($data.memberof | Select-String -Pattern 'KVS_*'){"User is mamber"}else{"not mamber"}
}
$dataTitle = $userData.'Username' +" - "+ $ou
$userData | ogv -Title "User Information - $dataTitle"
#$data
}}catch{$nul}}
