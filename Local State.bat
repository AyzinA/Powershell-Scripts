@echo off

REM Close Chrome browser completely
taskkill /F /IM chrome.exe

REM Wait for a moment
timeout /t 1

REM Remove a file in the Chrome folder
set "file_path=%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Local State"

if exist "%file_path%" (
    del "%file_path%"
    echo File "%file_path%" removed from Chrome folder.
) else (
    echo File "%file_path%" not found in Chrome folder.
)

REM Reopen Chrome browser
start chrome.exe

echo Script execution completed.
