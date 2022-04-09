$path = "FILE_PATH"

[convert]::ToBase64String((get-content $path -encoding byte)) | Clip