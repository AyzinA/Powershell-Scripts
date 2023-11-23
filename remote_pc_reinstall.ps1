$Path = $env:TEMP; $Installer = "AirWatchAgent.msi";
echo "Downloading - Workspace One";
Invoke-WebRequest "https://packages.vmware.com/wsone/AirwatchAgent.msi" -OutFile $Path\$Installer;
$argList = @(
    "/quiet"
    "ENROLL=N"
);
echo "Installing - Workspace One";
Start-Process "$Path\$Installer" -ArgumentList $argList -Wait;
echo "Finshed Installing - Workspace One";
Remove-Item $Path\$Installer;

# Define a temporary folder path
$tempFolderPath = Join-Path $env:TEMP "EndpointTemp"

# Create a temporary folder for downloads
New-Item -ItemType Directory -Path $tempFolderPath -Force | Out-Null

# Define registry path
$registryPath = "HKCU:\Software\Google\Endpoint Verification\Safe Storage"

# Define download URL
$downloadUrl = "https://dl.google.com/tag/s/appguid=%7B5289EAA4-96AA-881C-BCCA-C3A9D2D95347%7D&appname=SecureConnect-Win&needsadmin=false/secureconnect/install/win/regular/EndpointVerification.exe"

# Define the installation path
$installPath = Join-Path $tempFolderPath "EndpointVerification.exe"

# Specify the URL for the latest Google Chrome installer
$chromeInstallerURL = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"

# Specify the path where you want to save the installer
$chromeInstallerPath = Join-Path $tempFolderPath " chrome_installer.exe"

# Step 1: Update Chrome
$chromeVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Google\Update\ClientState\{8A69D345-D564-463C-AFF1-A69D9E530F96}").pv
if ($chromeVersion -ne $null) {
    Write-Host "Current Chrome version: $chromeVersion"

    # Download the latest Chrome update installer
    Invoke-WebRequest -Uri $chromeInstallerURL -OutFile $chromeInstallerPath

    # Install the update
    Start-Process -FilePath $chromeInstallerPath -ArgumentList "/silent", "/install" -Wait
    Write-Host "Chrome update completed."
} else {
    Write-Host "Unable to determine the current Chrome version."
}

# Step 2: Download and install the endpoint
Invoke-WebRequest -Uri $downloadUrl -OutFile $installPath
Start-Process -FilePath $installPath -Wait
Write-Host "Endpoint installation completed."

# Step 3: Delete the registry key
try {
    Remove-ItemProperty -Path $registryPath -Name "YourValueName" -ErrorAction Stop
    Write-Host "Registry key deleted successfully."
}
catch {
    Write-Host "Failed to delete the registry key."
}

# Step 4: Delete the temporary folder
Remove-Item -Path $tempFolderPath -Recurse -Force
Write-Host "Temporary folder deleted."
