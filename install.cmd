SET inst=%~dp0
MKDIR %WINDIR%\Setup\Scripts
Copy * %WINDIR%\Setup\Scripts\

:: Manual install of Intel 8260 Wifi Bluetooth device driver - skylake wes7 devices - (11/08/16)
Robocopy ".\8260bt" "c:\8260bt" /E /IS /XJ
Robocopy ".\8260bt2" "c:\8260bt2" /E /IS /XJ

REM If it gets turned on
Manage-BDE C: -off

REM Allow PowerShell scripts to run
reg add HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /d Unrestricted /f

REM This script enables Autohide of the start menu
powershell -ExecutionPolicy Unrestricted -File "C:\Windows\setup\scripts\install.ps1"

REM Set Windows Update time to 3am
REM REG ADD HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallTime /d 3 /F /t REG_DWORD

REM Remove Simple TCP Services
SC DELETE simptcp

REM CALL C:\Windows\Setup\Scripts\SetupFirewall.cmd