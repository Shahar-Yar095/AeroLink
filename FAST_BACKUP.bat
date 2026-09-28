@echo off
title 100X Ultra Fast Vivo Phone Data Move & Sync PRO
cd /d "%~dp0"

echo =======================================================================
echo         100X ULTRA-FAST VIVO / ANDROID SMART DATA SYNC & MOVE         
echo =======================================================================
echo  Starting Modern PC Desktop Application...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0app_ui.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [FALLBACK] Launching Console Mode...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0fast_backup.ps1"
    pause
)
