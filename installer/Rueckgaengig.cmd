@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0installer\Install.ps1" -Mode Restore
exit /b %errorlevel%
