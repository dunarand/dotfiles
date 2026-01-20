@echo off
setlocal enabledelayedexpansion

reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

set "RED=[91m"
set "GREEN=[92m"
set "BLUE=[94m"
set "YELLOW=[93m"
set "NC=[0m"

echo %GREEN%=== Windows Package Installer ===%NC%
echo.

set "SCRIPT_DIR=%~dp0"
set "PACKAGES_FILE=%SCRIPT_DIR%..\packages\windows.txt"

where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%Error: winget is not installed or not in PATH%NC%
    echo %YELLOW%Please install winget from Microsoft Store or https://aka.ms/getwinget%NC%
    pause
    exit /b 1
)

echo %GREEN%Found winget version:%NC%
winget --version
echo.

if not exist "%PACKAGES_FILE%" (
    echo %RED%Error: windows.txt not found at %PACKAGES_FILE%%NC%
    pause
    exit /b 1
)

echo %YELLOW%Updating winget sources...%NC%
winget source update
echo.

echo %BLUE%=== Installing packages from windows.txt ===%NC%
echo.

set "INSTALLED=0"
set "FAILED=0"
set "SKIPPED=0"

for /f "usebackq delims=" %%a in ("%PACKAGES_FILE%") do (
    set "line=%%a"
    
    if "!line!"=="" (
        set /a "SKIPPED+=1"
        goto :continue
    )
    
    echo !line! | findstr /r "^#" >nul
    if !errorlevel! equ 0 (
        set /a "SKIPPED+=1"
        goto :continue
    )
    
    echo %GREEN%Installing: !line!%NC%
    
    winget show --id="!line!" --exact >nul 2>&1
    if !errorlevel! neq 0 (
        echo %RED%  ✗ Package not found: !line!%NC%
        echo %YELLOW%    Tip: Search with: winget search "!line!"
        set /a "FAILED+=1"
        goto :continue_install
    )
    
    winget install --id="!line!" --exact --silent --accept-source-agreements --accept-package-agreements
    
    if !errorlevel! equ 0 (
        echo %GREEN%  ✓ Successfully installed !line!%NC%
        set /a "INSTALLED+=1"
    ) else (
        winget list --id="!line!" --exact >nul 2>&1
        if !errorlevel! equ 0 (
            echo %YELLOW%  ⚠ Already installed: !line!%NC%
        ) else (
            echo %RED%  ✗ Failed to install: !line!%NC%
        )
        set /a "FAILED+=1"
    )
    
    :continue_install
    echo.
    
    :continue
)

echo.
echo %BLUE%=== Installation Summary ===%NC%
echo %GREEN%Successfully installed: %INSTALLED%%NC%
echo %YELLOW%Failed/Already installed: %FAILED%%NC%
echo Skipped (comments/empty): %SKIPPED%
echo.
echo %GREEN%✓ Package installation complete!%NC%
echo.

pause
endlocal
