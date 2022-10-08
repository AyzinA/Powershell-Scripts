#region Setting

cls;
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

#endregion
#region Functions

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

#endregion
#region User

$appUser = "TEST" # (Get-ADUser $env:UserName -Properties DisplayName).DisplayName

#endregion
#region Base64Load-bin

$bin = Get-Content "$pwd\data.bin"
$data = DecodeBin($bin)

$bgImage = DecodeBase64Image $data[0]
$temp_Signature = $data[1]
$xImageOut = DecodeBase64Image $data[2]
$xImageIn = DecodeBase64Image $data[3]

#endregion
#region Refrashs

[xml]$xaml = Get-Content -Encoding UTF8 -Path "$pwd\menu.xml"

$Reader = (New-Object System.Xml.XmlNodeReader $xaml)  
$Form = [Windows.Markup.XamlReader]::Load($reader) 

$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object { New-Variable -Name $_.Name -Value $Form.FindName($_.Name) -Force }

#$Form.Icon = DecodeBase64Image -ImageBase64 $TitleIcon

$BackgroundImage.Source = $bgImage

$title.Content = "Tools v2 (WPF Version) by © אלכסנדר אייזין"

$btn_close_image.Source = $xImageOut

$pnia.Text = $appUser

$MATAK4800.IsEnabled="False"
$MATAK4800.Content="False"

#region חתימה לנציג

#Mail Signature
$SignatureFile = "$env:TEMP\Signature.png"
$SignatureDecode = [System.Convert]::FromBase64String($temp_Signature)
[System.IO.File]::WriteAllBytes($SignatureFile,$SignatureDecode)

$sing='
<p class=MsoNormal dir=RTL><SPAN lang=HE style="FONT-SIZE: 12pt; FONT-FAMILY: Arial,sans-serif; COLOR: #1f497d">בברכה,</SPAN><br><br>
<SPAN lang=HE style="FONT-SIZE: 12pt; FONT-FAMILY: Arial,sans-serif; COLOR: #1f497d"><b>'+ $appUser +'</b><?xml:namespace prefix = "o" ns = "urn:schemas-microsoft-com:office:office" /><o:p></o:p></SPAN><br>
<SPAN lang=HE style="FONT-SIZE: 12pt; FONT-FAMILY: Arial,sans-serif; COLOR: #1f497d">תומך מחשוב <B>|</B>&nbsp;מוקד מש"ל<?xml:namespace prefix = "o" ns = "urn:schemas-microsoft-com:office:office" /><o:p></o:p></SPAN><br><br>
<SPAN lang=HE style="FONT-SIZE: 12pt; FONT-FAMILY: Arial,sans-serif; COLOR: #1f497d">&nbsp;1700-707-207 <B>| </B><A href="mailto:CustomerServices@clalit.org.il"><SPAN lang=EN-US style="COLOR: #0563c1" dir=ltr>CustomerServices@clalit.org.il</SPAN></A><B><?xml:namespace prefix = "o" ns = "urn:schemas-microsoft-com:office:office" /><o:p></o:p></B></SPAN><br>
<SPAN lang=HE style="FONT-SIZE: 12pt; FONT-FAMILY: Arial,sans-serif; COLOR: #1f497d">מחלקת תפעול <B>| </B>חטיבת מערכות מידע ודיגיטל <B>| </B>הנהלה ראשית </SPAN><br>
<span dir=LTR><img border=0 width=444 height=76 style="width:4.625in;height:.7916in" id="תמונה_x0020_1" src="cid:Signature.png"></span></p>
'


$Send.Add_Click({

$o = New-Object -com Outlook.Application
$mail = $o.CreateItem(0)

$mail.subject = "חתימת נציג"
$mail.HTMLBody = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title></title>
</head><body>

'+$sing+'

</body></html>'

#$mail.Attachments.Add("file")

$mail.Attachments.Add($SignatureFile,0,0)
$mail.SentOnBehalfOfName = "CustomerServices@clalit.org.il"
$mail.Recipients.Add($data.emailaddress)
$mail.CC = "CustomerServices@clalit.org.il;shaytal@clalit.org.il;danielaei@clalit.org.il;tomerche@clalit.org.il"
$mail.Display()
})

#endregion
#region Option1 // Find Computer Information | מצה מידע על המחשב
$btn_Opt1.Add_Click({
cls;
Write-Host "$btn_Opt1"
$name = $d_Input.Text
if($name -match "^[\d\.]+$"){$ip = $name;$pcn = (Get-WmiObject Win32_ComputerSystem -ComputerName $name).Name;}
else{foreach($d in (Get-ADForest).Domains){try{$ip = [System.Net.Dns]::GetHostByName("$name.$d").AddressList[0].IPAddressToString}catch{$nul};$pcn = $name;}}
foreach($d in (Get-ADForest).Domains){try{$pinfo = Get-ADComputer -Identity $pcn -Server $d -Properties Description,OperatingSystem,ms-Mcs-AdmPwd,CanonicalName}catch{$nul}}
#(Get-WMIObject -ClassName Win32_ComputerSystem -ComputerName $name.$d).Username

Debug.cls

Debug.log("כתובת תחנה: "+$ip)
Debug.log("שם מחשב: "+$pcn)
Debug.log("קומה: "+($pinfo.CanonicalName.Split('/')[3]).Replace('Floor','קומה'))
Debug.log("מיקום: "+$pinfo.Description)
Debug.log("מערכת הפעלה: "+$pinfo.OperatingSystem)
Debug.log("סיסמת אדמין: "+$pinfo."ms-Mcs-AdmPwd")

})
#endregion
#region Option2 //
$btn_Opt2.Add_Click({
Debug.log($btn_Opt2.Name)
})

$btn_Opt3.Add_Click({
Debug.newlog($btn_Opt3.Name)
})
#endregion
#region כפתור סגור

$btn_Close.Add_MouseEnter({$btn_close_image.Source = $xImageIn})

$btn_Close.Add_MouseLeave({$btn_close_image.Source = $xImageOut})

$btn_Close.Add_Click({$Form.Close()})

#endregion
#region הגדרות נוספות

$Form.add_MouseLeftButtonDown({$_.handled=$true;$this.DragMove()})
 
#endregion 

#endregion
#region Start

$v = "Test Version 2.22.10.04";$v;$v | Out-File "$env:USERPROFILE\Desktop\TOOLS2_LOG.LOG" -Append

[void]$Form.ShowDialog()

#endregion

