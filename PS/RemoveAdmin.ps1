$members = ((Get-LocalGroupMember -Group Administrators).Name | Where-Object { $_ -notlike 'NT AUTHORITY*' } | ForEach-Object { $_.Split('\')[1] })

$membersWithAdmin = @()
foreach ($member in $members)
{
	if ($member -ne "Administrator" -and $member -ne "admin" -and $member -ne "gaia")
	{
 		$membersWithAdmin += $member
 	}
}
foreach ($user in $membersWithAdmin )
{
	Remove-LocalGroupMember -Group Administrators -Member $user
}
