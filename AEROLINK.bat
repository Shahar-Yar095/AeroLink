@echo off
title AeroLink Pro — Universal Android High-Speed Data Sync & Backup
cd /d "%~dp0"

echo =======================================================================
echo     AEROLINK PRO: UNIVERSAL HIGH-SPEED ANDROID DATA SYNC & BACKUP      
echo =======================================================================
echo  Starting Modern PC Desktop Interface...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0app_ui.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [FALLBACK] Launching Console CLI Mode...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0fast_backup.ps1"
    pause
)
