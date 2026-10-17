"""
make_package.py builds the zip a player is sent: check it on every character of
character_db.lua, against clone_character.py run the usual way.

  - the character's folder in the zip is the one clone_character.py writes (every
    file, byte for byte), in a copy of _master/: the data folder is not touched
  - the zip holds the GearSwap addon, Mote's libraries, shared/, the Atelier page
    and its engine, the AtelierLink addon, and INSTALLATION.txt
  - nothing private goes in: another character's folder, the Atelier's link keys
    (link_*.js) and live files, its icons, _master/, notes, scripts but AtelierLink
  - without lua5.1 (the page's Python has none): read_lua_table reads TUNING, AUTO_ABILITIES
    and BUFF_CONFIG (all migrate_config reads) as Lua does, and every package is the same
    (the page's own run, in Chrome: make_package_page_test.js)

    python scripts/atelier/make_package_test.py

@author ejouanchicot
@date   Created: 2026-10-16
"""
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

DATA = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
sys.path.insert(0, DATA)
import make_package  # noqa: E402

fails = []


def check(ok, what):
    if not ok:
        fails.append(what)


def files_of(root):
    out = {}
    for folder, _, files in os.walk(root):
        for f in files:
            p = os.path.join(folder, f)
            with open(p, 'rb') as h:
                out[os.path.relpath(p, root).replace('\\', '/')] = h.read()
    return out


def reference_clone(name, jobs, role, region):
    """clone_character.py as the .bat runs it, in a copy of the data folder's clone inputs."""
    work = tempfile.mkdtemp(prefix='gs_ref_')
    shutil.copytree(os.path.join(DATA, '_master'), os.path.join(work, '_master'))
    for f in make_package.CLONE_FILES:
        shutil.copy2(os.path.join(DATA, f), os.path.join(work, f))
    answers = '%s\n\n%s\no\n\n' % (name, region) if role == 'main' else '%s\nTetsouo\n%s\no\n\n' % (name, region)
    run = subprocess.run([sys.executable, 'clone_character.py'], cwd=work, input=answers, text=True,
                         capture_output=True, encoding='utf-8', env=dict(os.environ, PYTHONIOENCODING='utf-8'))
    check(os.path.isdir(os.path.join(work, name)), '%s: the usual clone ran (%s)' % (name, run.stdout[-300:]))
    return work


chars = make_package.importlib.import_module('clone_character').parse_character_db(
    make_package.importlib.import_module('clone_character').Path(DATA) / 'character_db.lua')
before = {n: os.path.isdir(os.path.join(DATA, n)) for n in chars}
for name, info in sorted(chars.items()):
    buf = io.BytesIO()
    partner = None if info['role'] == 'main' else 'Tetsouo'
    make_package.build(name, data_dir=DATA, partner=partner, region='US', out=buf)
    z = zipfile.ZipFile(buf)
    names = z.namelist()
    prefix = 'GearSwap/data/%s/' % name
    got = {n[len(prefix):]: z.read(n) for n in names if n.startswith(prefix)}
    ref_root = reference_clone(name, info['jobs'], info['role'], 'US')
    try:
        ref = files_of(os.path.join(ref_root, name))
        check(set(got) == set(ref), '%s: the same files as the usual clone (%s)' % (
            name, ', '.join(sorted(set(got) ^ set(ref))[:5])))
        diff = [k for k in got if k in ref and got[k] != ref[k]]
        check(not diff, '%s: the same bytes as the usual clone (%s)' % (name, ', '.join(diff[:5])))
    finally:
        shutil.rmtree(ref_root, ignore_errors=True)
    for need in ('INSTALLATION.txt', 'GearSwap/gearswap.lua', 'GearSwap/libs/Mote-Include.lua',
                 'GearSwap/data/shared/entry/war.lua', 'GearSwap/data/atelier.html', 'GearSwap/data/atelier/index.html',
                 'GearSwap/data/atelier/app/js/core.js', 'GearSwap/data/atelier/lua/lua51.js',
                 'GearSwap/data/scripts/atelier/AtelierLink/AtelierLink.lua', 'GearSwap/data/scripts/atelier/load_job.lua'):
        check(need in names, '%s: the package holds %s' % (name, need))
    check(any(n.startswith('GearSwap/data/atelier/engine/') for n in names), '%s: the package holds the engine' % name)
    # the Packages page stays home: not in the zip; the page is the built one (atelier/src/), which goes on without it
    check(not any('GearSwap/' + p in names for p in make_package.PAGE_ONLY), '%s: packages.js, package_exports.js are not in a package' % name)
    page = z.read('GearSwap/' + make_package.PAGE_INDEX).decode('utf-8')
    check('<meta name="atelier-build"' in page, '%s: the package\'s page is the built one' % name)
    # the Atelier's exports (make_package.add_exports, Node): every job, its main subjob, listed in atelier/index.js
    if shutil.which('node'):
        tmp = tempfile.mkdtemp(prefix='gs_pkgx_')
        try:
            path = os.path.join(tmp, 'p.zip')
            with open(path, 'wb') as handle:
                handle.write(buf.getvalue())
            done = make_package.add_exports(path, name)
            check(not done['failed'] and done['exported'] == len(info['jobs']), '%s: every job exported for the Atelier (%s)' % (name, done))
            with zipfile.ZipFile(path) as zx:
                index = zx.read('GearSwap/data/atelier/index.js').decode('utf-8')
                exports = [n for n in zx.namelist() if n.startswith(prefix + 'atelier/exports/')]
                icons = {n for n in zx.namelist() if n.startswith('GearSwap/data/atelier/icons/')}
                named = set()
                for n in exports:
                    m = re.search(r'"icons":(\{[^{}]*\})', zx.read(n).decode('utf-8'))
                    named |= {'GearSwap/data/atelier/icons/%d.bmp' % i for i in json.loads(m.group(1)).values()} if m else set()
                kept = {n for n in named if os.path.isfile(os.path.join(DATA, n[len('GearSwap/data/'):]))}
            check(len(exports) == len(info['jobs']) and all(n[len(prefix):] in index for n in exports),
                  '%s: the exports are listed in atelier/index.js' % name)
            # the icons of the items its sets name, as the maker's data/atelier/icons/ has them, and no other
            check(icons and icons == kept and done['icons'] == len(icons),
                  '%s: the icons of its items are in the package (%d of %d named, %d kept here)' % (name, len(icons), len(named), len(kept)))
        finally:
            shutil.rmtree(tmp, ignore_errors=True)
    others = [o for o in chars if o != name]
    for n in names:
        bad = (re.match(r'GearSwap/data/atelier/(link_|live_)', n) or n.startswith('GearSwap/data/atelier/icons/')
               or n.startswith('GearSwap/data/_master/') or n.startswith('GearSwap/data/notes/')
               or n.startswith('GearSwap/data/atelier/Img/')
               or (n.startswith('GearSwap/data/scripts/') and '/AtelierLink/' not in n and not n.endswith('load_job.lua'))
               or any(n.startswith('GearSwap/data/%s/' % o) for o in others + ['Tetsouo', 'Kaories', 'Hysoka'] if o != name))
        check(not bad, '%s: %s is not in a package' % (name, n))
for n, was in before.items():
    check(os.path.isdir(os.path.join(DATA, n)) == was, 'the data folder is not touched (%s)' % n)

# The page has no lua5.1: migrate_config then reads its three files (TUNING, AUTO_ABILITIES,
# BUFF_CONFIG) with read_lua_table, which must agree with Lua on every copy of them in _master/,
# and every package built that way must be the one built with Lua.
which = shutil.which
if which('lua5.1') or which('lua'):
    import migrate_config  # noqa: E402
    n = 0
    for folder, _, files in os.walk(os.path.join(DATA, '_master')):
        for f in files:
            if f in ('TUNING.lua', 'AUTO_ABILITIES.lua', 'BUFF_CONFIG.lua'):
                p = os.path.join(folder, f)
                a, b = migrate_config.read_lua(p), make_package.read_lua_table(p)
                check(a and json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True),
                      'read_lua_table reads %s as Lua does' % os.path.relpath(p, DATA))
                n += 1
    check(n > 0, 'settings files read')

    def zipped(name, info):
        buf = io.BytesIO()
        make_package.build(name, data_dir=DATA, partner=None if info['role'] == 'main' else 'Tetsouo', out=buf)
        z = zipfile.ZipFile(buf)
        return {n: z.read(n) for n in z.namelist()}
    for name, info in sorted(chars.items()):
        with_lua = zipped(name, info)
        shutil.which = lambda *a, **k: None
        try:
            without = zipped(name, info)
        finally:
            shutil.which = which
        diff = sorted(k for k in set(with_lua) | set(without) if with_lua.get(k) != without.get(k))
        check(not diff, '%s: the same package without Lua (%s)' % (name, ', '.join(diff[:5])))

for f in fails:
    print('FAIL ' + f)
print('%d characters packaged, %d failed check(s)' % (len(chars), len(fails)) if fails
      else '%d characters packaged, each one the usual clone, nothing private in it' % len(chars))
sys.exit(1 if fails else 0)
