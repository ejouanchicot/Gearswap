"""
Export every job of every character for the Atelier page, without the game.

    python scripts/atelier/atelier_all.py              every character folder
    python scripts/atelier/atelier_all.py Tetsouo      only these characters
    (or double-click "Atelier - export all jobs.bat" in the data folder)

Each <Char>/<Char>_<JOB>.lua is loaded outside the game by load_job.lua (Lua
5.1, lua5.1 or lua on the PATH), which writes <Char>/saved/atelier/<JOB>.js
and the item icons, as //gs c atelier does in game. The subjob is the one of
the last export, else a usual one for the job.

What only the game knows stays as the last in-game export had it: the items
in your bags (the "your items" list of a slot). Everything else comes from
the files as they are now. Then atelier.html is opened.

The item icons are read from the FFXI files: the install folder comes from
the registry (PlayOnline US / EU / JP), or --ffxi "<folder>".

@author ejouanchicot
@date   Created: 2026-10-01
"""
import concurrent.futures
import json
import os
import re
import shutil
import subprocess
import sys
import webbrowser

DATA = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LOADER = os.path.join(DATA, 'scripts', 'atelier', 'load_job.lua')
ICONS = os.path.join(DATA, 'scripts', 'atelier', 'write_icons.lua')
RES_ITEMS = os.path.normpath(os.path.join(DATA, '..', '..', '..', 'res', 'items.lua'))

# Subjob used when the job was never exported
USUAL_SUB = {'BLM': 'RDM', 'BLU': 'WAR', 'BRD': 'WHM', 'BST': 'DNC', 'COR': 'NIN', 'DNC': 'WAR',
             'DRG': 'SAM', 'DRK': 'SAM', 'GEO': 'RDM', 'MNK': 'WAR', 'NIN': 'WAR', 'PLD': 'WAR',
             'PUP': 'WAR', 'RDM': 'NIN', 'RNG': 'WAR', 'RUN': 'BLU', 'SAM': 'WAR', 'SCH': 'RDM',
             'SMN': 'WHM', 'THF': 'DNC', 'WAR': 'SAM', 'WHM': 'SCH'}


def ffxi_folder(argv):
    if '--ffxi' in argv:
        return argv[argv.index('--ffxi') + 1]
    try:
        import winreg
    except ImportError:
        return ''
    for region in ('PlayOnlineUS', 'PlayOnlineEU', 'PlayOnline'):
        for view in (winreg.KEY_WOW64_32KEY, winreg.KEY_WOW64_64KEY):
            try:
                key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r'SOFTWARE\%s\InstallFolder' % region, 0,
                                     winreg.KEY_READ | view)
                folder = winreg.QueryValueEx(key, '0001')[0]
                if os.path.isdir(os.path.join(folder, 'ROM')):
                    return folder
            except OSError:
                pass
    return ''


def lua_exe():
    for name in ('lua5.1', 'lua'):
        path = shutil.which(name)
        if path:
            return path
    sys.exit('Lua 5.1 not found (lua5.1 or lua on the PATH)')


def characters(names):
    if names:
        return names
    found = []
    for name in sorted(os.listdir(DATA)):
        folder = os.path.join(DATA, name)
        if os.path.isdir(folder) and not name.startswith(('_', '.')) and jobs_of(name):
            found.append(name)
    return found


def jobs_of(char):
    folder = os.path.join(DATA, char)
    pat = re.compile(r'^%s_([A-Z]{3})\.lua$' % re.escape(char))
    return sorted(m.group(1) for m in map(pat.match, os.listdir(folder)) if m)


def export_path(char, job):
    return os.path.join(DATA, char, 'saved', 'atelier', job + '.js')


def read_export(path):
    try:
        text = open(path, encoding='utf-8').read()
        return json.loads(text[text.rindex('] = ') + 4:].rstrip().rstrip(';'))
    except (OSError, ValueError):
        return None


def write_export(path, data):
    char, job = json.dumps(data['player']), json.dumps(data['job'])
    body = json.dumps(data, ensure_ascii=False, separators=(',', ':'), sort_keys=True)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('window.ATELIER = window.ATELIER || {};\nATELIER[%s] = ATELIER[%s] || {};\nATELIER[%s][%s] = %s;\n'
                % (char, char, char, job, body))


def item_ids():
    """Item name (lower case, short and long) -> id, equippable items first."""
    ids = {}
    pat = re.compile(r'\[(\d+)\] = \{id=\d+,en="((?:[^"\\]|\\.)*)",ja="(?:[^"\\]|\\.)*",enl="((?:[^"\\]|\\.)*)"([^\n]*)')
    for m in pat.finditer(open(RES_ITEMS, encoding='utf-8').read()):
        for name in (m.group(2).lower(), m.group(3).lower()):
            if name not in ids or 'slots=' in m.group(4):
                ids[name] = int(m.group(1))
    return ids


def run_job(lua, ffxi, char, job):
    old = read_export(export_path(char, job))
    sub = (old or {}).get('sub') or USUAL_SUB.get(job, 'WAR')
    proc = subprocess.run([lua, LOADER, char, job, sub, ffxi], cwd=DATA, capture_output=True, text=True)
    if proc.returncode != 0:
        return char, job, sub, None, (proc.stderr or proc.stdout).strip().splitlines()[-1:] or ['?']
    return char, job, sub, old, None


def keep_bag_items(char, job, old, names_for_icons):
    """The offline load sees empty bags: keep the item lists of the last in-game export."""
    new = read_export(export_path(char, job))
    if not new:
        return
    new['offline'] = True
    if old and old.get('items') and not new.get('items'):
        new['items'] = old['items']
        for names in old['items'].values():
            names_for_icons.update(names)
    write_export(export_path(char, job), new)
    return new


def add_icons(lua, ffxi, done, names):
    if not names:
        return
    ids = item_ids()
    found = {n: ids[n.lower()] for n in names if n.lower() in ids}
    for char, job in done:
        data = read_export(export_path(char, job))
        if data and data.get('items'):
            icons = data.setdefault('icons', {})
            for slot_names in data['items'].values():
                for n in slot_names:
                    if n in found:
                        icons.setdefault(n, found[n])
            write_export(export_path(char, job), data)
    subprocess.run([lua, ICONS, ffxi, os.path.join(DATA, 'atelier', 'icons') + os.sep] + [str(i) for i in set(found.values())],
                   cwd=DATA)


def write_index():
    """data/atelier/index.js, once at the end (the loads run side by side)."""
    entries, seen = [], set()
    for char in sorted(os.listdir(DATA)):
        for folder in ('/saved/atelier/', '/atelier/'):
            path = os.path.join(DATA, char + folder)
            if char.startswith(('_', '.')) or not os.path.isdir(path):
                continue
            for name in sorted(os.listdir(path)):
                m = re.match(r'^([A-Z]{3})\.js$', name)
                if m and (char, m.group(1)) not in seen:
                    seen.add((char, m.group(1)))
                    entries.append({'char': char, 'file': char + folder + name, 'job': m.group(1)})
    with open(os.path.join(DATA, 'atelier', 'index.js'), 'w', encoding='utf-8', newline='\n') as f:
        f.write('window.ATELIER_INDEX = %s;\n' % json.dumps(entries, separators=(',', ':')))


def main():
    argv = sys.argv[1:]
    ffxi = ffxi_folder(argv)
    names = [a for i, a in enumerate(argv) if not a.startswith('--') and (i == 0 or argv[i - 1] != '--ffxi')]
    lua = lua_exe()
    if not ffxi:
        print('FFXI folder not found: no item icons (use --ffxi "<FINAL FANTASY XI folder>")')
    tasks = [(char, job) for char in characters(names) for job in jobs_of(char)]
    print('Atelier: %d jobs to export' % len(tasks))
    done, failed, bag_names = [], [], set()
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        for char, job, sub, old, error in pool.map(lambda t: run_job(lua, ffxi, *t), tasks):
            if error:
                failed.append((char, job, error[0]))
                print('  %-12s %s/%s  FAILED  %s' % (char, job, sub, error[0]))
                continue
            keep_bag_items(char, job, old, bag_names)
            done.append((char, job))
            print('  %-12s %s/%s  ok' % (char, job, sub))
    add_icons(lua, ffxi, done, bag_names)
    write_index()
    print('Atelier: %d exported, %d failed' % (len(done), len(failed)))
    if '--no-open' not in argv:
        webbrowser.open('file:///' + os.path.join(DATA, 'atelier.html').replace('\\', '/'))


if __name__ == '__main__':
    main()
