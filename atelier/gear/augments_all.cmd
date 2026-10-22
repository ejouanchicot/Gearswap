@echo off
rem Rebuild the augment layer and run its checks (see AUGMENTS.md).
rem The sources must already be in cache\ (LSB, OmniWatch, BG Wiki pages).
cd /d "%~dp0"
python augments_lsb_parse.py || exit /b 1
python augments_extdata_dump.py || exit /b 1
python augments_build.py || exit /b 1
node augments_unity_match.js || exit /b 1
python augments_build.py || exit /b 1
python capes_build.py || exit /b 1
node augments_parse_test.js || exit /b 1
node augments_check_bgwiki.js
rem the comparisons with wsdist's gear.py: local tools, kept on this PC only (README.md)
if exist capes_gearpy_dump.py python capes_gearpy_dump.py && node capes_check.js
if exist augments_gearpy_extract.py python augments_gearpy_extract.py && python augments_check_gearpy.py
