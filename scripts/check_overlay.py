"""Check that a re-clone would give back every live character file as it is.

Why this exists
---------------
The live folders (`Tetsouo/`, `Kaories/`, ...) are gitignored. What git holds
is the templates (`_master/`, the generic layer, and `_master/<Char>/`, the
character's own overlay), and `clone_character.py` rebuilds a character from
them: it copies the templates, renames the source character, writes the
dualbox and region configs, then moves everything to the layout of 2026-09-30
(`migrate_layout.py`: `_common/`, `<job>/`, `saved/`).

Two failures hide there and neither shows up until a re-clone, which is far
too late:

  * a live file that no template gives back - lost if the folder goes;
  * a live file the re-clone would give back different - a re-clone silently
    reverts it (the old folder goes to `clone_backups/`, nobody looks there).
    This is how the PLD stance work of 2026-09-22 nearly went.

The check does not guess how a template maps to the live layout: it runs the
real cloner into a temporary folder and compares the result with the live
folder, file by file. Comparing by path alone stopped working with the layout
of 2026-09-30, when every live file moved and the old version of this script
called them all "without template".

Usage
-----
    python scripts/check_overlay.py            # Tetsouo and Kaories
    python scripts/check_overlay.py Kaories    # one of them
    python scripts/check_overlay.py -d Kaories # with the differing lines

Exits 1 when a live file would be lost or reverted by a re-clone.

Left out of the comparison: what the game writes (`saved/`, `atelier/`,
`logs/`, the per-job HUD files a re-clone copies back), the two configs the
cloner writes from its questions (DUALBOX_CONFIG, REGION_CONFIG), and files
rebuilt in game (WARP_ITEMS_OWNED).
"""
import contextlib
import difflib
import io
import os
import re
import shutil
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

# Hysoka and Gabvanstronger are one-shot clones, frozen by hand: not checked.
CHARACTERS = ['Tetsouo', 'Kaories']

GAME_WRITTEN_DIRS = ('saved/', 'atelier/', 'logs/')
GAME_WRITTEN = re.compile(r'^[a-z]{3}/display/[A-Z]{3}_HUD\.lua$')
CLONER_WRITTEN = {'_common/dualbox/DUALBOX_CONFIG.lua', '_common/region/REGION_CONFIG.lua'}
CLONER_WRITTEN_NAMES = {'DUALBOX_CONFIG.lua', 'REGION_CONFIG.lua', 'WARP_ITEMS_OWNED.lua'}


def read(path):
    """The file's content, line endings and @author lines aside (the templates say ejouanchicot since
    2026-09-27, files written in live before that still say Tetsouo: no change of behaviour)."""
    with io.open(path, 'rb') as fh:
        lines = fh.read().replace(b'\r\n', b'\n').split(b'\n')
    return b'\n'.join(l.rstrip() for l in lines if b'@author' not in l).rstrip()


def template_sources(char):
    """Live path (new layout) -> the template file a re-clone takes it from, the character's own
    overlay winning over the generic layer, as clone_character.py does."""
    from migrate_layout import new_place
    out = {}
    for layer in ('_master', '_master/' + char):        # generic first, the overlay overwrites
        base = os.path.join(REPO, layer)
        for top in ('entry', 'sets', 'config', 'config_global'):
            for rel, full in lua_files(os.path.join(base, top)).items():
                if top == 'entry':
                    old = '%s_%s' % (char, rel.split('_')[-1])
                else:
                    old = ('config' if top == 'config_global' else top) + '/' + rel
                out[new_place(old) or old] = full
    return out


def lua_files(root):
    out = {}
    for dirpath, dirnames, filenames in os.walk(root):
        for name in filenames:
            if name.endswith('.lua'):
                full = os.path.join(dirpath, name)
                out[os.path.relpath(full, root).replace('\\', '/')] = full
    return out


def ignored(rel):
    return (rel.startswith(GAME_WRITTEN_DIRS) or GAME_WRITTEN.match(rel) or rel in CLONER_WRITTEN
            or os.path.basename(rel) in CLONER_WRITTEN_NAMES)


def reclone(char):
    """Clone char from the templates into a temporary folder; returns (tmp, folder)."""
    import clone_character as cc
    tmp = tempfile.mkdtemp(prefix='overlay_check_')
    shutil.copytree(os.path.join(REPO, '_master'), os.path.join(tmp, '_master'))
    shutil.copy2(os.path.join(REPO, 'character_db.lua'), tmp)
    db = cc.parse_character_db(cc.Path(REPO) / 'character_db.lua').get(char)
    if not db:
        raise SystemExit('%s: not in character_db.lua' % char)
    cloner = cc.SmartCharacterCloner(base_dir=tmp)
    dualbox = {'role': db['role'], 'character_name': char, 'enabled': False}
    with contextlib.redirect_stdout(io.StringIO()):
        ok = cloner.clone(char, db['jobs'], dualbox, 'EU')
    if not ok:
        raise SystemExit('%s: the cloner failed' % char)
    return tmp, os.path.join(tmp, char)


def check(char, show_diff):
    live_root = os.path.join(REPO, char)
    if not os.path.isdir(live_root):
        print('%s: dossier absent\n' % char)
        return False
    tmp, clone_root = reclone(char)
    try:
        live = {r: p for r, p in lua_files(live_root).items() if not ignored(r)}
        clone = lua_files(clone_root)
        lost = sorted(r for r in live if r not in clone)
        reverted = sorted(r for r in live if r in clone and read(live[r]) != read(clone[r]))
        same = len(live) - len(lost) - len(reverted)

        print('=== %s : %d fichiers, %d rendus tels quels par un re-clonage' % (char, len(live), same))
        if lost:
            print('  PERDUS (%d) - aucun modele ne les rend :' % len(lost))
            for r in lost:
                print('      %s' % r)
        if reverted:
            sources = template_sources(char)
            print('  REMIS A L ANCIENNE VERSION (%d) - le modele differe du live :' % len(reverted))
            for r in reverted:
                a = read(clone[r]).decode('utf-8', 'replace').splitlines()
                b = read(live[r]).decode('utf-8', 'replace').splitlines()
                diff = [l for l in difflib.unified_diff(a, b, 'clone', 'live', lineterm='', n=0)
                        if l[:1] in '+-' and not l.startswith(('+++', '---'))]
                src = sources.get(r)
                newer = '?' if not src else ('live' if os.path.getmtime(live[r]) > os.path.getmtime(src) else 'modele')
                where = os.path.relpath(src, REPO).replace('\\', '/') if src else '?'
                print('      %s  (%d lignes, plus recent : %s, modele : %s)' % (r, len(diff), newer, where))
                if show_diff:
                    for l in diff[:40]:
                        print('          ' + l[:150])
        if not lost and not reverted:
            print('  tout est couvert et a jour')
        print()
        return bool(lost or reverted)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    args = sys.argv[1:]
    show_diff = '-d' in args
    wanted = [a for a in args if a != '-d'] or CHARACTERS
    failed = False
    for char in wanted:
        failed = check(char, show_diff) or failed
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
