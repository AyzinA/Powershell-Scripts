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

$viewForm = @{
'working' = $false;
'reset' = $false;
}

#$bin = Get-Content "$pwd\data.bin"
$bin = (
"iVBORw0KGgoAAAANSUhEUgAAAPoAAAAdCAYAAACDrXEHAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAADiSURBVHhe7dzBicJAAIbRuGoH24vYjMIe3A62CDvQg2A1Yi92oOsuCQNi9KagzP/eKTOHnPIxk8BkMBzN/hqgal3ov5tlGQK1GX79XEJfTT7KNFCL7/35OnSgTm3olnEI4GMcBOhC3x3WZQjUZvq5sHWHBEKHADdb93aZ5314rcrzjAb7Td8N/XTclhGvNBrPhR7o0Qb7z017P1t3CCB0CCB0CCB0CCB0CCB0CCB0CCB0CCB0CCB0CCB0CCB0CCB0CCB0COA8+ptzTDXPMxrsN+2fcVA559EhRLeil2ugSk3zD7fXQnx0vTpKAAAAAElFTkSuQmCC",
"iVBORw0KGgoAAAANSUhEUgAASwBpAHIAYQBXAGgAaQB0AGUAABQAAAAUCAYAAACNiR0NAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAACYSURBVDhPzdQ9DoAgDIBR9Ajujt7/QI7uXkGtoQ3QXwyDX2J0gJcSjdP1lAY25/uwCDzX7b16a/exCXtQaS2By7Hnpxharin3VhNGUQ2D2JE91MIgBkIa6mGQ+R1KE0IaBokTYtJGC4NM8Esm6L0UKRVsX0B5VAsVwRbDIigDNQzz0Ar0MMxCCYximIayI0cwTFr79z92SjfZIFXaNnJopgAAAABJRU5ErkJggg==",
"iVBORw0KGgoAAAANSUhEUgAASwBpAHIAYQBXAGgAaQB0AGUAABQAAAAUCAYAAACNiR0NAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAACYSURBVDhPzdTNDYAgDIBRdDhncBfP7uIMLqfW0AboL4aDX2L0AC8lGqfrKQ1szvdhEXhu63v11u5jE/ag0loCl/3ITzG0XFPurSaMohoGsSN7qIVBDIQ01MMg8zuUJoQ0DBInxKSNFgaZ4JdM0HspUirYvoDyqBYqgi2GRVAGahjmoRXoYZiFEhjFMA1lR45gmLT273/slG6voVdOzzFhmQAAAABJRU5ErkJggg==")
$data = DecodeBin($bin)

$BackgroundImageBin = DecodeBase64Image $data[0]
$btn_close_imageBin_out = DecodeBase64Image $data[1]
$btn_close_imageBin_in = DecodeBase64Image $data[2]

do{

$viewForm.reset = $false

#[xml]$xaml = (Get-Content -Encoding UTF8 -Path "$pwd\menu.xml" -Raw) -replace 'x:Name','Name'
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Tools V2 Mini" Width="250" Height="29" ResizeMode="NoResize"
		Topmost="true" WindowStartupLocation="CenterScreen"
        WindowStyle="None" AllowsTransparency="true" Background="Transparent">
        <!-- #CAF0F8 --> <!-- #90E0EF --> <!-- #00B4D8 --> <!-- #0077B6 --> <!-- #03045E -->
    <Grid>
        <Image Name="BackgroundImage" VerticalAlignment="Top" HorizontalAlignment="Left" Width="250" Height="29"/>
        <TextBox Name="i_Computer" VerticalAlignment="Top" HorizontalAlignment="Left" Margin="4,8,0,0" Width="100" Text="" HorizontalContentAlignment="Center"/>
		<TextBox Name="o_Computer" Text="" VerticalAlignment="Top" HorizontalAlignment="Left" Margin="110,8,0,0" Width="100" IsReadOnly="True" Background="#CAF0F8" BorderThickness="0" HorizontalContentAlignment="Center"/>
		<Button Name="btn_Close" VerticalAlignment="Top" HorizontalAlignment="Left" Margin="229,9,0,0" Width="17" Height="17">
            <Image Name="btn_close_image"></Image>
        </Button>
    </Grid>
</Window>
'@

$xaml.Window.RemoveAttribute('x:Class')
$xaml.Window.RemoveAttribute('mc:Ignorable')
$xaml.SelectNodes("//*") | ForEach-Object {$_.RemoveAttribute('d:LayoutOverrides')}

$Reader = (New-Object System.Xml.XmlNodeReader $xaml) 
try{ 
$Form = [Windows.Markup.XamlReader]::Load($reader) 
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object { New-Variable -Name $_.Name -Value $Form.FindName($_.Name) -Force }
}
catch{Write-Host "Unable to load Windows.Markup.XamlReader";exit}

#$Form.Icon = DecodeBase64Image -ImageBase64 $TitleIcon

$BackgroundImage.Source = $BackgroundImageBin

$i_Computer.Add_KeyDown({
if($_.Key -eq "Enter"){
$pc_data = $i_Computer.Text;
if($pc_data -match "^[\d\.]+$"){$pcn = (Get-WmiObject Win32_ComputerSystem -ComputerName $pc_data -ErrorAction SilentlyContinue).Name;$o_Computer.Text = $pcn}
else{foreach($d in (Get-ADForest).Domains){try{$pci = [System.Net.Dns]::GetHostByName("$pc_data.$d").AddressList[0].IPAddressToString}catch{$nul};$o_Computer.Text = $pci;}}
}})

$btn_close_image.Source = $btn_close_imageBin_out

$btn_Close.Add_MouseEnter({$btn_close_image.Source = $btn_close_imageBin_in})

$btn_Close.Add_MouseLeave({$btn_close_image.Source = $btn_close_imageBin_out})

$btn_Close.Add_Click({$Form.Close()})

$Form.add_MouseLeftButtonDown({$_.handled=$true;$this.DragMove()})

$Form.Add_KeyDown({if($viewForm.working -eq $false -and $_.Key -eq 'F12'){$viewForm.reset = $true;$Form.Close()}})

[void]$Form.ShowDialog()

}
while($viewForm.reset -eq $true)
