@echo off
title AeroLink Pro (Console High-Speed Mode)
cd /d "%~dp0"

echo =======================================================================
echo     AEROLINK PRO: UNIVERSAL HIGH-SPEED CLI DATA SYNC ENGINE             
echo =======================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0fast_backup.ps1"

pause
