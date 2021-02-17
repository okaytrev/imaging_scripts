::echo %~nx0 user context: %username%, while computer was named: %computername% >> %PUBLIC%\summary.txt
REM Change the workgroup to Signage
wmic computersystem where name="%computername%" call joindomainorworkgroup name="SIGNAGE"

REM Turn on the firewall
netsh advfirewall set privateprofile state on
netsh advfirewall set publicprofile state on
netsh advfirewall set domainprofile state on

REM Add firewall rules.  The image is set to use the "Work" profile by default

REM Changed to 32-bit path, removed inbound rule
netsh advfirewall firewall add rule name="VLC" dir=out action=allow profile=any description="VLC" program="C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"

REM Changed to 32-bit path for all applications/subapplications, removed inbound rules
netsh advfirewall firewall add rule name="FWI Content Player" dir=out action=allow profile=any description="Content Player Signage" program="C:\Program Files (x86)\Four Winds Interactive\Content Player\Signage.exe"
netsh advfirewall firewall add rule name="FWI Content Player Service" dir=out action=allow profile=any description="Content Player Signage" program="C:\Program Files (x86)\Four Winds Interactive\Content Player\ContentPlayerService.exe"
netsh advfirewall firewall add rule name="FWI Content Player Monitor" dir=out action=allow profile=any description="Content Player Signage" program="C:\Program Files (x86)\Four Winds Interactive\Content Player\ContentPlayerMonitor.exe"
netsh advfirewall firewall add rule name="FWI Content Player External Player" dir=out action=allow profile=any description="Content Player Signage" program="C:\Program Files (x86)\Four Winds Interactive\Content Player\ExternalPlayer.exe"
netsh advfirewall firewall add rule name="FWI Content Player Movie Player" dir=out action=allow profile=any description="Content Player Signage" program="C:\Program Files (x86)\Four Winds Interactive\Shared Files\FwiMoviePlayer.exe"

::Socket Requests
netsh advfirewall firewall add rule name="FWI Reader ID Socket" dir=in action=allow profile=any protocol=TCP localport=10561

netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes

netsh advfirewall firewall add rule name="FWI Multicast" dir=in action=allow profile=any protocol=udp localport=14000-14050
netsh advfirewall firewall add rule name="FWI Multicast" dir=out action=allow profile=any protocol=udp localport=14000-14050

REM Cleaned up and consolidated rules - Removed 80/443 outbound as they are allow by default, added outbound UDP 70 to 71-75 range, corrected typo on FWI RMM9
netsh advfirewall firewall add rule name="FWI RMM1" dir=out action=allow profile=any protocol=udp localport=40000-41000
netsh advfirewall firewall add rule name="FWI RMM2" dir=out action=allow profile=any protocol=tcp localport=40000-40100
netsh advfirewall firewall add rule name="FWI RMM3" dir=out action=allow profile=any protocol=tcp localport=70
netsh advfirewall firewall add rule name="FWI RMM4" dir=out action=allow profile=any protocol=udp localport=70-75
netsh advfirewall firewall add rule name="FWI RMM5" dir=out action=allow profile=any protocol=udp localport=8002
netsh advfirewall firewall add rule name="FWI RMM6" dir=out action=allow profile=any protocol=tcp localport=8002

REM LEAVING THIS RULE 
netsh firewall set multicastbroadcastresponse ENABLE

REM Disable Simple TCP Services
sc config "simptcp" start= disabled
sc stop "simptcp"

REM Disable RDP Application
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /d 1 /F /t REG_DWORD

::THE FOLLOWING WAS REMOVED 7/10/2017
REM netsh advfirewall firewall add rule name="VLC" dir=in action=allow profile=any description="VLC" program="C:\Program Files\VideoLAN\VLC\vlc.exe"
REM netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
REM netsh advfirewall firewall set rule name="File and Printer Sharing (NB-Session-In)" new enable=yes remoteip=any
REM netsh advfirewall firewall set rule name="File and Printer Sharing (NB-Name-In)" new enable=yes remoteip=any
REM netsh advfirewall firewall set rule name="File and Printer Sharing (NB-Datagram-In)" new enable=yes remoteip=any
REM netsh advfirewall firewall set rule name="File and Printer Sharing (SMB-In)" new enable=yes remoteip=any
REM netsh advfirewall firewall set rule name="File and Printer Sharing (Spooler Service - RPC)" new enable=yes remoteip=any
REM netsh advfirewall firewall set rule name="File and Printer Sharing (Spooler Service - RPC-EPMAP)" new enable=yes remoteip=any
REM netsh advfirewall firewall add rule name="FWI Content Player" dir=out action=allow profile=any description="Content Player Signage" program="C:\Program Files\Four Winds Interactive\Content Player\Signage.exe"
REM netsh advfirewall firewall add rule name="FWI Content Player" dir=in action=allow profile=any description="Content Player Signage" program="C:\Program Files\Four Winds Interactive\Content Player\Signage.exe"
REM netsh advfirewall firewall add rule name="FWI Content Player Service" dir=out action=allow profile=any description="Content Player Service" program="C:\Program Files (x86)\Four Winds Interactive\Content Player\ContentPlayerService.exe"
REM netsh advfirewall firewall add rule name="FWI Content Player" dir=in action=allow profile=any description="Content Player Signage" program="C:\Program Files\Four Winds Interactive\Content Player\Signage.exe"
REM Enable Remote Desktop connections
REM REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /d 1 /F /t REG_DWORD

::THE FOLLOWING WAS ADDED BACK IN 04/04/2018
netsh advfirewall firewall set rule name="File and Printer Sharing (Echo Request - ICMPv4-In)" new enable=yes remoteip=any
netsh advfirewall firewall add rule name="FWI RMM3" dir=out action=allow profile=any protocol=udp localport=70
netsh advfirewall firewall add rule name="FWI RMM6" dir=out action=allow profile=any protocol=tcp localport=80
netsh advfirewall firewall add rule name="FWI RMM7" dir=out action=allow profile=any protocol=tcp localport=443