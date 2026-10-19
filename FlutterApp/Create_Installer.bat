@echo off
title Smart Orders Desktop - Installer Creator
color 0A

echo.
echo ========================================
echo   Smart Orders Desktop
echo   Installer Creation Helper
echo ========================================
echo.
echo This script will help you create a professional .exe installer
echo.
pause

echo.
echo Step 1: Downloading Inno Setup...
echo.
echo Opening download page in your browser...
start https://jrsoftware.org/isdl.php
echo.
echo Please download and install Inno Setup from the opened page.
echo After installation, come back here and press any key to continue...
pause

echo.
echo Step 2: Checking if Inno Setup is installed...
echo.

if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    echo [OK] Inno Setup found!
    echo.
    echo Step 3: Compiling installer...
    echo.
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "%~dp0installer_script.iss"
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ========================================
        echo   SUCCESS!
        echo ========================================
        echo.
        echo Your installer has been created!
        echo.
        echo Location: %~dp0installer_output\SmartOrdersDesktop-v1.2.0-Setup.exe
        echo.
        echo Opening the output folder...
        explorer "%~dp0installer_output"
        echo.
        echo You can now distribute this .exe file!
        echo.
    ) else (
        echo.
        echo [ERROR] Compilation failed!
        echo Please check the error messages above.
        echo.
    )
) else (
    echo [ERROR] Inno Setup not found!
    echo.
    echo Please install Inno Setup first:
    echo 1. Download from: https://jrsoftware.org/isdl.php
    echo 2. Install it
    echo 3. Run this script again
    echo.
)

echo.
pause
