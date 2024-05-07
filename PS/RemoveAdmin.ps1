$members = (Get-LocalGroupMembers -Group Administrators).Name | Where-Object { $_ -notlike 'NT AUTHORITY*' } | ForEach-Object { $_.Split('\')[1] }

$MembersToCheckAndRemoveAdmin = @()
foreach ($member in $members)
{
	if ($member -ne "Administrator" -And $member -ne "admin")
	{
 		$MembersToCheckAndRemoveAdmin += $member
 	}
}
foreach ($user in $MembersToCheckAndRemoveAdmin )
{
	Remove-LocalGroupMember -Group Administrators -Member $user
}
