cls;
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

function DecodeBin($bin){
$bin = $bin.Replace("SwBpAHIAYQBXAGgAaQB0AGUA","")
return $bin
}

function DecodeBase64Image {
    param ([Parameter(Mandatory=$true)][String]$ImageBase64)
    $ObjBitmapImage = New-Object System.Windows.Media.Imaging.BitmapImage
    $ObjBitmapImage.BeginInit()
    $ObjBitmapImage.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($ImageBase64)
    $ObjBitmapImage.EndInit()
    $ObjBitmapImage.Freeze()
    $ObjBitmapImage
}

function DEBUG.LOG($cmd){
if($cmd -eq "cls"){$Console.Text = ""}
else{
$cmd = $cmd.Replace("System.Windows.Controls.Button:","")
$Console.Text += $cmd
$Console.Text += "`n"
}
}

function DEBUG.NEWLOG($cmd){
$cmd = $cmd.Replace("System.Windows.Controls.Button:","")
$Console.Text = ""
$Console.Text += $cmd
$Console.Text += "`n"
}

function DEBUG.CLS{
$Console.Text = ""
}

$viewForm = @{
'working' = $false;
'reset' = $false;
}

#$bin = Get-Content "$pwd\data.bin"
$bin = Get-Content "\\MPC43\C$\Users\alexanderay\Documents\aa\data.bin"
$data = DecodeBin($bin)

$BackgroundImageBin = DecodeBase64Image $data[0]
$btn_close_imageBin_out = DecodeBase64Image $data[1]
$btn_close_imageBin_in = DecodeBase64Image $data[2]

do{

$viewForm.reset = $false

#[xml]$xaml = (Get-Content -Encoding UTF8 -Path "$pwd\menu.xml" -Raw) -replace 'x:Name','Name'
[xml]$xaml = (Get-Content -Encoding UTF8 -Path "\\MPC43\C$\Users\alexanderay\Documents\aa\menu.xml" -Raw) -replace 'x:Name','Name'
$xaml.Window.RemoveAttribute('x:Class')
$xaml.Window.RemoveAttribute('mc:Ignorable')
$xaml.SelectNodes("//*") | ForEach-Object {$_.RemoveAttribute('d:LayoutOverrides')}

$Reader = (New-Object System.Xml.XmlNodeReader $xaml) 
try{ 
$Form = [Windows.Markup.XamlReader]::Load($reader) 
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object { New-Variable -Name $_.Name -Value $Form.FindName($_.Name) -Force }
}
catch{Write-Host "Unable to load Windows.Markup.XamlReader";exit}

$User_Missing_Label.Visibility = "Hidden"
$Computer_Missing_Label.Visibility = "Hidden"
$btn_Opt3.Visibility = "Hidden"

$Form.Height = 278;

#$Form.Icon = DecodeBase64Image -ImageBase64 $TitleIcon

$BackgroundImage.Source = $BackgroundImageBin

$title.Content = "Tools v2 (WPF Version) by © אלכסנדר אייזין"

$btn_close_image.Source = $btn_close_imageBin_out

$btn_Opt1.Add_Click({

if($viewForm.working -eq $true){return}

$viewForm.working = $true

if($i_User.Text -eq ""){$User_Missing_Label.Visibility = "Visible";$viewForm.working = $false;return}

$UserProfileImage.Source = $nul
$UserDisplayName.Content = ""
$UserStatus.Content = ""
$UserStatus.Foreground = "Black"
$UserLogonDate.Content = ""
$UserID.Content=""
$UserMobile.Text = ""
$UserTelephone.Text = ""
$UserPersonalDir.Text = ""

$User_Missing_Label.Visibility = "Hidden"
Debug.newlog("LOADING DATA FROM SERVER...")
$Form.Height = 450;

DEBUG.CLS

$name = $i_User.Text

$userID ="";$userIDa ="";$userIDb ="";
if($name -and [Int32]::TryParse($name,[ref]$userID)){$userIDa = $name.Substring(0,$name.Length -1);$userIDb = $name.Substring($name.Length -1)}else{$userIDa = $name;$userIDb = "*"}
foreach ($dm in (Get-ADForest).Domains){
try{$pc_data_current_user = Get-ADUser -Server $dm -filter {
(SamAccountName -like $name) -or
(Name -like $name) -or
(DisplayName -like $name) -or
(EmailAddress -like $name) -or
((ExtensionAttribute15 -like $userIDa) -and (ExtensionAttribute14 -like $userIDb)) -or
(Mobile -like $name) -or
(MobilePhone -like $name) } -Properties *
if($pc_data_current_user){

Debug.log("שם מלא: "+$pc_data_current_user.DisplayName)

$UserProfileImage.Source = $pc_data_current_user.thumbnailPhoto

$UserDisplayName.Content = $pc_data_current_user.DisplayName
$i_User.Text = $pc_data_current_user.DisplayName

if($pc_data_current_user.LastActivityStatus -eq 3){
if($pc_data_current_user.Enabled){
if($pc_data_current_user.PasswordExpired){$UserStatus.Content = "פגה סיסמה";$UserStatus.Foreground = "Yellow"}
elseif($pc_data_current_user.LockedOut){$UserStatus.Content = "משתמש נעול";$UserStatus.Foreground = "Yellow"}
else{$UserStatus.Content = "משתמש פעיל";$UserStatus.Foreground = "Green"}}
else{$UserStatus.Content = "משתמש לא פעיל";$UserStatus.Foreground = "Red"}}
else{$UserStatus.Content = "סטטוס משבאי אנוש";$UserStatus.Foreground = "Black"}

$UserLogonDate.Content = $pc_data_current_user.LastLogonDate.ToString().Replace("AM","").Replace("PM","")

$UserID.Content = ($pc_data_current_user.extensionAttribute15 + $pc_data_current_user.extensionAttribute14)

$UserMobile.Text = $pc_data_current_user.mobile
if($UserMobile.Text){Debug.log("טל נייד: "+$pc_data_current_user.mobile)}
$UserTelephone.Text = $pc_data_current_user.OfficePhone
if($UserTelephone.Text){Debug.log("טל נייח: "+$pc_data_current_user.OfficePhone)}

$UserPersonalDir.Text = $pc_data_current_user.HomeDirectory

}}catch{$nul}}

$viewForm.working = $false

})

$btn_Opt2.Add_Click({

if($viewForm.working -eq $true){return}

$viewForm.working = $true

if($i_Computer.Text -eq ""){$Computer_Missing_Label.Visibility = "Visible";$viewForm.working = $false;return}

$Computer_Missing_Label.Visibility = "Hidden"
Debug.newlog("LOADING DATA FROM SERVER...")
if($Form.Height -ge 450 -and $Form.Height -le 450.5){$Form.Height = $Form.Height +1}else{$Form.Height = 450}

$pc_data = $i_Computer.Text;$pinfo = $nul;$pc_data_current_user = $nul
if($pc_data -match "^[\d\.]+$"){$ip = $pc_data;$pcn = (Get-WmiObject Win32_ComputerSystem -ComputerName $pc_data -ErrorAction SilentlyContinue).Name;if($pcn -eq $nul){Debug.newlog("מחשב לא נמצא לפי כתובת תחנה - $ip");$viewForm.working = $false;return}}
else{foreach($d in (Get-ADForest).Domains){try{$ip = [System.Net.Dns]::GetHostByName("$pc_data.$d").AddressList[0].IPAddressToString}catch{$nul};$pcn = $pc_data;}}
foreach($d in (Get-ADForest).Domains){try{$pinfo = Get-ADComputer -Identity $pcn -Server $d -Properties Description,OperatingSystem,ms-Mcs-AdmPwd,CanonicalName}catch{$nul}}

Debug.cls

$i_User.Text = ""
$UserProfileImage.Source = $nul
$UserDisplayName.Content = ""
$UserStatus.Content = ""
$UserStatus.Foreground = "Black"
$UserLogonDate.Content = ""
$UserID.Content=""
$UserMobile.Text = ""
$UserTelephone.Text = ""
$UserPersonalDir.Text = ""

if($ip){Debug.log("כתובת תחנה: "+$ip)}else{Debug.log("למחשב אין כתובת תחנה")}
Debug.log("שם מחשב: "+$pcn)
if($pinfo){Debug.log("מחשב: "+($pinfo.CanonicalName.Split('/')[3]).Replace('Floor','קומה'))}
if($pinfo.Description){Debug.log("מיקום: "+$pinfo.Description)}
if($pinfo.OperatingSystem){Debug.log("מערכת הפעלה: "+$pinfo.OperatingSystem)}
#if($pinfo."ms-Mcs-AdmPwd"){Debug.log("סיסמת אדמין: "+$pinfo."ms-Mcs-AdmPwd")}
if($ip){
$pc_data_current_user_raw = (Get-WMIObject -ClassName Win32_ComputerSystem -ComputerName $ip).Username
if($pc_data_current_user_raw -ne $nul){
Debug.log("שם משתמש: "+$pc_data_current_user_raw)
$pc_data_current_user_domain = if($pc_data_current_user_raw.Split("\")[0] -eq 'CLALIT'){"clalit.org.il"}else{$pc_data_current_user_raw.Split("\")[0] + ".clalit.org.il"}
$pc_data_current_user = Get-ADUser -Identity $pc_data_current_user_raw.Split("\")[1] -Server $pc_data_current_user_domain -Properties *

Debug.log("שם מלא: "+$pc_data_current_user.DisplayName)

$UserProfileImage.Source = $pc_data_current_user.thumbnailPhoto

$UserDisplayName.Content = $pc_data_current_user.DisplayName
$i_User.Text = $pc_data_current_user.DisplayName

if($pc_data_current_user.LastActivityStatus -eq 3){
if($pc_data_current_user.Enabled){
if($pc_data_current_user.PasswordExpired){$UserStatus.Content = "פגה סיסמה";$UserStatus.Foreground = "Yellow"}
elseif($pc_data_current_user.LockedOut){$UserStatus.Content = "משתמש נעול";$UserStatus.Foreground = "Yellow"}
else{$UserStatus.Content = "משתמש פעיל";$UserStatus.Foreground = "Green"}}
else{$UserStatus.Content = "משתמש לא פעיל";$UserStatus.Foreground = "Red"}}
else{$UserStatus.Content = "סטטוס משבאי אנוש";$UserStatus.Foreground = "Black"}

$UserLogonDate.Content = $pc_data_current_user.LastLogonDate.ToString().Replace("AM","").Replace("PM","")

$UserID.Content = ($pc_data_current_user.extensionAttribute15 + $pc_data_current_user.extensionAttribute14)

$UserMobile.Text = $pc_data_current_user.mobile
if($UserMobile.Text){Debug.log("טל נייד: "+$pc_data_current_user.mobile)}
$UserTelephone.Text = $pc_data_current_user.OfficePhone
if($UserTelephone.Text){Debug.log("טל נייח: "+$pc_data_current_user.OfficePhone)}

$UserPersonalDir.Text = $pc_data_current_user.HomeDirectory


}}

$viewForm.working = $false

})

$btn_Opt3.Add_Click({
Debug.newlog($btn_Opt3.Name)
})

$btn_Close.Add_MouseEnter({$btn_close_image.Source = $btn_close_imageBin_in})

$btn_Close.Add_MouseLeave({$btn_close_image.Source = $btn_close_imageBin_out})

$btn_Close.Add_Click({$Form.Close()})

$Form.add_MouseLeftButtonDown({$_.handled=$true;$this.DragMove()})

$Form.Add_KeyDown({if($viewForm.working -eq $false -and $_.Key -eq 'F12'){$viewForm.reset = $true;$Form.Close()}})

$v = "Test Version 2.22.10.04";$v;#$v | Out-File "$env:USERPROFILE\Desktop\TOOLS2_LOG.LOG" -Append

[void]$Form.ShowDialog()

}
while($viewForm.reset -eq $true)
