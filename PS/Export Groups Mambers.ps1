Function Get-FileNameG($initialDirectory)
{   
[System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”) |
Out-Null

$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = "Pick File With Group Names"
$OpenFileDialog.initialDirectory = "$env:USERPROFILE\Desktop" #$initialDirectory
$OpenFileDialog.filter = “Text File Only | *.txt”
$OpenFileDialog.ShowDialog() | Out-Null
$OpenFileDialog.filename
} 

$InputFile = Get-FileNameG

if($InputFile -eq ""){ return }

foreach($Group in Get-Content $InputFile){
    foreach($Domain in (Get-ADForest).Domains){
        try{
            $G = Get-ADGroupMember -Identity $Group -Server $Domain | Get-ADuser -Properties Name,SamAccountName,Emailaddress | Select Name,SamAccountName,Emailaddress
            if($G){
                if((Test-Path "$env:USERPROFILE\Desktop\PS") -eq $False){
                    New-Item -Path "$env:USERPROFILE\Desktop\" -Name "PS" -ItemType Directory
                }
                $GFN = $Domain.Split(".")[0] + "_" + $Group
                $G | Export-Csv "$env:USERPROFILE\Desktop\PS\$GFN.csv" -Force -NoTypeInformation -Encoding UTF8
            }
        }
        catch {$nul}
    }
}