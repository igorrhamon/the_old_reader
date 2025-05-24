@echo off
echo ==========================================================
echo           THE OLD READER WEB APP LAUNCHER
echo ==========================================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: Node.js not found. Please install Node.js.
    echo Download: https://nodejs.org/
    pause
    exit /b 1
)

REM Run the launcher script
node start-web-app.js

REM If the script exits with an error, pause to show the message
if %ERRORLEVEL% neq 0 (
    echo.
    echo The app launcher encountered an error.
    pause
)