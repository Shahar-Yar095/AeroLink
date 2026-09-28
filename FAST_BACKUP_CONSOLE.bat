@echo off
title Vivo Ultra-Fast Data Move & Sync (Console Mode)
cd /d "%~dp0"

echo =======================================================================
echo          100X HIGH SPEED PHONE DATA TRANSFER & MOVE (CONSOLE)              
echo =======================================================================
echo   * MOVE MODE: Safely moves data to PC and frees phone storage
echo   * COPY MODE: Backs up data while keeping originals on phone
echo   * AUTO-SKIP: Instantly skips files already present on PC
echo =======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0fast_backup.ps1"

echo.
pause
