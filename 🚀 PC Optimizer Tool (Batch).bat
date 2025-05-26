@echo off
title PC Optimizer - Made by Chill Guy
color 0a
setlocal enabledelayedexpansion

:: Check for administrator privileges
NET FILE >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo Requesting administrator privileges...
    timeout /t 1 >nul
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

:: Main Menu
:menu
cls
echo.
echo  ==============================
echo    PC OPTIMIZER - Made by Chill Guy
echo  ==============================
echo.
echo  1. Disable Unnecessary Services
echo  2. Disable Background Apps
echo  3. Disable Telemetry/Tracking
echo  4. Clean Temporary Files
echo  5. Optimize Power Settings
echo  6. Disable Visual Effects
echo  7. Restore Default Services (Undo)
echo  8. Run All Optimizations
echo  9. Exit
echo.
set /p choice=Enter your choice (1-9): 

if "%choice%"=="1" goto services
if "%choice%"=="2" goto background
if "%choice%"=="3" goto telemetry
if "%choice%"=="4" goto cleanup
if "%choice%"=="5" goto power
if "%choice%"=="6" goto visual
if "%choice%"=="7" goto restore
if "%choice%"=="8" goto all
if "%choice%"=="9" exit

echo Invalid choice, please try again
timeout /t 2 >nul
goto menu

:: Disable unnecessary services
:services
cls
echo Disabling unnecessary services...
echo Creating restore point just in case...
echo.

:: Create restore point
powershell -Command "Checkpoint-Computer -Description 'Pre-PC-Optimizer-Changes' -RestorePointType MODIFY_SETTINGS" >nul 2>&1

:: Services to disable (safe ones that won't break your system)
set services=(
    "DiagTrack"           "Connected User Experiences and Telemetry"
    "DPS"                 "Diagnostic Policy Service"
    "dmwappushservice"    "Diagnostic Management Service"
    "WMPNetworkSvc"       "Windows Media Player Network Sharing"
    "WerSvc"              "Windows Error Reporting"
    "Fax"                 "Fax Service"
    "lfsvc"               "Geolocation Service"
    "MapsBroker"          "Downloaded Maps Manager"
    "wscsvc"              "Windows Security Center Service"
    "RemoteRegistry"      "Remote Registry"
)

for /f "tokens=1,2" %%a in ('echo %services%') do (
    echo Stopping and disabling: %%b
    sc stop "%%a" >nul 2>&1
    sc config "%%a" start= disabled >nul
    if errorlevel 1 (
        echo Failed to disable: %%b
    ) else (
        echo Successfully disabled: %%b
    )
    echo.
)

echo Services optimization complete!
echo Note: Some services may restart after reboot
pause
goto menu

:: Disable background apps
:background
cls
echo Disabling background apps...
echo.

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul
if errorlevel 1 (echo Failed to disable user background apps) else (echo Disabled user background apps)

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d 2 /f >nul
if errorlevel 1 (echo Failed to disable system background apps) else (echo Disabled system background apps)

:: Disable specific background apps
set apps=(
    "Microsoft.SkypeApp"
    "Microsoft.YourPhone"
    "Microsoft.XboxApp"
    "Microsoft.ZuneMusic"
)

for %%a in (%apps%) do (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\%%a" /v "Disabled" /t REG_DWORD /d 1 /f >nul
    if errorlevel 1 (
        echo Failed to disable %%a
    ) else (
        echo Disabled background access for %%a
    )
)

echo.
echo Background apps disabled!
pause
goto menu

:: Disable telemetry and tracking
:telemetry
cls
echo Disabling telemetry and tracking...
echo.

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
if errorlevel 1 (echo Failed to disable telemetry) else (echo Disabled telemetry collection)

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
if errorlevel 1 (echo Failed to disable data collection) else (echo Disabled additional data collection)

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul
if errorlevel 1 (echo Failed to disable advertising ID) else (echo Disabled advertising ID)

:: Disable Cortana telemetry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul
if errorlevel 1 (echo Failed to disable Cortana) else (echo Disabled Cortana)

echo.
echo Telemetry and tracking disabled!
pause
goto menu

:: Clean temporary files
:cleanup
cls
echo Cleaning temporary files...
echo This may take several minutes...
echo.

echo Cleaning Temp folders...
del /q /f /s "%temp%\*" >nul 2>&1
del /q /f /s "%systemroot%\temp\*" >nul 2>&1
del /q /f /s "%systemroot%\Prefetch\*" >nul 2>&1

echo Running Disk Cleanup...
cleanmgr /sagerun:1 >nul
if errorlevel 1 (
    echo Disk Cleanup failed. Running basic cleanup...
    rd /s /q "%systemroot%\Temp" >nul 2>&1
    md "%systemroot%\Temp" >nul 2>&1
)

echo Clearing thumbnail cache...
del /f /s /q "%localappdata%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1

echo.
echo Temporary files cleaned!
pause
goto menu

:: Optimize power settings
:power
cls
echo Optimizing power settings...
echo.

echo Setting high performance power plan...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul
if errorlevel 1 (
    echo Failed to set power plan. Creating custom plan...
    powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul
    powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a >nul
)

echo Disabling hibernation...
powercfg /h off >nul
if errorlevel 1 (echo Failed to disable hibernation) else (echo Hibernation disabled)

echo Optimizing USB selective suspend...
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul

echo.
echo Power settings optimized for performance!
pause
goto menu

:: Disable visual effects
:visual
cls
echo Disabling visual effects...
echo.

echo Optimizing visual performance settings...
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "0" /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012008012812000" /f >nul
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "3" /f >nul

:: Disable animations
reg add "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableStatusMessages" /t REG_DWORD /d "1" /f >nul

echo.
echo Visual effects optimized for performance!
pause
goto menu

:: Restore default services
:restore
cls
echo Restoring default services...
echo.

set services=(
    "DiagTrack"           "Connected User Experiences and Telemetry"
    "DPS"                 "Diagnostic Policy Service"
    "dmwappushservice"    "Diagnostic Management Service"
    "WMPNetworkSvc"       "Windows Media Player Network Sharing"
    "WerSvc"              "Windows Error Reporting"
    "Fax"                 "Fax Service"
    "lfsvc"               "Geolocation Service"
    "MapsBroker"          "Downloaded Maps Manager"
    "wscsvc"              "Windows Security Center Service"
    "RemoteRegistry"      "Remote Registry"
)

for /f "tokens=1,2" %%a in ('echo %services%') do (
    echo Restoring: %%b
    sc config "%%a" start= demand >nul
    if errorlevel 1 (
        echo Failed to restore: %%b
    ) else (
        echo Successfully restored: %%b
    )
    echo.
)

echo Default services restored!
pause
goto menu

:: Run all optimizations
:all
cls
echo Running all optimizations...
echo This may take several minutes...
echo Creating restore point first...
echo.

powershell -Command "Checkpoint-Computer -Description 'Pre-PC-Optimizer-Changes' -RestorePointType MODIFY_SETTINGS" >nul 2>&1

call :services
call :background
call :telemetry
call :cleanup
call :power
call :visual

echo.
echo All optimizations complete!
echo Recommend restarting your computer for full effect
pause
goto menu