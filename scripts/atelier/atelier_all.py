"""
Export every job of every character for the Atelier page, without the game.

    python scripts/atelier/atelier_all.py              every character folder
    python scripts/atelier/atelier_all.py Tetsouo      only these characters
    (or double-click "Atelier - export all jobs.bat" in the data folder)

Each <Char>/<Char>_<JOB>.lua is loaded outside the game by load_job.lua (Lua
5.1, lua5.1 or lua on the PATH), which writes <Char>/saved/atelier/<JOB>_<SUB>.js
and the item icons, as //gs c atelier does in game: one file per subjob, since
the modes, weapons and WS a job offers can depend on it. First the subjob of
the last in-game export (else of the last export, else a usual one),
then the 20 other subjobs. Such an export is kept only when it shows something
else than the main one (PLD/SCH: its own modes); the page shows the other
subjobs from the main export with their own macro book and lockstyle. An
offline export that became the same as the main one is removed, an in-game
one stays.

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


def export_folder(char):
    return os.path.join(DATA, char, 'saved', 'atelier')


def export_path(char, job, sub):
    return os.path.join(export_folder(char), '%s_%s.js' % (job, sub))


def read_export(path):
    try:
        text = open(path, encoding='utf-8').read()
        return json.loads(text[text.rindex('] = ') + 4:].rstrip().rstrip(';'))
    except (OSError, ValueError):
        return None


def write_export(path, data):
    c, j, s = json.dumps(data['player']), json.dumps(data['job']), json.dumps(data['sub'])
    body = json.dumps(data, ensure_ascii=False, separators=(',', ':'), sort_keys=True)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('window.ATELIER_SUBS = window.ATELIER_SUBS || {};\nATELIER_SUBS[%s] = ATELIER_SUBS[%s] || {};\n'
                'ATELIER_SUBS[%s][%s] = ATELIER_SUBS[%s][%s] || {};\nATELIER_SUBS[%s][%s][%s] = %s;\n'
                % (c, c, c, j, c, j, c, j, s, body))


def previous_exports(char, job):
    """Exports of this job already on the disk: one per subjob, and the <JOB>.js of before 2026-10-01."""
    folder = export_folder(char)
    found = []
    for name in os.listdir(folder) if os.path.isdir(folder) else []:
        if re.match(r'^%s(_[A-Z]+)?\.js$' % job, name):
            data = read_export(os.path.join(folder, name))
            if data:
                found.append((name, data))
    return found


def first_sub(job, previous):
    """The subjob of the last in-game export, else the one an offline run started with
    (marked main_sub), else a usual one."""
    ranked = sorted(previous, key=lambda p: (not p[1].get('offline'), bool(p[1].get('main_sub')), p[1].get('at', '')),
                    reverse=True)
    best = ranked[0][1] if ranked else {}
    if best.get('sub') and (not best.get('offline') or best.get('main_sub')):
        return best['sub']
    return USUAL_SUB.get(job, 'WAR')


def same_content(a, b):
    """Two exports of a job show the same thing: sets, keys and modes (the macro book
    and lockstyle of each subjob are in both)."""
    return all(a.get(k) == b.get(k) for k in ('sets', 'keys', 'modes'))


def item_ids():
    """Item name (lower case, short and long) -> id, equippable items first."""
    ids = {}
    pat = re.compile(r'\[(\d+)\] = \{id=\d+,en="((?:[^"\\]|\\.)*)",ja="(?:[^"\\]|\\.)*",enl="((?:[^"\\]|\\.)*)"([^\n]*)')
    for m in pat.finditer(open(RES_ITEMS, encoding='utf-8').read()):
        for name in (m.group(2).lower(), m.group(3).lower()):
            if name not in ids or 'slots=' in m.group(4):
                ids[name] = int(m.group(1))
    return ids


def run_load(lua, ffxi, char, job, sub):
    proc = subprocess.run([lua, LOADER, char, job, sub, ffxi], cwd=DATA, capture_output=True, text=True)
    error = None if proc.returncode == 0 else ((proc.stderr or proc.stdout).strip().splitlines()[-1:] or ['?'])[0]
    return char, job, sub, error


def finish(char, job, sub, bags, names_for_icons, main):
    """Mark the file offline and give it the bag items of the last in-game export (the load sees empty bags)."""
    data = read_export(export_path(char, job, sub))
    if not data:
        return None
    data['offline'] = True
    if main:
        data['main_sub'] = True
    if bags and not data.get('items'):
        data['items'] = bags
        for names in bags.values():
            names_for_icons.update(names)
    write_export(export_path(char, job, sub), data)
    return data


def add_icons(lua, ffxi, done, names):
    if not names:
        return
    ids = item_ids()
    found = {n: ids[n.lower()] for n in names if n.lower() in ids}
    for char, job, sub in done:
        data = read_export(export_path(char, job, sub))
        if data and data.get('items'):
            icons = data.setdefault('icons', {})
            for slot_names in data['items'].values():
                for n in slot_names:
                    if n in found:
                        icons.setdefault(n, found[n])
            write_export(export_path(char, job, sub), data)
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
                m = re.match(r'^([A-Z]{3})_?([A-Z]*)\.js$', name)
                if m and (char, m.group(1), m.group(2)) not in seen:
                    seen.add((char, m.group(1), m.group(2)))
                    entry = {'char': char, 'file': char + folder + name, 'job': m.group(1)}
                    if m.group(2):
                        entry['sub'] = m.group(2)
                    entries.append(entry)
    with open(os.path.join(DATA, 'atelier', 'index.js'), 'w', encoding='utf-8', newline='\n') as f:
        f.write('window.ATELIER_INDEX = %s;\n' % json.dumps(entries, separators=(',', ':')))


def run_all(lua, ffxi, tasks, bags, done, failed, names_for_icons, workers, mains=None):
    """Load and export each (character, job, subjob). Without mains, these are the main
    subjobs; with mains ({(char, job): sub}), an export showing the same as the main
    one is not kept: the page shows the main one with that subjob's macro book and
    lockstyle."""
    same = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        for char, job, sub, error in pool.map(lambda t: run_load(lua, ffxi, *t), tasks):
            if error:
                failed.append((char, job, sub))
                print('  %-12s %s/%s  FAILED  %s' % (char, job, sub, error))
                continue
            if mains is not None:
                main = read_export(export_path(char, job, mains[(char, job)]))
                mine = read_export(export_path(char, job, sub))
                if main and mine and same_content(main, mine):
                    os.remove(export_path(char, job, sub))
                    same += 1
                    continue
            finish(char, job, sub, bags.get((char, job)), names_for_icons, mains is None)
            done.append((char, job, sub))
            print('  %-12s %s/%s  ok%s' % (char, job, sub, '' if mains is None else ', its own content'))
    if mains is not None:
        print('  (%d subjobs show the same as the main one: no file of their own)' % same)


def main():
    argv = sys.argv[1:]
    ffxi = ffxi_folder(argv)
    names = [a for i, a in enumerate(argv) if not a.startswith('--') and (i == 0 or argv[i - 1] != '--ffxi')]
    lua = lua_exe()
    if not ffxi:
        print('FFXI folder not found: no item icons (use --ffxi "<FINAL FANTASY XI folder>")')
    workers = max(2, min(8, (os.cpu_count() or 4) - 1))
    jobs = [(char, job) for char in characters(names) for job in jobs_of(char)]
    # What the disk holds before anything is rewritten: the subjob to start with, the bag items
    first, bags = {}, {}
    for char, job in jobs:
        previous = previous_exports(char, job)
        first[(char, job)] = first_sub(job, previous)
        # an offline export only carries the items it was given: an in-game one first
        with_items = sorted((d for _, d in previous if d.get('items')),
                            key=lambda d: (not d.get('offline'), d.get('at', '')))
        bags[(char, job)] = with_items[-1]['items'] if with_items else None
    done, failed, names_for_icons = [], [], set()
    print('Atelier: %d jobs, the subjob of the last export first' % len(jobs))
    run_all(lua, ffxi, [(c, j, first[(c, j)]) for c, j in jobs], bags, done, failed, names_for_icons, workers)
    # Then every other subjob
    more = [(char, job, s) for char, job, sub in list(done) for s in sorted(USUAL_SUB) if s not in (job, sub)]
    print('Atelier: %d other subjobs' % len(more))
    run_all(lua, ffxi, more, bags, done, failed, names_for_icons, workers, mains=first)
    # Offline exports that are now the same as the main one go; an in-game export always stays
    exported = set(done)
    for char, job in jobs:
        legacy = os.path.join(export_folder(char), job + '.js')
        if os.path.exists(legacy):
            os.remove(legacy)
        for name, data in previous_exports(char, job):
            sub = name[len(job) + 1:-3]
            if sub and data.get('offline') and (char, job, sub) not in exported:
                os.remove(os.path.join(export_folder(char), name))
    add_icons(lua, ffxi, done, names_for_icons)
    write_index()
    print('Atelier: %d exported, %d failed' % (len(done), len(failed)))
    if '--no-open' not in argv:
        webbrowser.open('file:///' + os.path.join(DATA, 'atelier.html').replace('\\', '/'))


if __name__ == '__main__':
    main()
