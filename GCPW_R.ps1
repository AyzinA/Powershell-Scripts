<# This script downloads Google Credential Provider for Windows from
https://tools.google.com/dlpage/gcpw/, then installs and configures it.
Windows administrator access is required to use the script. #>

<# Set the following key to the domains you want to allow users to sign in from.

For example:
$domainsAllowedToLogin = "rapyd.net"
#>

$domainsAllowedToLogin = "rapyd.net"

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

<# Check if one or more domains are set #>
if ($domainsAllowedToLogin.Equals('')) {
    $msgResult = [System.Windows.MessageBox]::Show('The list of domains cannot be empty! Please edit this script.', 'GCPW', 'OK', 'Error')
    exit 5
}

function Is-Admin() {
    $admin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match 'S-1-5-32-544')
    return $admin
}

<# Check if the current user is an admin and exit if they aren't. #>
if (-not (Is-Admin)) {
    $result = [System.Windows.MessageBox]::Show('Please run as administrator!', 'GCPW', 'OK', 'Error')
    exit 5
}

<# Choose the GCPW file to download. 32-bit and 64-bit versions have different names #>
$gcpwFileName = 'gcpwstandaloneenterprise.msi'
if ([Environment]::Is64BitOperatingSystem) {
    $gcpwFileName = 'gcpwstandaloneenterprise64.msi'
}

<# Download Google Chrome Installer. #>
$chromeFileName = 'chrome_installer.exe'
$chromeUrlPrefix = 'https://dl.google.com/chrome/install/latest/'
$chromeUri = $gcpwUrlPrefix + $chromeFileName
Write-Host 'Downloading Chrome from' $gcpwUri
Invoke-WebRequest -Uri $chromeUri -OutFile $chromeFileName

<# Install Google Chrome. #>
$installProcess = (Start-Process -FilePath $chromeUri -ArgumentList "/silent", "/install" -Wait)

<# Check if installation was successful #>
if ($installProcess.ExitCode -ne 0) {
    $result = [System.Windows.MessageBox]::Show('Installation failed!', 'Chrome', 'OK', 'Error')
    Remove-Item -Path $gcpwFileName -Recurse -Force
    exit $installProcess.ExitCode
}
else {
    Remove-Item -Path $gcpwFileName -Recurse -Force
    $result = [System.Windows.MessageBox]::Show('Installation completed successfully!', 'Chrome', 'OK', 'Info')
}

<# Download the GCPW installer. #>
$gcpwUrlPrefix = 'https://dl.google.com/credentialprovider/'
$gcpwUri = $gcpwUrlPrefix + $gcpwFileName
Write-Host 'Downloading GCPW from' $gcpwUri
Invoke-WebRequest -Uri $gcpwUri -OutFile $gcpwFileName

<# Run the GCPW installer and wait for the installation to finish #>
$arguments = "/i `"$pwd\$gcpwFileName`""
$installProcess = (Start-Process msiexec.exe -ArgumentList $arguments -PassThru -Wait)

<# Check if installation was successful #>
if ($installProcess.ExitCode -ne 0) {
    $result = [System.Windows.MessageBox]::Show('Installation failed!', 'GCPW', 'OK', 'Error')
    Remove-Item -Path $gcpwFileName -Recurse -Force
    exit $installProcess.ExitCode
}
else {
    Remove-Item -Path $gcpwFileName -Recurse -Force
    $result = [System.Windows.MessageBox]::Show('Installation completed successfully!', 'GCPW', 'OK', 'Info')
}

<# Set the required registry key with the allowed domains #>
$registryPath = 'HKEY_LOCAL_MACHINE\Software\Google\GCPW'
$name = 'domains_allowed_to_login'
[microsoft.win32.registry]::SetValue($registryPath, $name, $domainsAllowedToLogin)

$domains = Get-ItemPropertyValue HKLM:\Software\Google\GCPW -Name $name

if ($domains -eq $domainsAllowedToLogin) {
    $msgResult = [System.Windows.MessageBox]::Show('Configuration completed successfully!', 'GCPW', 'OK', 'Info')
}
else {
    $msgResult = [System.Windows.MessageBox]::Show('Could not write to registry. Configuration was not completed.', 'GCPW', 'OK', 'Error')

}
