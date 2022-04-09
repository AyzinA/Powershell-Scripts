$path = "FILE_PATH"

$mainDomain = "Main"
$mainEnd = ".com"

$userList = (get-acl -Path $path).Access | Select IdentityReference
foreach($user in $userList){
if($user.IdentityReference.ToString().Split("\")[0] -eq "clalit"){$D = $user.IdentityReference.ToString().Split("\")[0] + $mainEnd}
else{$D = $user.IdentityReference.ToString().Split("\")[0] + "." + $mainDomain + $mainEnd }
try{$U = (Get-ADUser -Identity $user.IdentityReference.ToString().Split("\")[1] -Server $D)
if($U){$U.Name}}
catch{$nul}}