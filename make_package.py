"""
Build a ready-to-send GearSwap for one character: one zip holding a whole
GearSwap folder (the addon, Mote's libraries, our shared code, the character
cloned from _master/, the Atelier page with its engine, atelier/calc/) and an INSTALLATION.txt.

The character is cloned by clone_character.py itself (with migrate_layout.py,
migrate_config.py and where_is_what.py), in a copy of _master/ made in a
temporary folder: the data folder is only read, nothing of it changes.

The Atelier's "Paquets" tab runs this same file in the page (Python compiled
to WebAssembly), so the page and the command line build the same zip.

Usage (from the data folder):
    python make_package.py <Character>
    python make_package.py <Character> --region EU --jobs WAR,DRK --alt Name --out D:/x.zip

Jobs and role default to the character's line in character_db.lua; --alt
<Name> (a main's alt) or --main <Name> (an alt's main) turns dual-boxing on.
The Atelier's exports of the character are added (add_exports, with Node), so
the page shows its jobs and sets at once; --no-exports leaves them out.

@author ejouanchicot
@date   Created: 2026-10-16
"""
import base64
import builtins
import contextlib
import importlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
CLONE_FILES = ['clone_character.py', 'migrate_layout.py', 'migrate_config.py', 'where_is_what.py', 'character_db.lua']

# What a package holds, relative to the GearSwap folder: (path, a folder taken whole?)
ADDON_FILES = ['equip_processing.lua', 'export.lua', 'flow.lua', 'gearswap.lua', 'helper_functions.lua',
               'packet_parsing.lua', 'refresh.lua', 'statics.lua', 'targets.lua', 'triggers.lua',
               'user_functions.lua', 'validate.lua', 'README.md', 'version_history.txt']
# the engine before (data/atelier/engine/, wsdist's) and its fight model (cycle.js) stay on this PC: the page no longer
# loads them (notes/docs-perso/moteur-sans-wsdist-2026-10-22/SPEC.md, Lot 5)
TREES = ['libs', 'data/shared', 'data/atelier/app', 'data/atelier/calc', 'data/atelier/lua',
         'data/scripts/atelier/AtelierLink',
         # the job templates the Atelier's "+ Add a job" makes a job from (shared/utils/atelier/job_adder.lua: entry,
         # settings, sets); never the characters' overlays (_master/<Char>/): without them the button answered
         # "No template" in every package (audit 2026-10-28 H, the player's choice)
         'data/_master/entry', 'data/_master/config', 'data/_master/sets']
DATA_FILES = ['data/atelier.html', 'data/atelier/index.html', 'data/atelier/opt.js', 'data/atelier/opt_enf.js',
              'data/atelier/targets.js', 'data/scripts/atelier/load_job.lua',
              # the gear catalogue the page reads (atelier/gear/: its build scripts and caches stay out)
              'data/atelier/gear/items.js', 'data/atelier/gear/augments_ranked.js', 'data/atelier/gear/capes.js',
              'data/atelier/gear/augments_parse.js',
              # what GearSwap loads for a job with no file: the Atelier's live link only (shared/entry/no_job_file.lua)
              'data/default.lua',
              # the version shipped and its file list: the Atelier's update starts from them (scripts/release/release.py)
              'data/VERSION', 'data/release_manifest.json']
# Never inside a package, wherever it is
SKIP_NAMES = {'__pycache__', 'nul', '.git', 'Thumbs.db', 'desktop.ini'}
SKIP_EXT = ('.pyc',)
# The Atelier's Packages page makes packages from _master/, which a package has not: it is left out. The page is
# shipped as built (atelier/src/, one file): its loader goes on past a script that is not there, and the top bar
# shows no 📦 button without packages.js (atelier/src/screens/topbar/model.ts)
PAGE_ONLY = ('data/atelier/app/js/packages.js', 'data/atelier/app/js/package_exports.js')
PAGE_INDEX = 'data/atelier/index.html'

INSTALL = """\
GearSwap de {name} - installation
================================================================

Ce dossier GearSwap contient tout : GearSwap, notre code, ton personnage
{name} ({jobs}) et l'Atelier (la page de gestion de ton equipement).

1. Ferme le jeu, ou tape //lua unload gearswap.

2. Fais une copie de securite de ton dossier :
       Windower/addons/GearSwap

3. Dans ton dossier Windower/addons/GearSwap/data, mets de cote (dans un
   autre dossier, ne les supprime pas) tes anciens fichiers de {name} :
       {name}-XXX.lua, {name}_XXX.lua, {name}-Globals.lua,
       user-globals.lua s'il y en a un.
   Important : un ancien {name}-Globals.lua serait encore charge par-dessus
   le nouveau GearSwap.

4. Copie le dossier GearSwap de ce zip dans Windower/addons/
   (accepte de remplacer les fichiers).

5. En jeu : //lua load gearswap (ou //lua reload gearswap).
   Puis //gs c checksets : la liste des pieces de tes sets introuvables.

6. Addon Windower conseille : Cancel (charge-le avec //lua load cancel).

7. L'Atelier : ouvre Windower/addons/GearSwap/data/atelier.html dans
   Chrome. En jeu, //gs c atelier lui envoie tes sets et tes sacs.

Aide en jeu : //gs c commands
"""


# ---------------------------------------------------------------------------------------------
# Lua settings files without a Lua program (the page has none for Python): migrate_config.read_lua
# ---------------------------------------------------------------------------------------------
class _LuaReader:
    """The table a plain `return { ... }` settings file holds: strings, numbers, booleans, tables."""

    def __init__(self, text):
        self.s, self.i = text, 0

    def skip(self):
        s = self.s
        while self.i < len(s):
            if s[self.i].isspace():
                self.i += 1
            elif s.startswith('--', self.i):
                m = re.match(r'--\[(=*)\[', s[self.i:])
                if m:
                    end = s.find(']' + m.group(1) + ']', self.i)
                    self.i = len(s) if end < 0 else end + len(m.group(1)) + 2
                else:
                    end = s.find('\n', self.i)
                    self.i = len(s) if end < 0 else end + 1
            else:
                break

    def value(self):
        self.skip()
        s, c = self.s, self.s[self.i]
        if c == '{':
            return self.table()
        if c in '"\'':
            return self.string()
        if s.startswith('[[', self.i) or re.match(r'\[=+\[', s[self.i:]):
            m = re.match(r'\[(=*)\[', s[self.i:])
            end = s.index(']' + m.group(1) + ']', self.i)
            text = s[self.i + len(m.group(0)):end]
            self.i = end + len(m.group(1)) + 2
            return text[1:] if text.startswith('\n') else text
        m = re.match(r'-?(0x[0-9a-fA-F]+|\d+\.?\d*(?:[eE][-+]?\d+)?|\.\d+)', s[self.i:])
        if m:
            self.i += len(m.group(0))
            n = m.group(0)
            if 'x' in n:
                return int(n, 16)
            # Lua 5.1 has one number type: 5.0 reads back as 5, as its dump writes it
            f = float(n)
            return int(f) if f == int(f) else f
        m = re.match(r'(true|false|nil)\b', s[self.i:])
        if m:
            self.i += len(m.group(0))
            return {'true': True, 'false': False, 'nil': None}[m.group(1)]
        raise ValueError('unexpected %r' % s[self.i:self.i + 20])

    def string(self):
        q, out = self.s[self.i], []
        self.i += 1
        while self.s[self.i] != q:
            c = self.s[self.i]
            if c == '\\':
                n = self.s[self.i + 1]
                out.append({'n': '\n', 't': '\t', 'r': '\r'}.get(n, n))
                self.i += 2
            else:
                out.append(c)
                self.i += 1
        self.i += 1
        return ''.join(out)

    def table(self):
        self.i += 1
        items, n = {}, 0
        while True:
            self.skip()
            if self.s[self.i] == '}':
                self.i += 1
                break
            m = re.match(r'([A-Za-z_]\w*)\s*=(?!=)', self.s[self.i:])
            if m:
                self.i += len(m.group(0))
                key = m.group(1)
            elif self.s[self.i] == '[' and not re.match(r'\[=*\[', self.s[self.i:]):
                self.i += 1
                key = self.value()
                self.skip()
                self.i += 1          # ]
                self.skip()
                self.i += 1          # =
            else:
                n += 1
                key = n
            val = self.value()
            if val is not None:
                items[key] = val
            self.skip()
            if self.s[self.i] in ',;':
                self.i += 1
        # a Lua sequence (keys 1..n, nothing else) reads as a list, as migrate_config's Lua dump writes it
        if items and all(isinstance(k, int) for k in items) and sorted(items) == list(range(1, len(items) + 1)):
            return [items[k] for k in range(1, len(items) + 1)]
        return {str(k) if isinstance(k, (int, float)) else k: v for k, v in items.items()}


def read_lua_table(path):
    """migrate_config.read_lua without lua5.1: {} when missing or not a plain table."""
    if not os.path.isfile(path):
        return {}
    with open(path, encoding='utf-8') as handle:
        text = handle.read()
    m = re.search(r'\breturn\s*\{', text)
    if not m:
        return {}
    try:
        reader = _LuaReader(text)
        reader.i = m.end() - 1
        value = reader.table()
        return value if isinstance(value, dict) else {}
    except (ValueError, IndexError):
        return {}


# ---------------------------------------------------------------------------------------------
# The clone
# ---------------------------------------------------------------------------------------------
def _fresh_modules(work):
    """clone_character and its helpers imported from the copy in `work` (their HERE is that folder)."""
    for name in ('clone_character', 'migrate_layout', 'migrate_config', 'where_is_what'):
        sys.modules.pop(name, None)
    sys.path.insert(0, work)
    try:
        clone = importlib.import_module('clone_character')
        config = importlib.import_module('migrate_config')
    finally:
        sys.path.remove(work)
    if not (shutil.which('lua5.1') or shutil.which('lua')):
        config.read_lua = read_lua_table
    return clone


@contextlib.contextmanager
def _windows_newlines():
    """Off Windows (the page's Python), text files written as Windows writes them (CRLF): the clone rewrites a few
    files in text mode, and the zip made in the page is then the one the command line makes, byte for byte."""
    if os.name == 'nt':
        yield
        return
    real = io.open

    def crlf_open(file, mode='r', buffering=-1, encoding=None, errors=None, newline=None, *rest, **kw):
        if 'b' not in mode and any(c in mode for c in 'wax+') and newline is None:
            newline = '\r\n'
        return real(file, mode, buffering, encoding, errors, newline, *rest, **kw)
    builtins.open = io.open = crlf_open
    try:
        yield
    finally:
        builtins.open = io.open = real


def clone_into(data_dir, work, name, jobs=None, role=None, partner=None, region='US'):
    """Clone `name` into work/<name> from a copy of data_dir's _master/. Returns (folder, jobs, role)."""
    shutil.copytree(os.path.join(data_dir, '_master'), os.path.join(work, '_master'))
    for f in CLONE_FILES:
        shutil.copy2(os.path.join(data_dir, f), os.path.join(work, f))
    clone = _fresh_modules(work)
    db = clone.parse_character_db(clone.Path(work) / 'character_db.lua')
    known = next((v for k, v in db.items() if k.lower() == name.lower()), None)
    jobs = [j.upper() for j in (jobs or (known or {}).get('jobs') or [])]
    if not jobs:
        raise ValueError('%s: no jobs (not in character_db.lua, and none given)' % name)
    role = role or (known or {}).get('role') or 'main'
    dualbox = {'role': role, 'character_name': name, 'enabled': bool(partner),
               'alt_character': partner if role == 'main' else None,
               'main_character': partner if role != 'main' else None}
    cloner = clone.SmartCharacterCloner(base_dir=work)
    with contextlib.redirect_stdout(io.StringIO()), _windows_newlines():
        ok = cloner.clone(name, jobs, dualbox, region)
    if not ok:
        raise RuntimeError('clone of %s failed' % name)
    return os.path.join(work, name), jobs, role


# ---------------------------------------------------------------------------------------------
# The zip
# ---------------------------------------------------------------------------------------------
def _walk(root):
    for folder, dirs, files in os.walk(root):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_NAMES)
        for f in sorted(files):
            if f not in SKIP_NAMES and not f.endswith(SKIP_EXT):
                yield os.path.join(folder, f)


def package_files(gs_dir, char_dir, name):
    """Every (source path, path in the zip) of the package, in order."""
    out = []
    for f in ADDON_FILES + DATA_FILES:
        src = os.path.join(gs_dir, f)
        if os.path.isfile(src):
            out.append((src, 'GearSwap/' + f))
    for tree in TREES:
        root = os.path.join(gs_dir, tree)
        for src in _walk(root):
            out.append((src, 'GearSwap/' + tree + '/' + os.path.relpath(src, root).replace('\\', '/')))
    for src in _walk(char_dir):
        out.append((src, 'GearSwap/data/%s/' % name + os.path.relpath(src, char_dir).replace('\\', '/')))
    return [f for f in out if f[1][len('GearSwap/'):] not in PAGE_ONLY]


def sources():
    """What build() reads, relative to the GearSwap folder: {'files': [...], 'trees': [...]}. The page copies
    these (and nothing else of the Windower folder) into its Python before it calls build()."""
    return {'files': ADDON_FILES + DATA_FILES + ['data/' + f for f in CLONE_FILES + ['make_package.py']],
            'trees': TREES + ['data/_master'], 'skip': sorted(SKIP_NAMES), 'skip_ext': list(SKIP_EXT)}


def build(name, data_dir=HERE, jobs=None, role=None, partner=None, region='US', out=None, progress=None):
    """Build the package of `name`; writes the zip to `out` (a path or a file object). Returns a summary."""
    gs_dir = os.path.dirname(os.path.abspath(data_dir))
    work = tempfile.mkdtemp(prefix='gs_package_')
    try:
        char_dir, jobs, role = clone_into(data_dir, work, name, jobs, role, partner, region)
        files = package_files(gs_dir, char_dir, name)
        with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
            z.writestr('INSTALLATION.txt', INSTALL.format(name=name, jobs=', '.join(jobs)).replace('\n', '\r\n'))
            for n, (src, arc) in enumerate(files, 1):
                z.write(src, arc)
                if progress and n % 200 == 0:
                    progress(n, len(files))
        return {'name': name, 'jobs': jobs, 'role': role, 'region': region, 'files': len(files) + 1}
    finally:
        shutil.rmtree(work, ignore_errors=True)


def add_files(out, files):
    """Add (path in the zip, text or bytes) pairs to a package already written (the Atelier's exports, their icons)."""
    with zipfile.ZipFile(out, 'a', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for arc, data in files:
            z.writestr(arc, data if isinstance(data, str) else bytes(data))


def add_exports(out, name, windower=None):
    """The Atelier's exports of `name` added to the package `out` (a path), so that the page shows the character's
    jobs and sets the first time it opens. Made by atelier/app/js/package_exports.js under Node, as the Packages
    page makes them; Windower's res/ and addons/libs/ are read from `windower` (the one above this data folder), and
    the icons of the items they name from its data/atelier/icons/ (written by the game, //gs c atelier).
    Returns {'exported': n, 'failed': [[job, sub, error]], 'icons': n}, or None without Node."""
    node = shutil.which('node')
    if not node:
        return None
    windower = windower or os.path.normpath(os.path.join(HERE, '..', '..', '..'))
    work = tempfile.mkdtemp(prefix='gs_exports_')
    try:
        with zipfile.ZipFile(out) as z:
            z.extractall(os.path.join(work, 'addons'))
        listing = os.path.join(work, 'written.json')
        run = subprocess.run([node, os.path.join(HERE, 'scripts', 'atelier', 'package_exports_cli.js'), work, windower, name, listing],
                             capture_output=True, text=True, encoding='utf-8', errors='replace')
        if run.returncode != 0 or not os.path.isfile(listing):
            raise RuntimeError('exports of %s failed: %s' % (name, (run.stderr or run.stdout).strip()[-400:]))
        with open(listing, encoding='utf-8') as handle:
            written = json.load(handle)
        arc = lambda rel: 'GearSwap/' + rel[len('addons/GearSwap/'):]
        add_files(out, [(arc(rel), text) for rel, text in written['files']]
                  + [(arc(rel), base64.b64decode(b)) for rel, b in written['icons']])
        done = json.loads(run.stdout.strip().splitlines()[-1])
        done['icons'] = len(written['icons'])
        return done
    finally:
        shutil.rmtree(work, ignore_errors=True)


def main():
    args = sys.argv[1:]
    if not args or args[0].startswith('-'):
        sys.exit(__doc__)

    def opt(flag):
        return args[args.index(flag) + 1] if flag in args and args.index(flag) + 1 < len(args) else None
    name = args[0]
    jobs = opt('--jobs').split(',') if opt('--jobs') else None
    partner, role = (opt('--alt'), 'main') if opt('--alt') else (opt('--main'), 'alt') if opt('--main') else (None, None)
    out = opt('--out') or os.path.join(os.path.expanduser('~'), 'Downloads', 'GearSwap_%s.zip' % name)
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    summary = build(name, jobs=jobs, role=role, partner=partner, region=(opt('--region') or 'US').upper(), out=out)
    print('%s: %d files, jobs %s, %s -> %s' % (name, summary['files'], ', '.join(summary['jobs']), summary['role'], out))
    if '--no-exports' not in args:
        done = add_exports(out, name)
        if done is None:
            print('No Node on this PC: the package has no Atelier exports (the page shows the jobs after //gs c atelier in game)')
        else:
            print('Atelier: %d job(s) exported, %d item icons%s' % (done['exported'], done['icons'], ''.join(
                '\n  failed %s/%s: %s' % tuple(f) for f in done['failed'])))


if __name__ == '__main__':
    main()
