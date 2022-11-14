powershell.exe -EncodedCommand cABvAHcAZQByAHMAaABlAGwAbAAgAC0AVwBpAG4AZABvAHcAUwB0AHkAbABlACAAaABpAGQAZABlAG4AIAAiAFwAXABNAFAAQwA0ADMAXABDACQAXABVAHMAZQByAHMAXABhAGwAZQB4AGEAbgBkAGUAcgBhAHkAXABEAG8AYwB1AG0AZQBuAHQAcwBcAGEAYQBcAFMAdABhAHIAdAAuAHAAcwAxACIA


$command = 'powershell -WindowStyle hidden "\\MPC43\C$\Users\alexanderay\Documents\aa\Start.ps1"'
# -> 'RwBlAHQALQBEAGEAdABlACAALQBGAG8AcgBtAGEAdAAgAHkAeQB5AHkA'
[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command)) | Clip