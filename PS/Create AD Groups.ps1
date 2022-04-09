#name	scope	category	description	manager

#HE|EN	scope*	category*	HE|EN	    USERNAME

#scope     : DomainLocal | Global | Universal

#category  : Security    | Distribution

$path = "FILE_PATH"

$managerUsername = "USERNAME"

#$lines = @()

$lines = Import-Csv $path 

#$lines += @{ Name = "1"; GroupScope = "Universal"; GroupCategory = "Security"; Description = "5"; ManagedBy  = "" }
#$lines += @{ Name = "2"; GroupScope = "Universal"; GroupCategory = "Security"; Description = "4"; ManagedBy  = "" }
#$lines += @{ Name = "3"; GroupScope = "Universal"; GroupCategory = "Security"; Description = "3"; ManagedBy  = "" }
#$lines += @{ Name = "4"; GroupScope = "Universal"; GroupCategory = "Security"; Description = "2"; ManagedBy  = "" }
#$lines += @{ Name = "5"; GroupScope = "Universal"; GroupCategory = "Security"; Description = "1"; ManagedBy  = "" }

$manager = Get-ADUser -Identity $managerUsername

foreach ($group in $lines) {

    New-ADGroup -Name $group.Group -DisplayName $group.Display -Path "OU=Groups,OU=Center,DC=clalit,DC=org,DC=il" -GroupScope Universal -GroupCategory Security -ManagedBy $manager
}
