cls;$b = @();$g = Read-Host 'Enter Folder Path';$userList = (get-acl -Path $g).Access | Select IdentityReference,FileSystemRights
foreach($user in $userList){if($user.IdentityReference.ToString().Split("\")[0] -eq "clalit"){$D = $user.IdentityReference.ToString().Split("\")[0] + ".org.il"}
else{$D = $user.IdentityReference.ToString().Split("\")[0] + ".clalit.org.il"}try{$U = (Get-ADUser -Identity $user.IdentityReference.ToString().Split("\")[1] -Server $D)
if($U){$b += $U.Name + " ( " + $U.SamAccountName +" ) יש הרשאות " + $user.FileSystemRights.ToString().Split(",")[0]}}catch{$nul}};
"שלום רב,";"";"לנתיב $g";"";"יש גישה ל:";$b