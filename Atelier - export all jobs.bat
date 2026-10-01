@echo off
rem Atelier: export every job of every character for atelier.html, without the game.
rem Needs Python 3 and Lua 5.1. Details: scripts\atelier\atelier_all.py
cd /d "%~dp0"
python scripts\atelier\atelier_all.py %*
pause
