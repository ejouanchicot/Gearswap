"""
Export every job of every character for the Atelier page, without the game.

    python scripts/atelier/atelier_all.py              every character folder
    python scripts/atelier/atelier_all.py Tetsouo      only these characters
    python scripts/atelier/atelier_all.py --all-subs   try the 20 other subjobs of every job again
    python scripts/atelier/atelier_all.py --force      also the jobs whose files did not change
    (or double-click "Atelier - export all jobs.bat" in the data folder, or the page's
    "Read the files again" button)

A job whose files did not change since its last export here is left as it is (its own
folder, the character's common folder and overrides, shared/, these scripts, the Porter
slips, a newer in-game export). For a job that changed: its main subjob, then the subjobs
that already had a file of their own; the 20 other subjobs are tried the first time a job
is exported and with --all-subs (a subjob shows something else only when the job's code or
config reads it, not when a set changes).

The page's button: a normal run registers the gsatelier:// link for this Windows user
(HKCU, Software / Classes / gsatelier; --unregister removes it); the page opens
gsatelier://refresh/<Character>, Windows runs this script with --url, and the page reloads
when atelier/refresh.js changes.

Each <Char>/<Char>_<JOB>.lua is loaded outside the game by load_job.lua (Lua
5.1, lua5.1 or lua on the PATH), which writes <Char>/atelier/exports/<JOB>_<SUB>.js
and the item icons, as //gs c atelier does in game: one file per subjob, since
the modes, weapons and WS a job offers can depend on it. First the subjob of
the last in-game export (else of the last export, else a usual one),
then the 20 other subjobs. Such an export is kept only when it shows something
else than the main one (PLD/SCH: its own modes); the page shows the other
subjobs from the main export with their own macro book and lockstyle. An
offline export that became the same as the main one is removed, an in-game
one stays.

What only the game knows stays as the last in-game export had it: the items
in your bags (the "your items" list of a slot). The bags are the character's,
not a job's: the newest in-game export of any of its jobs brings every other
job up to date (a piece it lists that the job can wear is added, a piece its
own job could wear and it no longer lists is taken off), without loading the
job again. Everything else comes from the files as they are now. Then
atelier.html is opened.

The item icons are read from the FFXI files: the install folder comes from
the registry (PlayOnline US / EU / JP), or --ffxi "<folder>".

@author ejouanchicot
@date   Created: 2026-10-01
"""
import concurrent.futures
import datetime
import hashlib
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
STAMP = os.path.join(DATA, 'atelier', 'refresh.js')
PROTOCOL = 'gsatelier'
# never part of what an export is made from: written by the game or by the Atelier itself
SKIP_DIRS = {'saved', 'logs', 'backups', 'exports', '__pycache__'}

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
    """<Char>/atelier/exports/ for a tidied folder (shared/utils/core/char_paths.lua; saved/atelier/ before
    2026-10-05, still read by the index), else saved/atelier/."""
    base = os.path.join(DATA, char)
    if os.path.isdir(os.path.join(base, '_common')) or os.path.isdir(os.path.join(base, 'common')):
        folder = os.path.join(base, 'atelier', 'exports')
        os.makedirs(folder, exist_ok=True)
        return folder
    return os.path.join(base, 'saved', 'atelier')


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


def item_descs(wanted):
    """The game's English description of these item ids (res/item_descriptions.lua)."""
    path = os.path.join(os.path.dirname(RES_ITEMS), 'item_descriptions.lua')
    texts = {}
    for m in re.finditer(r'\[(\d+)\] = \{id=\d+,en="((?:[^"\\]|\\.)*)"', open(path, encoding='utf-8').read()):
        if int(m.group(1)) in wanted:
            texts[int(m.group(1))] = m.group(2).replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')
    return texts


def tree_marks(folder, skip=()):
    """(relative path, size, modified) of every file under a folder."""
    marks = []
    for root, dirs, files in os.walk(folder):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and d not in skip]
        for name in files:
            path = os.path.join(root, name)
            st = os.stat(path)
            marks.append((os.path.relpath(path, folder), st.st_size, st.st_mtime_ns))
    return sorted(marks)


_COMMON_MARKS = []


def common_marks():
    """shared/ and these scripts, walked once a run."""
    if not _COMMON_MARKS:
        _COMMON_MARKS.extend(tree_marks(os.path.join(DATA, 'shared')) + tree_marks(os.path.dirname(LOADER)))
    return _COMMON_MARKS


def fingerprint(char, job, previous, main):
    """What a job's export is made from, as one value: the character's folder without the
    other jobs', shared/, these scripts, the Porter slips and the newest in-game export."""
    other_jobs = {j.lower() for j in USUAL_SUB if j != job}
    other_entry = re.compile(r'^%s_(?!%s\.)[A-Z]{3}\.lua$' % (re.escape(char), job))
    marks = [m for m in tree_marks(os.path.join(DATA, char), skip=other_jobs) if not other_entry.match(m[0])]
    slips = os.path.join(DATA, char, 'saved', 'slip_items.lua')
    slip = hashlib.sha1(open(slips, 'rb').read()).hexdigest() if os.path.exists(slips) else ''
    # the main subjob's own in-game export aside: this run writes over it (counted, the job was redone once more)
    in_game = max((d.get('at', '') for _, d in previous if not d.get('offline') and d.get('sub') != main), default='')
    return hashlib.sha1(repr((marks, common_marks(), slip, in_game)).encode('utf-8')).hexdigest()


def register(remove=False):
    """The gsatelier:// link of the page's button, for this Windows user. True when written."""
    try:
        import winreg
    except ImportError:
        return False
    base = r'Software\Classes\%s' % PROTOCOL
    command = '"%s" "%s" --url "%%1"' % (sys.executable, os.path.abspath(__file__))
    if remove:
        for key in (base + r'\shell\open\command', base + r'\shell\open', base + r'\shell', base):
            try:
                winreg.DeleteKey(winreg.HKEY_CURRENT_USER, key)
            except OSError:
                pass
        return True
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, base + r'\shell\open\command') as key:
            if winreg.QueryValueEx(key, None)[0] == command:
                return False
    except OSError:
        pass
    with winreg.CreateKey(winreg.HKEY_CURRENT_USER, base) as key:
        winreg.SetValueEx(key, None, 0, winreg.REG_SZ, 'URL:GearSwap Atelier')
        winreg.SetValueEx(key, 'URL Protocol', 0, winreg.REG_SZ, '')
    with winreg.CreateKey(winreg.HKEY_CURRENT_USER, base + r'\shell\open\command') as key:
        winreg.SetValueEx(key, None, 0, winreg.REG_SZ, command)
    return True


def url_names(url):
    """The character a gsatelier://refresh/<Character> link names: only a folder that exists
    here (the link can come from any page), else every character."""
    name = url.split('://', 1)[-1].strip('/').split('/')[-1]
    return [name] if re.fullmatch(r'[A-Za-z]+', name) and name in characters([]) else []


def write_stamp(exported, failed, unchanged):
    """atelier/refresh.js: the page that asked for this run reloads when it changes."""
    stamp = {'at': datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 'exported': exported, 'failed': failed,
             'unchanged': unchanged}
    with open(STAMP, 'w', encoding='utf-8', newline='\n') as f:
        f.write('window.ATELIER_REFRESH = %s;\n' % json.dumps(stamp))


JOB_IDS = {job: i + 1 for i, job in enumerate(
    'WAR MNK WHM BLM RDM THF PLD DRK BST BRD RNG SAM NIN DRG SMN BLU COR PUP DNC SCH GEO RUN'.split())}
_ITEM_JOBS = {}


def wears(job, key):
    """Whether a job can wear an item (id, or name): True, False, or None when the item is unknown."""
    if not _ITEM_JOBS:
        pat = re.compile(r'\[(\d+)\] = \{id=\d+,en="((?:[^"\\]|\\.)*)"[^\n]*?[,{]jobs=(\d+)')
        for m in pat.finditer(open(RES_ITEMS, encoding='utf-8').read()):
            _ITEM_JOBS[int(m.group(1))] = int(m.group(3))
            _ITEM_JOBS.setdefault(m.group(2).lower(), int(m.group(3)))
    mask = _ITEM_JOBS.get(key.lower() if isinstance(key, str) else key)
    return None if mask is None else (mask >> JOB_IDS[job]) & 1 == 1


def merge_lists(mine, newer, key, wear_here, wear_there, keep):
    """One slot's list brought up to date from a newer one made on another job: what the newer
    job could wear and no longer lists goes, what it lists and this job can wear comes."""
    there = {key(x): x for x in newer}
    out = [there.get(key(x), x) for x in mine if key(x) in there or keep(x) or wear_there(x) is not True]
    have = {key(x) for x in out}
    return out + [x for x in newer if key(x) not in have and wear_here(x) is True]


def merge_bags(mine, job, newer, newer_job):
    """The bags a job's export carries ({items, owned}), brought up to date from a newer
    in-game export of another job of the same character. A Porter slip's piece stays."""
    copy = lambda c: (c.get('name'), tuple(c.get('augs') or []))
    ident = lambda c: c.get('id') or c.get('name') or ''
    slip = lambda c: bool(c.get('where')) and all(w.startswith('Slip ') for w in c['where'])
    out = {'items': {}, 'owned': {}}
    for slot in sorted(set(mine.get('items') or {}) | set(newer.get('items') or {})):
        names = merge_lists((mine.get('items') or {}).get(slot, []), (newer.get('items') or {}).get(slot, []), lambda n: n,
                            lambda n: wears(job, n), lambda n: wears(newer_job, n), lambda n: False)
        if names:
            out['items'][slot] = names
    for slot in sorted(set(mine.get('owned') or {}) | set(newer.get('owned') or {})):
        copies = merge_lists((mine.get('owned') or {}).get(slot, []), (newer.get('owned') or {}).get(slot, []), copy,
                             lambda c: wears(job, ident(c)), lambda c: wears(newer_job, ident(c)), slip)
        if copies:
            out['owned'][slot] = sorted(copies, key=lambda c: c.get('name') or '')
    return out


def bags_time(data):
    """When the game last read the bags an export lists: its own time for an in-game export,
    the time of the in-game export it was given them from (bags_at) for one made here."""
    return (data.get('bags_at') or '') if data.get('offline') else data.get('at', '')


def newest_bags(char, jobs):
    """(job, export) of the character's export whose bags the game read last, or None."""
    found = [(bags_time(d), job, d) for job in jobs for _, d in previous_exports(char, job) if d.get('owned')]
    found = [f for f in found if f[0]]
    return max(found, key=lambda f: f[0])[1:] if found else None


def with_slips(owned, data):
    """The bags' copies plus the Porter slips' pieces an export outside the game holds
    (its own bags are empty, the slips come from <Char>/saved/slip_items.lua)."""
    out = {slot: list(copies) for slot, copies in owned.items()}
    for slot, copies in (data.get('owned') or {}).items():
        mine = out.setdefault(slot, [])
        for c in copies:
            if c.get('where') and all(w.startswith('Slip ') for w in c['where']) and not any(
                    m.get('name') == c.get('name') and (m.get('augs') or []) == (c.get('augs') or []) for m in mine):
                mine.append(c)
    return out


def refresh_bags(char, job, sub, carry, names_for_icons):
    """An export left as it is (its files did not change) still follows the bags. True when rewritten."""
    data = read_export(export_path(char, job, sub))
    if not (data and data.get('offline') and (carry or {}).get('owned')):
        return False
    owned = with_slips(carry['owned'], data)
    if owned == data.get('owned') and carry.get('items') == data.get('items'):
        return False
    data['owned'], data['items'] = owned, carry.get('items') or data.get('items')
    data['bags_at'] = carry.get('bags_at')
    for names in (data['items'] or {}).values():
        names_for_icons.update(names)
    write_export(export_path(char, job, sub), data)
    return True


def run_load(lua, ffxi, char, job, sub):
    proc = subprocess.run([lua, LOADER, char, job, sub, ffxi], cwd=DATA, capture_output=True, text=True)
    error = None if proc.returncode == 0 else ((proc.stderr or proc.stdout).strip().splitlines()[-1:] or ['?'])[0]
    return char, job, sub, error


def finish(char, job, sub, carry, names_for_icons, main):
    """Mark the file offline and give it what only the game sees, from the last in-game
    export: the bag items (each copy with its augments), and the character's measured
    stats (same subjob first)."""
    data = read_export(export_path(char, job, sub))
    if not data:
        return None
    data['offline'] = True
    if main:
        data['main_sub'] = True
        data['src'] = (carry or {}).get('src')
    bags, measured = (carry or {}).get('items'), (carry or {}).get('chars') or {}
    if bags and not data.get('items'):
        data['items'] = bags
        for names in bags.values():
            names_for_icons.update(names)
    # each copy of the bags with its own augments (the page's piece swap); the export outside the game holds
    # only the Porter Moogle's pieces (its bags are empty, the slips come from <Char>/saved/slip_items.lua):
    # they join the bags' copies of the last in-game export
    if (carry or {}).get('owned'):
        data['owned'] = with_slips(carry['owned'], data)
        data['bags_at'] = carry.get('bags_at')
    if not data.get('char') and measured:
        data['char'] = measured.get(sub) or sorted(measured.values(), key=lambda c: c.get('at', ''))[-1]
    write_export(export_path(char, job, sub), data)
    return data


def add_icons(lua, ffxi, done, names):
    # an icon left empty by a run stopped half way is written again
    icons_dir = os.path.join(DATA, 'atelier', 'icons')
    for entry in os.scandir(icons_dir) if os.path.isdir(icons_dir) else []:
        if entry.name.endswith(('.bmp', '.tmp')) and entry.stat().st_size == 0:
            os.remove(entry.path)
    if not names:
        return
    ids = item_ids()
    found = {n: ids[n.lower()] for n in names if n.lower() in ids}
    texts = item_descs(set(found.values()))
    for char, job, sub in done:
        data = read_export(export_path(char, job, sub))
        if data and data.get('items'):
            # an export with none wrote them as an empty list (Lua's empty table)
            for key in ('icons', 'descs'):
                if not isinstance(data.get(key), dict):
                    data[key] = {}
            icons, descs = data['icons'], data['descs']
            for slot_names in data['items'].values():
                for n in slot_names:
                    if n in found:
                        icons.setdefault(n, found[n])
                        if found[n] in texts:
                            descs.setdefault(str(found[n]), texts[found[n]])
            write_export(export_path(char, job, sub), data)
    subprocess.run([lua, ICONS, ffxi, os.path.join(DATA, 'atelier', 'icons') + os.sep] + [str(i) for i in set(found.values())],
                   cwd=DATA)


def write_index():
    """data/atelier/index.js, once at the end (the loads run side by side)."""
    entries, seen = [], set()
    for char in sorted(os.listdir(DATA)):
        for folder in ('/atelier/exports/', '/saved/atelier/', '/atelier/'):
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
    # the live link files that exist (live_<Char>.js, link_<Char>.js): the page loads only those
    live = sorted('atelier/' + n for n in os.listdir(os.path.join(DATA, 'atelier'))
                  if re.match(r'^(live|link)_.+\.js$', n))
    # the spell families come from the game (shared/utils/atelier/atelier_families.lua): kept as they were
    index = os.path.join(DATA, 'atelier', 'index.js')
    families = ''
    if os.path.exists(index):
        m = re.search(r'^window\.ATELIER_FAMILIES = .*;$', open(index, encoding='utf-8').read(), re.M)
        families = m.group(0) + '\n' if m else ''
    with open(index, 'w', encoding='utf-8', newline='\n') as f:
        f.write('window.ATELIER_INDEX = %s;\nwindow.ATELIER_LIVE_FILES = %s;\n%s'
                % (json.dumps(entries, separators=(',', ':')), json.dumps(live, separators=(',', ':')), families))


def group_twins(char, job, main_sub, done, known=None):
    """Subjobs kept because they differ from the main one may still be alike (PLD: main /SCH
    has its own stances, the 19 others are all the same): one file per content, the others
    removed and named in the main file's same_as ({sub: the sub whose file it shows}).
    `known`: the same_as of the export before, when the other subjobs were not tried again;
    a subjob it names still shows the file it named, while that file is there."""
    groups, same_as = [], {}
    for name, data in sorted(previous_exports(char, job)):
        sub = name[len(job) + 1:-3]
        if not sub or sub == main_sub:
            continue
        for keep_sub, keep in groups:
            if same_content(keep, data):
                if data.get('offline'):
                    os.remove(export_path(char, job, sub))
                    same_as[sub] = keep_sub
                    if (char, job, sub) in done:
                        done.remove((char, job, sub))
                break
        else:
            groups.append((sub, data))
    kept = {keep_sub for keep_sub, _ in groups}
    for sub, keep_sub in (known or {}).items():
        if sub not in same_as and keep_sub in kept and not os.path.exists(export_path(char, job, sub)):
            same_as[sub] = keep_sub
    main = read_export(export_path(char, job, main_sub))
    if main is not None:
        main['same_as'] = same_as
        write_export(export_path(char, job, main_sub), main)


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
    if '--unregister' in argv:
        register(remove=True)
        return print('Atelier: the page button link is removed')
    by_page = '--url' in argv
    ffxi = ffxi_folder(argv)
    names = [a for i, a in enumerate(argv) if not a.startswith('--') and (i == 0 or argv[i - 1] not in ('--ffxi', '--url'))]
    if by_page:
        names = url_names(argv[argv.index('--url') + 1])
    elif register():
        print('Atelier: the page\'s "Read the files again" button is on for this Windows user')
    all_subs, force = '--all-subs' in argv, '--force' in argv
    lua = lua_exe()
    if not ffxi:
        print('FFXI folder not found: no item icons (use --ffxi "<FINAL FANTASY XI folder>")')
    workers = max(2, min(8, (os.cpu_count() or 4) - 1))
    jobs = [(char, job) for char in characters(names) for job in jobs_of(char)]
    # What the disk holds before anything is rewritten: the subjob to start with, the bag items
    first, bags, own, known, unchanged, newest, files = {}, {}, {}, {}, set(), {}, {}
    for char, job in jobs:
        previous = previous_exports(char, job)
        first[(char, job)] = first_sub(job, previous)
        src = fingerprint(char, job, previous, first[(char, job)])
        before = next((d for _, d in previous if d.get('main_sub') and d.get('sub') == first[(char, job)]), {})
        if not force and before.get('src') == src:
            unchanged.add((char, job))
        # the subjobs that had a file of their own; None: every other subjob (first export, --all-subs)
        mine = {name[len(job) + 1:-3] for name, _ in previous} - {'', first[(char, job)]}
        # (also when the main export is not one made here: never exported, or the game wrote over it, and which
        # subjobs show the same as which, same_as, went with it)
        own[(char, job)] = None if all_subs or not before.get('main_sub') else sorted(mine)
        known[(char, job)] = None if own[(char, job)] is None else before.get('same_as')
        # an offline export only carries the items it was given: an in-game one first
        with_items = sorted((d for _, d in previous if d.get('items')),
                            key=lambda d: (not d.get('offline'), d.get('at', '')))
        # the stats measured in game, by the subjob they were measured on
        chars = {}
        for _, d in sorted(previous, key=lambda p: p[1].get('at', '')):
            if d.get('char'):
                chars[d['char'].get('sub') or d.get('sub')] = d['char']
        last = with_items[-1] if with_items else {}
        carry = {'items': last.get('items'), 'owned': last.get('owned'), 'bags_at': bags_time(last)}
        # the bags are the character's: the export of another of its jobs whose bags the game read later
        # brings these up to date
        if char not in newest:
            newest[char] = newest_bags(char, jobs_of(char))
        if newest[char] and newest[char][0] != job and carry['bags_at'] < bags_time(newest[char][1]):
            carry = dict(merge_bags(carry, job, newest[char][1], newest[char][0]), bags_at=bags_time(newest[char][1]))
        bags[(char, job)] = dict(carry, chars=chars, src=src)
        files[(char, job)] = [name[len(job) + 1:-3] for name, _ in previous if len(name) > len(job) + 3]
    done, failed, names_for_icons = [], [], set()
    if unchanged:
        print('Atelier: %d jobs unchanged since their last export, left as they are (--force to redo them)' % len(unchanged))
    # those still follow the bags (a newer in-game export of another job of the character)
    patched = [(c, j, s) for c, j in sorted(unchanged) for s in files[(c, j)] if refresh_bags(c, j, s, bags[(c, j)], names_for_icons)]
    if patched:
        print('Atelier: %d of their files brought up to date with the bags' % len(patched))
    jobs = [j for j in jobs if j not in unchanged]
    print('Atelier: %d jobs, the subjob of the last export first' % len(jobs))
    run_all(lua, ffxi, [(c, j, first[(c, j)]) for c, j in jobs], bags, done, failed, names_for_icons, workers)
    # Then the subjobs that had their own file, or every other subjob
    more = [(char, job, s) for char, job, sub in list(done)
            for s in (sorted(USUAL_SUB) if own[(char, job)] is None else own[(char, job)]) if s not in (job, sub)]
    print('Atelier: %d other subjobs' % len(more))
    run_all(lua, ffxi, more, bags, done, failed, names_for_icons, workers, mains=first)
    for char, job in jobs:
        group_twins(char, job, first[(char, job)], done, known[(char, job)])
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
    add_icons(lua, ffxi, done + patched, names_for_icons)
    write_index()
    print('Atelier: %d exported, %d failed' % (len(done), len(failed)))
    write_stamp(len(done), len(failed), len(unchanged))
    if '--no-open' not in argv and not by_page:
        webbrowser.open('file:///' + os.path.join(DATA, 'atelier.html').replace('\\', '/'))


if __name__ == '__main__':
    main()
