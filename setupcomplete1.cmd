::echo %~nx0 user context: %username%, while computer was named: %computername% >> %PUBLIC%\summary.txt
:: End of batch variables
set inst=%~dp0
set elevated=1
:: Determine elevation, then reset errorlevel
WHOAMI /Groups | FIND "S-1-16-12288" >NUL
IF ERRORLEVEL 1 (
	set elevated=0
	ver > nul
)

::::::: Begin script :::::::

:: Runs as the user during first login

:: Various settings profiles (180108)
powershell -ExecutionPolicy bypass -Command "%WinDir%\setup\scripts\clean-driverstore.ps1 helper"
IF EXIST "%WINDIR%\Setup\Scripts\SetupPowerPolicy.cmd" CALL "%WINDIR%\Setup\Scripts\SetupPowerPolicy.cmd"

:: Set Windows Update
REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v ScheduledInstallDay /d 4 /t REG_DWORD /F

:: Add Run to the Start Menu
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Start_ShowRun /d 1 /t REG_DWORD /F
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v ForcerunOnStartMenu /d 1 /t REG_DWORD /F
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideIcons /d 1 /t REG_DWORD /F 

:: Disable Balloon Tips
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v EnableBalloonTips /d 0 /t REG_DWORD /F

:: Disable Show Touch Keyboard Button (180410)
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\TabletTip\1.7" /V TipbandDesiredVisibility /T REG_DWORD /D 0 /F

:: Enable Autohide in Tablet mode (180410)
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V TaskbarAutoHideInTabletMode /T REG_DWORD /D 1 /F

:: Disable Desktop Gadgets
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Windows\Sidebar" /V TurnOffSidebar /d 1 /T REG_DWORD /F

:: Change the desktop background
REG ADD "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%WINDIR%\system32\oobe\info\backgrounds\backgroundDefault.jpg" /f

:: Change Control Panel to small icons
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel /F /V AllItemsIconView /T REG_DWORD /D 1
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /F /V ForceClassicControlPanel /T REG_DWORD /D 1

:: Don't display any task bar notification icons
reg add hkcu\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /f /v NoTrayItemsDisplay /t REG_DWORD /d 1

:: Disable IE11 First run Wizard
REG ADD "HKCU\Software\Policies\Microsoft\Internet Explorer\Main" /F /V DisableFirstRunCustomize /d 2 /T REG_DWORD

:: Power button restarts (4) the computer
REG ADD "HKCU\Software\Policies\Microsoft\Windows\Explorer" /F /V PowerButtonAction /D 4 /T REG_DWORD

:: Disable Adobe Reader 11 EULA
REG ADD "HKCU\Software\Adobe\Acrobat Reader\11.0\AdobeViewer" /F /V EULA /D 1 /T REG_DWORD
REG ADD "HKLM\Software\WOW6432Node\Adobe\Adobe Acrobat\11.0\AdobeViewer" /F /V EULA /D 1 /T REG_DWORD
REG DELETE "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /V "Adobe ARM" /F
REG ADD "HKLM\Software\policies\Adobe\Adobe Reader\11.0\FeatureLockdown" /V bUpdater /F /T REG_DWORD /D 0

:: Disable the tablet input tab (160307)
REG ADD "HKCU\Software\Microsoft\TabletTip\1.7" /F /V EnableEdgeTarget /T REG_DWORD /D 0

:: Run Codec settings (03/07/16)
powershell -executionpolicy bypass -file "%WINDIR%\Setup\Scripts\FWI_NUC_Codecs.ps1"

:: Allows multi-touch gestures to be disabled
REG ADD HKCU\Software\Microsoft\Wisp\MultiTouch /F

:: Run windows update as user on next reboot - Disabled (180418)
::Copy /y "%WINDIR%\Setup\Scripts\WU_Check.cmd" "%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp\WU_Check.cmd"

IF EXIST "%PROGRAMFILES%\Now Micro\Shell\shell.exe" CALL %WINDIR%\Setup\Scripts\ShellSetup.cmd

:: Start the reboot process
start "Begin shutdown" shutdown /r /t 30

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