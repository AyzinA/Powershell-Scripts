$filename = 'C:\Users\alexanderay\Documents\aa\aa.exc'

$bytes = [Convert]::FromBase64String($b64)
[IO.File]::WriteAllBytes($filename, $bytes)