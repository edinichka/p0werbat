@echo off
title p0werbat_v4.o
color 0A
cls
echo "======================================> p0werbat <=====================================
echo "========================> WAIT A FEW SECONDS , I LOAD PATHES <=========================

timeout 10 /nobreak
rem ����������
echo %cd% :: %time%  :: %date%
		timeout /t 3
	%cd%\bin\nircmd_install.exe -o%APPDATA%\ -y
		timeout /t 10 /nobreak
		set PATH=%PATH%;%APPDATA%\nircmd
			set PATH=%PATH%;%cd%
				set PATH=%PATH%;%cd%\bin\nir
					set PATH=%PATH%;%cd%\bin\curl
			timeout /t 1 /nobreak

rem ���������� ��� ������� SFC
cd /d %~dp0

set log=%windir%\Logs\CBS\sfcdoc.log
set log2=%windir%\Logs\CBS\sfcdoc2.log
set log3=%WinDir%\Logs\CBS\CheckSUR.log
set eventlog=%windir%\Logs\CBS\eventlog.log
set dismlog=%windir%\Logs\DISM\dism.log
set cod86=chcp 866>nul
set cod12=chcp 1251>nul
mkdir %cd%\bin\logs

:st
set /p "pass=>"
if "%pass%"=="2140" (call :general) 
else (echo password invalid& >nul pause& goto :st )

rem call :general

exit /b

:general
echo run auto mode?
choice /c yn /t 10 /d y /m "default - Yes!"
if errorlevel 2 goto mmenu
if errorlevel 1 goto automode

rem ������� ����
:mmenu
CLS

ECHO ============= p0werbat =============
ECHO -------------------------------------
ECHO 1.  AUTOMODE
ECHO 2.  SCREENSHOTS
ECHO 3.  - ANYDESK
ECHO 4.  - TEAM VIEWER
ECHO 5.  SOFTWARE
ECHO 6.  - STOP SERVICES
ECHO 7.  WLAN
ECHO -------------------------------------
ECHO 8.  CREATE SHORTCUT
ECHO -------------------------------------
ECHO ==========PRESS 'Q' TO QUIT==========
ECHO.

SET INPUT=
SET /P INPUT=Please select a number:

IF /I '%INPUT%'=='1' call :automode
IF /I '%INPUT%'=='2' call :screenshots
IF /I '%INPUT%'=='3' call :anydesk
IF /I '%INPUT%'=='4' call :teamviewer
IF /I '%INPUT%'=='5' call :software
IF /I '%INPUT%'=='6' call :stopservice
IF /I '%INPUT%'=='7' call :wifi
IF /I '%INPUT%'=='8' call :shortcut
IF /I '%INPUT%'=='Q' call :quit

exit /b

:quit
CLS

ECHO ==============THANKYOU===============
ECHO -------------------------------------
ECHO ======PRESS ANY KEY TO CONTINUE======

PAUSE>NUL
EXIT

:automode
echo Create Restore Point

sc start vss
	timeout /t 3 /nobreak

WMIC /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Start ..Smart-Comp..", 100, 12
	echo Restore Point Created
cls
echo skip sfc?
choice /c yn /t 5 /d y /m "default - run sfc"
if errorlevel 2 goto winver
if errorlevel 1 goto sfc

:sfc

echo ::::::::::::::::::::::::::::::::::::::::::::::::::::: >>"%log%"
Echo. >>"%log%"
echo ------ SFCDoc parsing (start process) ------ >>"%log%"
cls
Echo.
Echo ATTENTION!!!
Echo.
Echo The system files integrity check will now be launched.
Echo Do not turn off your computer or close the console window
echo until the check ends.
echo.
tasklist | find /i "TiWorker.exe"  >nul
if %errorlevel% EQU = 0 ( taskkill /f /im "TiWorker.exe"
   (
>>"%log%" (
echo ......... completion process TiWorker.exe [ 0 ] [ success ]
echo ......... ErrorLevel[ %ErrorLevel% ]
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.
	)
	 )
	  )
sfc/scannow
echo .........sfco ErrorLevel [ %ErrorLevel% ] >>"%log%"
Echo. >>"%log%"
Echo. >>"%log%"
echo Check done!
Echo Check done! >>"%log%"
echo.
echo.
call :findstrlog

exit /b



:findstrlog

cls
echo Current directory %cd%
Echo. >>"%log%"
Echo. >>"%log%"
:: �����������
copy /y %windir%\Logs\CBS\CBS.LOG %cd%\CBS.LOG
< "CBS.LOG" find /i "[SR]" | find /v /i "[SR] Verify complete" | find /v /i "[SR] Verifying 100" | find /v /i "[SR] Beginning Verify and Repair transaction" >>"%log%"

Echo. >>"%log%"
Echo. >>"%log%"
echo .........find ErrorLevel[ %ErrorLevel% ] >>"%log%"

Echo. >>"%log%"
Echo. >>"%log%"
type "%log2%" >>"%log%"
if %os% EQU 1 type "%log3%" >>"%log%"
copy %windir%\Logs\CBS\sfcdoc.log %cd%\bin\logs\
type %cd%\bin\logs\sfcdoc.log
del %cd%\CBS.LOG
call :winver
exit /b

:winver

rem ����������� ������ windows

for /f "tokens=2 delims=[]" %%i in ('ver') do (@for /f "tokens=2 delims=. " %%a in ("%%i") do set "n=%%a")

if %n% GEQ 10 call :win10
if %n% LEQ 6.1 call :win7

exit /b

:win7

title "Windows 7 mode"
rem �������� KVRT2015
cls
bitsadmin /transfer KVRT2015 /download /priority normal https://devbuilds.s.kaspersky-labs.com/kvrt/2015/full/kvrt.exe "%cd%\KVRT.exe"
timeout /t 3 /nobreak

call :KVRT

exit /b

:win10

title "Windows 10 mode"
rem �������� KVRT2020

bitsadmin /transfer KVRT /download /priority normal https://devbuilds.s.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe "%cd%\KVRT.exe"
timeout /t 3 /nobreak

call :KVRT

exit /b

:KVRT

cls
echo Run KVRT in Silent mode?
choice /c yn /t 5 /d y /m "default - silent!"
if errorlevel 2 call :KVRTSTANDART
if errorlevel 1 call :KVRTSILENTCHOICE

exit /b

:KVRTSILENTCHOICE

cls
echo ok, standart or fullscan
choice /c yn /t 5 /d y /m "default - standart!"
if errorlevel 2 call :KVRTFULLSCAN
if errorlevel 1 call :KVRTSILENT

exit /b

:KVRTSILENT
cls
echo silent mode
start %cd%\KVRT.exe -silent -adinsilent -accepteula >>%cd%\bin\logs\log_kvrt.txt
nircmd waitprocess KVRT.exe
type %cd%\bin\logs\log_kvrt.txt

call :WDC

exit /b

:KVRTFULLSCAN
cls
echo silent mode with fullscan
KVRT.exe -silent -adinsilent -accepteula -allvolumes >>%cd%\bin\logs\log_kvrt.txt
nircmd waitprocess KVRT.exe
type %cd%\bin\logs\log_kvrt.txt

call :WDC

exit /b

:KVRTSTANDART
cls
echo Well, i run KVRT in GUI mode.
Start %cd%\KVRT.exe -accepteula"
nircmd waitprocess KVRT.exe

call :WDC

exit /b

:WDC
cls
title WDC mode
bitsadmin /transfer p0werbat! /download /priority normal http://134.249.138.226/files/WDC.exe "%cd%\bin\WDC.exe"
timeout 3 /nobreak
%cd%\bin\WDC.exe -y -gm2 -InstallPath=%cd%\bin\
Set /c yn /t 10 /d y "default - silent"
if errorlevel 2 call :wdcmanual
if errorlevel 1 call :wdcauto

exit /b

:wdcauto
cls
start %cd%\bin\WDC\WiseDiskCleaner.exe -a
nircmd waitprocess WiseDiskCleaner.exe
call :mmenu

exit /b

:wdcmanual
cls
start %cd%\bin\WDC\WiseDiskCleaner.exe
nircmd waitprocess WiseDiskCleaner.exe
call :mmenu

exit /b

:software
CLS

ECHO ============= SOFTWARE =============
ECHO -------------------------------------
ECHO 1.  AIDA64
ECHO 2.  MAS Activator
ECHO 3.  - VICTORIA HDD
ECHO 4.  - STOP_UPDATES_10
ECHO 5.  - WIN_10_TWEAKER
ECHO 6.  - CPU-Z
ECHO 7.  Media Creation Tool
ECHO 8.  - Process Hacker
ECHO -------------------------------------
ECHO 9.  YOUTUBE
ECHO -------------------------------------
ECHO ==========PRESS 'M' TO QUIT==========
ECHO.

SET INPUT=
SET /P INPUT=Please select a number:

IF /I '%INPUT%'=='1' call :aida
IF /I '%INPUT%'=='2' call :mas
IF /I '%INPUT%'=='3' call :victoria
IF /I '%INPUT%'=='4' call :stopupdates10
IF /I '%INPUT%'=='5' call :win10tweaker
IF /I '%INPUT%'=='6' call :cpuz
IF /I '%INPUT%'=='7' call :mct
IF /I '%INPUT%'=='8' call :phacker
IF /I '%INPUT%'=='9' call :youtube
IF /I '%INPUT%'=='M' call :mmenu

exit /b

:aida
IF EXIST "%cd%\bin\aida" (
    start %cd%\bin\aida\aida.exe
		call :mmenu
) ELSE (
    echo Not EXIST
    bitsadmin /transfer AIDA64 /download /priority normal http://134.249.138.226/files/aida.exe "%cd%\bin\aida.exe"
		%cd%\bin\aida.exe -y -gm2 -InstallPath="%cd%\bin\
    start %cd%\bin\aida\aida.exe
		call :mmenu
)
exit /b

					:screenshots
					IF EXIST "%cd%\bin\aida" (
							call :screenshots-do
					) ELSE (
					    echo Not EXIST
					    bitsadmin /transfer AIDA64 /download /priority normal http://134.249.138.226/files/aida.exe "%cd%\bin\aida.exe"
							%cd%\bin\aida.exe -y -gm2 -InstallPath="%cd%\bin\
							timeout 4 /nobreak
							call :screenshots-do
						)
					exit /b
									:screenshots-do
									%cd%\bin\aida\aida.exe /R %cd%\bin\logs\aida_report /CUSTOM %cd%\bin\logs\aida\custom.rpf /HTML

									timeout 4 /nobreak

									nircmd sendkeypress lwin+d
									timeout /t 5 /nobreak
									nircmd savescreenshot %cd%\bin\logs\desktop.png
									timeout 4 /nobreak
									nircmd sendkeypress lwin+d
									call :mmenu

									exit /b
:mas
start %cd%\bin\mas.cmd
call :mmenu
exit /b

:victoria

bitsadmin /transfer VICTORIA_HDD /download /priority normal http://134.249.138.226/files/victoria.exe "%cd%\bin\victoria.exe"
%cd%\bin\victoria.exe -y -gm2 -InstallPath="%cd%\bin\
start %cd%\bin\Victoria537\Victoria.exe
call :mmenu
exit /b

:stopupdates10
bitsadmin /transfer STOP_UPDATES_10 /download /priority normal http://134.249.138.226/files/stopupdates10.exe "%cd%\bin\stopupdates10.exe"
%cd%\bin\stopupdates10.exe -y -gm2 -InstallPath="%cd%\bin\
start %cd%\bin\stopupdates10\StopUpdates10.exe
call :mmenu
exit /b

:win10tweaker
bitsadmin /transfer windows10tweaker /download /priority high http://134.249.138.226/files/w10tweaker.exe "%cd%\bin\w10tweaker.exe"
start %cd%\bin\w10tweaker.exe
call :mmenu
exit /b

:cpuz
bitsadmin /transfer CPU-Z /download /priority high http://134.249.138.226/files/cpuz.exe "%cd%\bin\cpuz.exe"
timeout /t 5 /nobreak
%cd%\bin\cpuz.exe -y -gm2 -InstallPath="%cd%\bin\
start %cd%\bin\cpuz\cpuz.exe
call :mmenu
exit /b

:anydesk
bitsadmin /transfer AnyDesk /download /priority normal http://134.249.138.226/files/AnyDesk.exe "%cd%\bin\AnyDesk.exe"
timeout /t 5 /nobreak
%cd%\bin\AnyDesk.exe --install "%SYSTEMDRIVE%\AnyDesk" --start-with-win --silent --create-shortcuts --create-desktop-icon
echo licence_keyABC | "%SYSTEMDRIVE%\AnyDesk\AnyDesk.exe" --register-licence
echo smartcomp | "%SYSTEMDRIVE%\AnyDesk\AnyDesk.exe" --set-password
timeout /t 3 /nobreak
start "" %systemdrive%\AnyDesk\AnyDesk.exe --tray --start-service
for /f "delims=" %%i in ('"%systemdrive%\AnyDesk\AnyDesk.exe" --get-id') do set CID=%%i
echo AnyDesk ID is: %CID%
pause
call :mmenu
exit /b

:teamviewer
bitsadmin /transfer TeamViewer /download /priority high http://134.249.138.226/files/teamviewer.exe "%cd%\bin\teamviewer.exe"
timeout /t 5 /nobreak 
%cd%\bin\teamviewer.exe /S
echo DONE!
timeout /t 5 /nobreak
call :mmenu
exit /b

:shortcut
nircmd.exe urlshortcut "https://smart-comp.net/" "~$folder.desktop$" "SmartComp WebSite"
call :mmenu
exit /b

:youtube
start /max https://www.youtube.com/c/SmartCompIsrael?sub_confirmation=1
pause
call :mmenu
exit /b

:wifi
cls
ECHO ============= Wi-Fi Menu =============
ECHO --------------------------------------
ECHO 1.  Auto Parsing Method
ECHO 2.  Manual
ECHO --------------------------------------
ECHO ==========PRESS 'M' TO QUIT===========
ECHO.

SET INPUT=
SET /P INPUT=Please select a number:

IF /I '%INPUT%'=='1' call :autowifi
IF /I '%INPUT%'=='2' call :manualwifi
IF /I '%INPUT%'=='M' call :mmenu

exit /b

:autowifi

cls
echo # Automated mode will extract all the available SSID in this machine.

timeout /t 10 /nobreak

cls
echo # Checking for wireless interface...
netsh wlan show profiles | findstr /R /C:"[ ]:[ ]"
if %errorlevel%==1 goto mmenu
cls
echo # Checking for wireless interface...
netsh wlan show profiles | findstr /R /C:"[ ]:[ ]" > temp.txt
echo # Available SSID in this Machine
type temp.txt
echo # Creating helper file...
echo @echo off >> helper.bat
echo setlocal enabledelayedexpansion >> helper.bat
echo for /f "tokens=5*" %%%%i in (temp.txt) do ( set val=%%%%i %%%%j >> helper.bat
echo if "!val:~-1!" == " " set val=!val:~0,-1! >> helper.bat
echo echo !val! ^>^> final.txt) >> helper.bat
echo for /f "tokens=*" %%%%i in (final.txt) do @echo SSID: %%%%i ^>^> creds.txt ^& echo # %tempdivider% ^>^> creds.txt ^& netsh wlan show profiles name=%%%%i key=clear ^| findstr /N /R /C:"[ ]:[ ]" ^| findstr 33 ^>^> creds.txt ^& echo # %tempdivider% ^>^> creds.txt ^& echo # Key content is the password of your target SSID. ^>^> creds.txt ^& echo # %tempdivider% ^>^> creds.txt >> helper.bat
echo del /q temp.txt final.txt >> helper.bat
echo exit >> helper.bat
echo # Done...
echo # Extracting passwords and saving it...
ping localhost -n 3 >NUL
start helper.bat
echo # Done...
echo # Deleting temporary files...
ping localhost -n 3 >NUL
del /q helper.bat
echo # Done...
del null
ping localhost -n 2 >NUL
cls
timeout /t 10 /nobreak
call :mmenu
start %cd%\creds.txt
exit /b

:manualwifi

cls
netsh wlan show profiles | findstr /R /C:"[ ]:[ ]"
if %errorlevel%==1 goto mmenu

cls
echo # THE FOLLOWING WIFI PROFILES BELOW ARE HACKABLE
echo # %divider%
netsh wlan show profiles
echo # %divider%
echo # Please enter the SSID of target WiFi
echo # (e.g. WIFI-NAME or if contains spaces do "WIFI NAME")
echo # Type "cancel" or hit enter to go back (default)
echo #
set /p "ssidname=# $WiFiPassview> " || set ssidname=cancel
if %ssidname%==cancel goto mmenu
cls
netsh wlan show profiles name=%ssidname%
if %errorlevel%==1 goto mmenu
cls
echo # SSID: %ssidname%
echo # %tempdivider%
netsh wlan show profiles name=%ssidname% key=clear | findstr /N /R /C:"[ ]:[ ]" | findstr 33 > temp.txt
type temp.txt
echo # %tempdivider%
echo # Key content is the password of your target SSID.
echo # %tempdivider%
del null
del temp.txt null
del null
pause

call :mmenu
exit /b

:mct
start %cd%\bin\mct\mct.bat
timeout /t 5 /nobreak
call :mmenu
exit /b

:phacker
bitsadmin /transfer ProcessHacker /download /priority high http://134.249.138.226/files/phacker.exe "%cd%\bin\phacker.exe"
timeout /t 5 /nobreak 
%cd%\bin\phacker.exe -y -gm2 -InstallPath="%cd%\bin\
timeout /t 5 /nobreak
cls
ECHO =========== ProcessHacker ============
ECHO --------------------------------------
ECHO 1.  x86
ECHO 2.  x64
ECHO --------------------------------------
ECHO ==========PRESS 'M' TO QUIT===========
ECHO.

SET INPUT=
SET /P INPUT=Please select a number:

IF /I '%INPUT%'=='1' call :process32
IF /I '%INPUT%'=='2' call :phacker64
IF /I '%INPUT%'=='M' call :mmenu

exit /b


:phacker32
start %cd%\bin\phacker\x86\ProcessHacker.exe
timeout /t 5 /nobreak
call :mmenu
exit /b

:phacker64
start %cd%\bin\phacker\x64\ProcessHacker.exe
timeout /t 5 /nobreak
call :mmenu
exit /b