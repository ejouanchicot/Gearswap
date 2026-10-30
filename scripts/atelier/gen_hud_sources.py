"""Write atelier/app/js/hud_sources.js: the Lua files of GearSwap's HUD that the Atelier page runs to draw its live
preview (atelier/app/js/hud_preview.js; SPEC notes/docs-perso/hud-apercu-2026-10-30). The list is not written by hand:
the HUD is rendered once outside the game (scripts/atelier/hud_harness.lua, with lua5.1) and every module it loaded is
kept, with the harness itself. Run before each build of the page (atelier/package.json "build"); without lua5.1 the
file already there is kept.
    python scripts/atelier/gen_hud_sources.py
@author ejouanchicot"""
import json, os, shutil, subprocess, sys, tempfile

DATA = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
OUT = os.path.join(DATA, 'atelier', 'app', 'js', 'hud_sources.js')
HARNESS = 'scripts/atelier/hud_harness.lua'

# a sample to render: rows of two sections, two modes (what the harness needs to walk the whole HUD code)
PROBE = r"""
HUD_ROOT = %s
HUD_IN = {char = '__probe', job = 'WHM', sub = 'RDM', keys = {
  {key = '^numpad7', desc = 'Main Weapon', state = 'MainWeapon'}, {key = '^numpad1', desc = 'Idle Mode', state = 'IdleMode'}},
  modes = {MainWeapon = {current = 'A', values = {'A', 'B'}}, IdleMode = {current = 'PDT', values = {'PDT', 'Refresh'}}}}
dofile(HUD_ROOT .. 'data/%s')
for name in pairs(package.loaded) do if name:find('/') and not name:find('^__probe') then print('MOD ' .. name) end end
"""


def main():
    lua = shutil.which('lua5.1') or shutil.which('lua')
    if not lua:
        print('no lua5.1: %s kept as it is' % OUT); return
    root = os.path.dirname(DATA).replace('\\', '/') + '/'      # the GearSwap folder, holding data/
    with tempfile.NamedTemporaryFile('w', suffix='.lua', delete=False, encoding='utf-8') as f:
        f.write(PROBE % (json.dumps(root), HARNESS))
    try:
        r = subprocess.run([lua, f.name], capture_output=True, text=True, cwd=DATA)
    finally:
        os.unlink(f.name)
    mods = sorted(l[4:].strip() for l in r.stdout.splitlines() if l.startswith('MOD '))
    if r.returncode or not mods:
        sys.exit('the HUD did not render outside the game:\n' + r.stderr[-2000:])
    files = {}
    for m in mods + [HARNESS[:-4]]:
        with open(os.path.join(DATA, m + '.lua'), encoding='utf-8', newline='') as h:
            files[m + '.lua'] = h.read()
    text = ("// GearSwap Atelier · hud_sources.js: GearSwap's HUD code (Lua) for the live preview of the Settings' Display\n"
            "// (hud_preview.js). Written by scripts/atelier/gen_hud_sources.py at each build: never by hand.\n"
            "const HUD_SOURCES = " + json.dumps(files, ensure_ascii=False) + ";\n")
    old = open(OUT, encoding='utf-8').read() if os.path.exists(OUT) else ''
    if old != text:
        open(OUT, 'w', encoding='utf-8', newline='\n').write(text)
    print('HUD sources: %d files, %d bytes%s' % (len(files), len(text), '' if old != text else ' (unchanged)'))


if __name__ == '__main__':
    main()
