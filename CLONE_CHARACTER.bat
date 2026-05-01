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

REM Usage:
REM   CLONE_CHARACTER.bat                          -> FR, source Tetsouo
REM   CLONE_CHARACTER.bat en                       -> EN, source Tetsouo
REM   CLONE_CHARACTER.bat --source Kaories         -> FR, source Kaories
REM   CLONE_CHARACTER.bat en --source Kaories      -> EN, source Kaories

set FIRST=%1
if /i "%FIRST%"=="--help" goto :usage
if /i "%FIRST%"=="-h"     goto :usage

REM If first arg is a bare lang code, convert it to --lang and shift.
if /i "%FIRST%"=="fr" (
    shift
    python clone_character.py --lang fr %1 %2 %3 %4
    goto :end
)
if /i "%FIRST%"=="en" (
    shift
    python clone_character.py --lang en %1 %2 %3 %4
    goto :end
)

REM Otherwise pass all args through (default lang = fr handled by Python).
python clone_character.py %*
goto :end

:usage
echo.
echo USAGE:
echo   CLONE_CHARACTER.bat                          (FR, source Tetsouo)
echo   CLONE_CHARACTER.bat en                       (EN, source Tetsouo)
echo   CLONE_CHARACTER.bat --source Kaories         (FR, rebuild Kaories from her template)
echo   CLONE_CHARACTER.bat en --source Kaories      (EN, rebuild Kaories from her template)
echo.
pause
exit /b 0

:end

REM Script will handle its own pause, so just exit
exit /b 0
