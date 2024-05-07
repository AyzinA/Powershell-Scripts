$members = ((Get-LocalGroupMember -Group Administrators).Name | Where-Object { $_ -notlike 'NT AUTHORITY*' } | ForEach-Object { $_.Split('\')[1] })

$membersWithAdmin = @()
foreach ($member in $members)
{
	if ($member -ne "Administrator" -And $member -ne "admin")
	{
 		$membersWithAdmin += $member
 	}
}
foreach ($user in $membersWithAdmin )
{
	Remove-LocalGroupMember -Group Administrators -Member $user
}
