@echo off

setlocal enableextensions enabledelayedexpansion

SET varDefaultGateway=
for /f "tokens=1-2 delims=:" %%a in ('ipconfig^|find "Default"') do (
	if not defined varDefaultGateway SET varDefaultGateway=%%b
)
SET varDefaultGateway=%varDefaultGateway:~1,25%
ECHO Default gateway is %varDefaultGateway%.

SET /P varIPtoTest=IP to test:
SET /P varPorttoTest=Port to test:

echo Testing connectivity to %varDefaultGateway% and %varIPtoTest%:%varPorttoTest%.
echo At any time, press Ctrl+C to exit the program. Results are saved in the log folder.
pause

SET varFileName=%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%-Log-%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%-%varDefaultGateway%-%varIPtoTest%-%varPorttoTest%.csv
ECHO date;time;SSID;AccessPointMacAddress;Channel;Signal;PingGatewayTimeInMS;PingDestinationTimeInMS;OpenConnectionInDestinationPort > log\%varFileName%

:loop
	
	SET varOutput1=---
	SET varOutput2=---
	SET varOutput3=---
	SET varOutput4=---
	SET varOutput5=timeout
	SET varOutput6=timeout
	SET varOutput7=error
	
	REM Get connected SSID
	FOR /F "tokens=* USEBACKQ" %%F IN (`netsh wlan show int ^| find " SSID "`) DO (
		SET varOutput1=%%F
	)
	SET varOutput1=%varOutput1:~25,100%
	
	REM Get mac-address of connected AP.
	FOR /F "tokens=* USEBACKQ" %%F IN (`netsh wlan show int ^| find "BSSID"`) DO (
		SET varOutput2=%%F
	)
	SET varOutput2=%varOutput2:~25,100%
	
	REM Get Used Wi-Fi channel.
	FOR /F "tokens=* USEBACKQ" %%F IN (`netsh wlan show int ^| find "Channel"`) DO (
		SET varOutput3=%%F
	)
	SET varOutput3=%varOutput3:~25,100%
	
	REM Get signal power.
	FOR /F "tokens=* USEBACKQ" %%F IN (`netsh wlan show int ^| find "Signal"`) DO (
		SET varOutput4=%%F
	)
	SET varOutput4=%varOutput4:~25,5%
	
	REM Ping default Gateway.
	FOR /F "tokens=4 delims=Replyfrombytes=time<ms USEBACKQ" %%F IN (`ping -n  1 -w 200 %varDefaultGateway% ^| find "Reply"`) DO (
		SET varOutput5=%%F
	)
	
	REM Ping chosen IP.
	FOR /F "tokens=4 delims=Replyfrombytes=time<ms USEBACKQ" %%F IN (`ping -n  1 -w 200 %varIPtoTest% ^| find "Reply"`) DO (
		SET varOutput6=%%F
	)
	
	REM Try to connect to IP:Port.
	FOR /F "tokens=* USEBACKQ" %%F IN (`lib\netcat-1.11\nc.exe -nzv -w 2 %varIPtoTest% %varPorttoTest% 2^>^&1`) DO (
		SET varOutput7=%%F
	)
	echo.%varOutput7%|findstr /C:"open" >nul 2>&1
	if not errorlevel 1 (
		SET varOutput7=OK
	) else (
    SET varOutput7=error
	)
	
	ECHO %DATE%;%TIME%;%varOutput1%;%varOutput2%;%varOutput3%;%varOutput4%;%varOutput5%;%varOutput6%;%varOutput7% >> log\%varFileName%
	ECHO %DATE%;%TIME%;%varOutput1%;%varOutput2%;%varOutput3%;%varOutput4%;%varOutput5%;%varOutput6%;%varOutput7%
	
	timeout 1 > nul
	
  goto :loop

endlocal