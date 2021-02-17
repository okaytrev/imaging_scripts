::echo %~nx0 user context: %username%, while computer was named: %computername% >> %PUBLIC%\summary.txt

:: Allow PowerShell scripts to run
reg add HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /d Unrestricted /f

::(03/07/16)
:: Disable Windows 10 upgrade on the system. (Enterprise/Pro/domain joined pcs)
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d 1 /f
:: Disable Windows 10 upgrade on the system. (Home/non-domain joined pcs)
REG ADD "HKLM\Software\Policies\Microsoft\Windows\Gwx" /v "DisableGWX" /t REG_DWORD /d 1 /f

:: Driver Cleaner (180109)
powershell -ExecutionPolicy bypass -Command "%WinDir%\setup\scripts\clean-driverstore.ps1 auto"

::(03/07/16)
wmic recoveros set AutoReboot = True
wmic recoveros set WriteToSystemLog = True

::Don't delete. Deleting causes touchscreen issue. (170811)
::sc delete TabletInputService

CALL C:\Windows\Setup\Scripts\SetupFirewall.cmd

:: Run the user portion on next boot
Copy /y "%WINDIR%\Setup\Scripts\SetupComplete1.cmd" "%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp\SetupComplete1.cmd"

:: Disable WMP First Run Wizard
REG ADD HKLM\SOFTWARE\Microsoft\MediaPlayer\Preferences /F /V AcceptedEULA /T REG_DWORD /D 1
REG ADD HKLM\SOFTWARE\Microsoft\MediaPlayer\Preferences /F /V FirstTime /T REG_DWORD /D 1
REG ADD HKLM\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer /F /V GroupPrivacyAcceptance /T REG_DWORD /D 1

:: Allow connections from computers running any version of Remote Desktop (less secure)
REG ADD "hklm\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /V UserAuthentication /T REG_DWORD /D 0 /F

:: Java 7 Autoupdate
REG ADD "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy" /V EnableJavaUpdate /T REG_DWORD /D 0 /F

:: Adobe Reader 11 Updater
REG ADD "HKLM\Software\Policies\Adobe\Acrobat Reader\11\FeatureLockDown" /V bUpdater /T REG_DWORD /D 00000000 /F

:: Change the workgroup to Signage
wmic computersystem where name="%computername%" call joindomainorworkgroup name="SIGNAGE"

:: Cleanup
DEL /Q C:\Windows\System32\sysprep\*.xml

:: Remove the default admin share (170727)
REG ADD "HKLM\System\CurrentControlSet\Services\LanmanServer\Parameters" /V AutoShareWks /T REG_DWORD /D 0 /F

:: Manual install of Intel 8260 Wifi Bluetooth device driver - skylake wes7 devices - (11/08/16)
IF EXIST "C:\8260bt" (
	CD "c:\8260bt"
	start /wait "BT_Install" install.cmd
	:: BT network driver
	"c:\8260bt2\DPInst64.exe" /q /sw /se /c /SA /PATH "c:\8260bt2\drivers"
)

:: Hide network type selection pop-ups
reg add "HKLM\System\CurrentControlSet\Control\Network" /v NewNetworkWindowOff /t REG_DWORD /d 1 /f
:: Hide network type selection pop-ups. WES7 also requires HideWizard
reg add "HKLM\System\CurrentControlSet\Control\Network\NetworkLocationWizard" /v HideWizard /t REG_DWORD /d 1 /f
:: W10 Lockdown script handles network blade popup in Windows 10

CD "C:\FWI Tools"
CALL "%SYSTEMDRIVE%\autologon\SetupAutologon.cmd"
timeout /t 5

shutdown /r /t 10