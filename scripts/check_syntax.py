"""Parse every Lua file in the project and report the ones that will not load.

Why this exists
---------------
A GearSwap file with a syntax error does not announce itself. `get_sets()`
aborts, and depending on where the break is you get a job with no sets, no
keybinds, or no commands - with nothing in the chat log saying why. This check
catches that class of mistake in a couple of seconds, before the game does.

It deliberately covers the live character folders as well as the tracked files.
Those folders are gitignored, but they are what the game actually loads, so a
tracked-only check misses exactly the files a player hits first.

Note that loadfile() proves a file parses. It does not prove it runs: a module
can compile and still fail on a bad require at load time. Clean output here
means "no syntax errors", not "everything works".

Usage
-----
    python scripts/check_syntax.py            # whole project
    python scripts/check_syntax.py shared     # one subtree

Exits 1 if anything failed to parse, so it can gate a commit.
"""
import os
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIVE_FOLDERS = ('Tetsouo', 'Kaories', 'Hysoka', 'Gabvanstronger')
SKIP_DIRS = {'.git', 'scripts', 'node_modules'}

# Windower ships Lua 5.1; anything newer would accept syntax the game rejects.
LUA_CANDIDATES = (
    'C:/ProgramData/chocolatey/bin/lua5.1.exe',
    'lua5.1',
    'lua5.1.exe',
    'lua',
)


def find_lua():
    for cand in LUA_CANDIDATES:
        try:
            r = subprocess.run([cand, '-v'], capture_output=True, text=True)
        except (OSError, FileNotFoundError):
            continue
        banner = (r.stdout or '') + (r.stderr or '')
        if '5.1' in banner:
            return cand
    return None


def collect(subtree=None):
    """Every .lua file under the repo, tracked or not, minus SKIP_DIRS."""
    root = os.path.join(REPO, subtree) if subtree else REPO
    found = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if name.endswith('.lua'):
                full = os.path.join(dirpath, name)
                found.append(os.path.relpath(full, REPO).replace('\\', '/'))
    return sorted(found)


def main():
    lua = find_lua()
    if not lua:
        print('Lua 5.1 introuvable. Installe-le (choco install lua51) ou ajoute '
              'son chemin a LUA_CANDIDATES.')
        return 2

    subtree = sys.argv[1] if len(sys.argv) > 1 else None
    files = collect(subtree)
    if not files:
        print('aucun fichier .lua trouve%s' % (' sous ' + subtree if subtree else ''))
        return 0

    # one Lua for every file (one each took minutes): it reads the paths, one a line, and writes
    # "<path>\t<error>" for each file that does not parse
    code = ("for p in io.stdin:lines() do local f, e = loadfile(p); "
            "if not f then io.write(p, '\\t', (tostring(e):gsub('\\n', ' ')), '\\n') end end")
    paths = {os.path.join(REPO, rel).replace('\\', '/'): rel for rel in files}
    r = subprocess.run([lua, '-e', code], input='\n'.join(paths) + '\n', capture_output=True,
                       text=True, encoding='utf-8', errors='replace', cwd=REPO)
    failures = []
    for line in r.stdout.splitlines():
        p, _, msg = line.partition('\t')
        failures.append((paths.get(p, p), msg.strip()))
    if r.returncode != 0:
        failures.append(('(lua)', (r.stderr or 'exit %d' % r.returncode).strip()))

    live = sum(1 for f in files if f.split('/')[0] in LIVE_FOLDERS)
    print('%d fichiers .lua controles (%d dans les dossiers personnages)'
          % (len(files), live))

    if not failures:
        print('aucune erreur de syntaxe')
        return 0

    print('\n%d fichier(s) ne compilent pas :' % len(failures))
    for rel, msg in failures:
        print('  %s' % rel)
        print('      %s' % msg)
    return 1


if __name__ == '__main__':
    sys.exit(main())
