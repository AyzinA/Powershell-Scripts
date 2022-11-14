########################################################
#                                                      #
#   Get Group Names by User Name                       #
#                                                      #
#                             code by alexander ayzin  #
#                                                      #
########################################################

$u = Read-Host 'Enter User Name'
foreach($d in (Get-ADForest).Domains){try{foreach($g in (Get-ADUser -Identity $u -Server $d -Properties memberof).memberof){($g.split("=")[1].split(",")[0]).Replace("\","")}}catch{$nul}}