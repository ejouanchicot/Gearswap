@echo off
REM ============================================================================
REM Tetsouo GearSwap Character Cloner - Windows Launcher
REM ============================================================================
REM Double-click this file to clone a character
REM ============================================================================

cd /d "%~dp0"

echo.
echo ======================================================================
echo   TETSOUO GEARSWAP CHARACTER CLONER - LAUNCHER
echo ======================================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH!
    echo.
    echo Please install Python 3.8+ from: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

REM Check for language argument
set LANG_ARG=%1

if "%LANG_ARG%"=="" (
    REM Default: French
    python clone_character.py
) else if /i "%LANG_ARG%"=="en" (
    REM English
    python clone_character.py --lang en
) else if /i "%LANG_ARG%"=="fr" (
    REM French
    python clone_character.py --lang fr
) else (
    echo.
    echo USAGE:
    echo   CLONE_CHARACTER.bat       (French - default)
    echo   CLONE_CHARACTER.bat en    (English)
    echo   CLONE_CHARACTER.bat fr    (French)
    echo.
    pause
    exit /b 1
)

REM Script will handle its own pause, so just exit
exit /b 0
