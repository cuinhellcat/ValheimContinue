@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0installer\Install.ps1" -Mode Install
exit /b %errorlevel%
