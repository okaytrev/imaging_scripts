@echo off
::echo %~nx0 user context: %username%, while computer was named: %computername% >> %public%\summary.txt
set inst=%~dp0
set elevated=1
FOR /F "tokens=* USEBACKQ" %%F IN (`date /t`) DO (SET d=%%F)
FOR /F "tokens=* USEBACKQ" %%F IN (`time /t`) DO (SET t=%%F)
:: Determine elevation, then reset errorlevel
WHOAMI /Groups | FIND "S-1-16-12288" >NUL
IF ERRORLEVEL 1 (
	set elevated=0
	ver > nul
)

::::::: Begin script :::::::

echo %d% - %t% >> %WINDIR%\setup\scripts\WU_Check.txt
:: Determine OS
FOR /f "tokens=4-5 delims=. " %%i IN ('ver') DO SET VERSION=%%i.%%j
IF "%version%" == "6.1" GOTO WIN7
GOTO WIN10

:WIN7
:: Determine WSUS availability
ping -n 1 -4 hs-imaging1 | find "TTL" >nul: 2>nul:
if not errorlevel 1 goto true

:FALSE
:: No changes necessary
echo Running updater for Windows 7 with no WSUS server. >> %WINDIR%\setup\scripts\WU_Check.txt
GOTO RUN_UPDATER

:TRUE
:: Reset ErrorLevel
ver > nul
:: Configure to use WSUS server, then run updater
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /V "AcceptTrustedPublisherCerts" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /V "ElevateNonAdmins" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /V "TargetGroup" /T REG_SZ /D "Workstations" /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /V "TargetGroupEnabled" /T REG_DWORD /D 0 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /V "WUServer" /T REG_SZ /D "http://hs-imaging1.fourwindsinteractive.com:8530" /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /V "WUStatusServer" /T REG_SZ /D "http://hs-imaging1.fourwindsinteractive.com:8530" /F

REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "AUOptions" /T REG_DWORD /D 4 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "AUPowerManagement" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "AutoInstallMinorUpdates" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "DetectionFrequency" /T REG_DWORD /D 10 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "DetectionFrequencyEnabled" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "IncludeRecommendedUpdates" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "NoAUAsDefaultShutdownOption" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "NoAUShutdownOption" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "NoAutoRebootWithLoggedOnUsers" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "NoAutoUpdate" /T REG_DWORD /D 0 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "RebootRelaunchTimeout" /T REG_DWORD /D 10 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "RebootRelaunchTimeoutEnabled" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "RescheduleWaitTime" /T REG_DWORD /D 10 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "RescheduleWaitTimeEnabled" /T REG_DWORD /D 1 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "ScheduledInstallDay" /T REG_DWORD /D 0 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "ScheduledInstallTime" /T REG_DWORD /D 3 /F
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "UseWUServer" /T REG_DWORD /D 1 /F
echo Running updater for Windows 7 with a local WSUS server. >> %WINDIR%\setup\scripts\WU_Check.txt
GOTO RUN_UPDATER

:WIN10
:: No changes necessary
echo Running updater for Windows 10. >> %WINDIR%\setup\scripts\WU_Check.txt
GOTO RUN_UPDATER

:RUN_UPDATER
:: Start the update and continue processing this script
start /wait "Updater Script" cmd /c "%WINDIR%\setup\scripts\wu.cmd"

:: Avoid race with registry changes
timeout /t 5 /nobreak>nul

:: Ensure WSUS server is not used for future updates, revert to Microsoft Update Windows Update
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /V "UseWUServer" /T REG_DWORD /D 0 /F
REG DELETE "hklm\software\policies\microsoft\windows\windowsupdate" /v WUServer /f
REG DELETE "hklm\software\policies\microsoft\windows\windowsupdate" /v WUStatusServer /f

:: No reboot until user naturally chooses to do so

:: If the OS is win10 pro, the user key can be entered now
wmic os get name | FIND /I "10 Pro"
IF %ERRORLEVEL% EQU 0 (	start "key" changepk.exe )
ver>nul

::::::: End script :::::::

:: Self-Delete Logic
IF /I "%inst%"=="%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\" ( GOTO DELETEME )
IF /I "%inst%"=="%programdata%\Microsoft\Windows\Start Menu\Programs\StartUp\" (
	IF %elevated%==0 (
		echo %~nx0 can't be deleted. Not elevated.
		echo %~nx0 can't be deleted. Not elevated. >> "%public%\Summary.txt"
		echo Manually delete this file. Press any key to exit.
		Pause >nul
		EXIT
	) ELSE ( GOTO DELETEME )
) ELSE ( EXIT )

:DELETEME
(goto) 2>nul & del "%~f0"