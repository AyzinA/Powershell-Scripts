@echo off
cls
Echo( ______________________________________________________________________________________________________________________
Echo(
Echo(  Deleting Windows Temp
Echo( ______________________________________________________________________________________________________________________
Echo(
IF EXIST "%windir%\Temp" ( rmdir /s /q "%windir%\Temp" ) ELSE ( echo "No folder found." )
cls
Echo( ______________________________________________________________________________________________________________________
Echo(
Echo(  Deleting Downloaded Program Files
Echo( ______________________________________________________________________________________________________________________
Echo(
IF EXIST "%windir%\Downloaded Program Files" ( rmdir /s /q "%windir%\Downloaded Program Files" ) ELSE ( echo "No folder found." )
cls
Echo( ______________________________________________________________________________________________________________________
Echo(
Echo(  Deleting Offline Web Pages
Echo( ______________________________________________________________________________________________________________________
Echo(
IF EXIST "%windir%\Offline Web Pages" ( rmdir /s /q "%windir%\Offline Web Pages" ) ELSE ( echo "No folder found." )
cls
Echo( ______________________________________________________________________________________________________________________
Echo(
Echo(  Deleting Local Temp for All Users
Echo( ______________________________________________________________________________________________________________________
Echo(
FOR /D %%x in ("%userprofile%\..\*") DO IF EXIST "%%x\AppData\Local\Temp" ( rmdir /s /q "%%x\AppData\Local\Temp" ) ELSE ( echo "No folder found." )
cls
Echo( ______________________________________________________________________________________________________________________
Echo(
Echo(  Deleting IE Cache for All Users
Echo( ______________________________________________________________________________________________________________________
Echo(
FOR /D %%x in ("%userprofile%\..\*") DO IF EXIST "%%x\AppData\Local\Microsoft\Windows\INetCache\IE" ( rmdir /s /q "%%x\AppData\Local\Microsoft\Windows\INetCache\IE" ) ELSE ( echo "No folder found." )
cls
Echo( ______________________________________________________________________________________________________________________
Echo(
Echo(  GPUPDATE
Echo( ______________________________________________________________________________________________________________________
Echo(
gpupdate /force

::by Alexanderay Ayzin