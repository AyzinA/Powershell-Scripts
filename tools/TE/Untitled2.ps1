
if($i_Computer.Text -eq ""){$Data_Output_Label.Visibility = "Visible";$Data_Output_Label.Content = "PC";$viewForm.working = $false;return}

$Data_Output_Label.Visibility = "Visible"
$Data_Output_Label.Content = "LOADING DATA FROM SERVER..."
if($Form.Height -ge 450 -and $Form.Height -le 450.5){$Form.Height = $Form.Height +1}else{$Form.Height = 450}
$Data_Output_Label.Visibility = "Hidden"

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



####################################






if($i_User.Text -eq ""){$Data_Output_Label.Visibility = "Visible";$Data_Output_Label.Content = "USER";$viewForm.working = $false;return}

$UserProfileImage.Source = $nul
$UserDisplayName.Content = ""
$UserStatus.Content = ""
$UserStatus.Foreground = "Black"
$UserLogonDate.Content = ""
$UserID.Content=""
$UserMobile.Text = ""
$UserTelephone.Text = ""
$UserPersonalDir.Text = ""

$Data_Output_Label.Visibility = "Visible"
$Data_Output_Label.Content = "LOADING DATA FROM SERVER..."
if($Form.Height -ge 450 -and $Form.Height -le 450.5){$Form.Height = $Form.Height +1}else{$Form.Height = 450}
$Data_Output_Label.Visibility = "Hidden"

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