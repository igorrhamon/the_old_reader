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

REM Check if flutter-config.js exists, and if not, run the fixer
if not exist flutter-config.js (
    echo Flutter configuration not found. Running path fixer...
    call fix-flutter-path.bat
    if %ERRORLEVEL% neq 0 (
        echo Failed to configure Flutter path.
        pause
        exit /b 1
    )
    echo Flutter path configured successfully.
    echo.
)

REM Check if Flutter path is in the environment
echo Checking for Flutter installation...
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Flutter not found in PATH. Attempting to locate Flutter installation...
    
    REM Try common Flutter installation paths
    set "FLUTTER_PATHS=C:\flutter\bin;%LOCALAPPDATA%\flutter\bin;%APPDATA%\flutter\bin;%USERPROFILE%\flutter\bin;%USERPROFILE%\Documents\flutter\bin;%USERPROFILE%\development\flutter\bin;C:\src\flutter\bin"
    
    for %%p in (%FLUTTER_PATHS:;= %) do (
        if exist "%%p\flutter.bat" (
            echo Found Flutter at: %%p
            set "PATH=%%p;%PATH%"
            goto :flutter_found
        )
    )
    
    echo Flutter not found. Please install Flutter and add it to your PATH.
    echo You can download Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

:flutter_found
echo Flutter found in PATH.

REM Run the launcher script
echo Starting The Old Reader web app...
node start-web-app.js

REM If the script exits with an error, pause to show the message
if %ERRORLEVEL% neq 0 (
    echo The app launcher encountered an error.
    pause
    exit /b %ERRORLEVEL%
)

exit /b 0
    echo.
    echo The app launcher encountered an error.
    pause
)