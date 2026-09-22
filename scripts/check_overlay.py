"""Check that every live character file can be regenerated from the templates.

Why this exists
---------------
The live folders (`Tetsouo/`, `Kaories/`, ...) are gitignored. What git holds
is the templates, and `clone_character.py` rebuilds a character from them
through a three-layer chain:

    <Char>/<path>   <-  _master/<Char>/<path>   <-  _master/<path>

with one rename on the way: a character's global configs live in `config/`,
while the templates keep them in `config_global/`. Entry points are matched by
job rather than by name, since `Kaories_RDM.lua` comes from
`_master/Kaories/entry/Kaories_RDM.lua` or `_master/entry/Tetsouo_RDM.lua`.

Two failures hide in that chain and neither shows up until a redeploy, which
is far too late:

  * a live file with no layer behind it - lost for good if the folder goes;
  * a live file that differs from its own overlay - a redeploy silently
    reverts it. This is how the PLD stance work of 2026-09-22 nearly went:
    written to the live folder only, absent from `_master/Tetsouo/sets/pld/`.

`CharDB.validate()` does not catch either. It checks that every job is
assigned to a character or the archive and answers "OK - all 16 jobs
assigned" without ever asking whether a file exists.

Usage
-----
    python scripts/check_overlay.py            # all characters
    python scripts/check_overlay.py Tetsouo    # one of them

Exits 1 when a live file has no template behind it.

Divergence is only reported when the match came from the character's **own**
overlay (`_master/<Char>/`), because that layer exists precisely to say "this
file belongs to this character" - so the two differing means one of them is
stale. A live file that falls back to the generic `_master/` layer is expected
to differ: the templates deliberately stay flat while Tetsouo's live sets are
modular (see docs/dev section 15.1), and macrobook pages, lockstyle numbers
and states are personal by nature. Reporting those would bury the real
findings, which is how a check stops being run.
"""
import io
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Most specific layer first. A character absent from here is not checked -
# Hysoka and Gabvanstronger are one-shot clones, frozen by hand.
CHAIN = {
    'Tetsouo': ['_master/Tetsouo', '_master'],
    'Kaories': ['_master/Kaories', '_master'],
}

# Live path prefix -> the name the templates use for it.
RENAMES = {'config/': 'config_global/'}

SKIP_DIRS = {'.git', 'scripts', 'node_modules'}

# Regenerated in game rather than written by hand, so having no template is
# correct: `//gs c wo scan` rebuilds this from what the character actually owns,
# and a stale template would be worse than none.
REGENERABLE = {'config/WARP_ITEMS_OWNED.lua'}


def read(path):
    with io.open(path, 'rb') as fh:
        return fh.read().replace(b'\r\n', b'\n')


def candidates(char, rel, layers):
    """Template paths that could supply <char>/<rel>, best layer first."""
    out = []
    for layer in layers:
        out.append('%s/%s' % (layer, rel))

        # A character's global config sits one directory up in the templates.
        for live_prefix, tpl_prefix in RENAMES.items():
            if rel.startswith(live_prefix) and '/' not in rel[len(live_prefix):]:
                out.append('%s/%s%s' % (layer, tpl_prefix, rel[len(live_prefix):]))

        # Entry point at the character root: matched by job, not by file name.
        if '/' not in rel and rel.endswith('.lua'):
            job = rel[:-4].split('_')[-1]
            out.append('%s/entry/%s_%s.lua' % (layer, char, job))
            out.append('%s/entry/Tetsouo_%s.lua' % (layer, job))
    return out


def check(char, layers):
    root = os.path.join(REPO, char)
    if not os.path.isdir(root):
        return None

    own_overlay = layers[0]
    missing, diverged, generic, ok = [], [], 0, 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if not name.endswith('.lua'):
                continue
            live = os.path.join(dirpath, name)
            rel = os.path.relpath(live, root).replace('\\', '/')

            found = None
            for cand in candidates(char, rel, layers):
                if os.path.exists(os.path.join(REPO, cand)):
                    found = cand
                    break

            if not found:
                if rel not in REGENERABLE:
                    missing.append(rel)
            elif read(live) == read(os.path.join(REPO, found)):
                ok += 1
            elif found.startswith(own_overlay + '/'):
                diverged.append((rel, found))
            else:
                # Fell back to the generic layer, which is meant to differ.
                generic += 1

    return missing, diverged, generic, ok


def main():
    wanted = sys.argv[1:] or sorted(CHAIN)
    failed = False

    for char in wanted:
        if char not in CHAIN:
            print('%s: pas dans la chaine d overlays (clone figé ?) - ignoré' % char)
            continue
        result = check(char, CHAIN[char])
        if result is None:
            print('%s: dossier absent' % char)
            continue
        missing, diverged, generic, ok = result

        print('=== %s : %d identiques, %d sur template generique (ecart attendu)'
              % (char, ok, generic))

        if missing:
            failed = True
            print('  SANS TEMPLATE (%d) - perdus si le dossier disparait :' % len(missing))
            for rel in sorted(missing):
                print('      %s' % rel)

        if diverged:
            print('  DIVERGENTS DE LEUR PROPRE OVERLAY (%d) - un redeploiement les'
                  % len(diverged))
            print('  ecraserait, et cet overlay existe pour dire qu ils devraient')
            print('  etre identiques : l un des deux est perime.')
            for rel, src in sorted(diverged):
                print('      %s' % rel)
                print('          template : %s' % src)

        if not missing and not diverged:
            print('  tout est couvert et a jour')
        print()

    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
