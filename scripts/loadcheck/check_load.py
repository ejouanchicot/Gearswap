"""Load Check - every job of every character loaded outside the game, with proof.

What it does, on a COPY of the game folder (the real files are never written):
  1. sweep   : each character x each job x each subjob is loaded by harness.lua
               (entry file, get_sets, the work scheduled in the first 10 s).
  2. probes  : load errors, errors a few seconds later, Lua's shared tables changed,
               Windower libraries loaded inside the sandbox, functions left hooked
               on windower.* (they keep the old load alive after a reload: a leak),
               files loaded twice, time, memory, commands sent.
  3. inject  : every character file read at load is broken four ways, one at a time
               (syntax error, runtime error, empty file, wrong value), and the load
               is replayed: does GearSwap still load, and does the player learn
               which file is broken?
  4. compare : sets, states and globals of every load are kept (out/fp/); the next
               run lists the loads whose result changed (proof a refactor changed nothing).

usage (from anywhere):
  python scripts/loadcheck/check_load.py                  everything, all characters
  python scripts/loadcheck/check_load.py --quick          2 subjobs per job instead of all
  python scripts/loadcheck/check_load.py Tetsouo Kaories  only these characters
  python scripts/loadcheck/check_load.py --inject Tetsouo:WAR:SAM --inject Kaories:GEO:WHM
  python scripts/loadcheck/check_load.py --no-inject
Report: scripts/loadcheck/out/report.md (and summary.json). Exit code 1 if a load fails or leaks.

@file scripts/loadcheck/check_load.py
@author ejouanchicot
@version 1.0
@date Created: 2026-10-17
"""
import argparse
import collections
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.normpath(os.path.join(HERE, '..', '..'))
GS = os.path.dirname(DATA)
WINDOWER = os.path.dirname(os.path.dirname(GS))
OUT = os.path.join(HERE, 'out')
HARNESS = os.path.join(HERE, 'harness.lua')
JOBS = ['BLM', 'BLU', 'BRD', 'BST', 'COR', 'DNC', 'DRG', 'DRK', 'GEO', 'MNK', 'NIN', 'PLD', 'PUP', 'RDM', 'RNG',
        'RUN', 'SAM', 'SCH', 'SMN', 'THF', 'WAR', 'WHM']
QUICK_SUBS = ['WAR', 'NIN', 'DNC', 'SCH', 'RDM', 'WHM']
DEFAULT_INJECT = ['Tetsouo:WAR:SAM', 'Kaories:GEO:WHM']
BREAKS = {
    'syntax': 'return {\n',
    'runtime': "error('LOADCHECK INJECTED')\n",
    'empty': '',
    'number': 'return 42\n',
}
# Tags that fail the run: a load that breaks, or a load that leaks into the next one.
FATAL = ['ENTRY LOAD ERROR', 'GET_SETS ERROR', 'SCHED_ERROR', 'TIMEOUT', 'CRASH', 'SHARED_ADDED',
         'SHARED_CHANGED', 'SHARED_REMOVED', 'WINDOWER_LIB_IN_SANDBOX', 'PINS_SANDBOX']


def find_lua():
    for name in ('lua5.1', 'lua5.1.exe'):
        p = shutil.which(name)
        if p:
            return p
    for p in (r'C:\ProgramData\chocolatey\bin\lua5.1.exe',
              r'C:\ProgramData\chocolatey\lib\luarocks\luarocks-2.4.4-win32\lua5.1.exe'):
        if os.path.exists(p):
            return p
    sys.exit('lua5.1 not found (GearSwap runs Lua 5.1: install it, e.g. choco install lua51)')


def characters():
    out = []
    for d in sorted(os.listdir(DATA)):
        full = os.path.join(DATA, d)
        if os.path.isdir(full) and not d.startswith(('_', '.')) and any(
                os.path.exists(os.path.join(full, '%s_%s.lua' % (d, j))) for j in JOBS):
            out.append(d)
    return out


def copy_tree(src, dst, skip=()):
    def ignore(folder, names):
        rel = os.path.relpath(folder, src).replace('\\', '/')
        # 'nul' & co: Windows device names, a stray one sits in GearSwap/libs and cannot be copied
        return [n for n in names if (rel + '/' + n).lstrip('./') in skip or n in ('.git', '__pycache__')
                or n.split('.')[0].lower() in ('nul', 'con', 'prn', 'aux')]
    if os.path.isdir(src):
        shutil.copytree(src, dst, ignore=ignore, dirs_exist_ok=True)


def make_lab(chars):
    """Copy what a load reads (code, characters, res/, libs) into a fresh folder."""
    lab = tempfile.mkdtemp(prefix='gs_loadcheck_')
    gs_lab = os.path.join(lab, 'addons', 'GearSwap')
    copy_tree(os.path.join(WINDOWER, 'res'), os.path.join(lab, 'res'))
    copy_tree(os.path.join(WINDOWER, 'addons', 'libs'), os.path.join(lab, 'addons', 'libs'))
    for d in ('libs', 'libs-dev'):
        copy_tree(os.path.join(GS, d), os.path.join(gs_lab, d))
    for d in ['shared', '_master'] + chars:
        copy_tree(os.path.join(DATA, d), os.path.join(gs_lab, 'data', d),
                  skip=('logs', 'atelier/exports', 'atelier/backups'))
    for f in os.listdir(DATA):
        if f.endswith('.lua'):
            shutil.copy2(os.path.join(DATA, f), os.path.join(gs_lab, 'data', f))
    for c in chars:
        copy_tree(os.path.join(WINDOWER, 'addons', 'PorterPacker', 'data', c),
                  os.path.join(lab, 'addons', 'PorterPacker', 'data', c))
    # A freshly copied file is scanned by the antivirus on its first open: read them all once,
    # or the first loads of each job measure Windows instead of GearSwap (600 ms vs 90 ms).
    for folder, _, names in os.walk(lab):
        for n in names:
            if n.endswith('.lua'):
                with open(os.path.join(folder, n), 'rb') as f:
                    f.read()
    return lab


def run_load(lua, lab, char, main, sub, workdir):
    os.makedirs(workdir, exist_ok=True)
    try:
        p = subprocess.run([lua, HARNESS, char, main, sub, lab], cwd=workdir, capture_output=True,
                           text=True, errors='replace', timeout=300)
        out = p.stdout + p.stderr
        if p.returncode != 0:
            out += '\nCRASH harness exit %d' % p.returncode
        return out
    except subprocess.TimeoutExpired:
        return 'TIMEOUT'


def clean(msg, lab):
    msg = msg.replace('\\', '/').replace(lab.replace('\\', '/') + '/', '')
    return re.sub(r'\.\.\.[^ ]*?/(addons/GearSwap/)?data/', 'data/', msg)


def parse(out, lab):
    r = collections.defaultdict(list)
    m = re.search(r'file=(\d+)ms\s+get_sets=(\d+)ms\s+scheduled\(<=10s, (\d+) runs\)=(\d+)ms', out)
    if m:
        r['ms_file'], r['ms_get_sets'], r['ms_sched'] = int(m.group(1)), int(m.group(2)), int(m.group(4))
    m = re.search(r'files=(\d+)\s+loads=(\d+)\s+bytes read=([\d.]+) KB.*send_command=(\d+)\s+events=(\d+)', out)
    if m:
        r['files'], r['loads'], r['kb_read'] = int(m.group(1)), int(m.group(2)), float(m.group(3))
        r['sends'], r['events'] = int(m.group(4)), int(m.group(5))
    m = re.search(r'MEMORY (-?\d+) KB kept after load\+scheduled, (\d+) globals', out)
    if m:
        r['kb_kept'], r['globals'] = int(m.group(1)), int(m.group(2))
    dup = re.search(r'-- loaded more than once --\n(.*?)\n\n', out, re.S)
    if dup:
        for line in dup.group(1).splitlines():
            m = re.match(r'x(\d+)\s+pre=\d+\s+post=\d+\s+[\d.]+ms\s+(\S+)', line)
            if m:
                r['DUPLICATE'].append(m.group(2))
    for line in out.splitlines():
        for tag in FATAL + ['PCALL_FAIL', 'CHAT', 'CHARREAD']:
            if line.startswith(tag):
                r[tag].append(clean(line[len(tag):].strip(), lab))
    if 'lua5.1' in out and 'CRASH' not in r:
        tail = [l for l in out.splitlines() if 'lua5.1' in l]
        if tail:
            r['CRASH'].append(clean(tail[0], lab))
    return r


# ---------------------------------------------------------------- sweep

def sweep(lua, lab, chars, quick):
    combos = []
    for c in chars:
        for j in JOBS:
            if os.path.exists(os.path.join(lab, 'addons', 'GearSwap', 'data', c, '%s_%s.lua' % (c, j))):
                subs = [s for s in (QUICK_SUBS if quick else JOBS) if s != j]
                combos += [(c, j, s) for s in (subs[:2] if quick else subs)]
    work = os.path.join(lab, 'work')

    def one(cb):
        wd = os.path.join(work, '_'.join(cb))
        out = run_load(lua, lab, cb[0], cb[1], cb[2], wd)
        fp = os.path.join(wd, 'fp_%s_%s.txt' % (cb[0], cb[1]))
        return cb, parse(out, lab), (open(fp, encoding='utf-8', errors='replace').read() if os.path.exists(fp) else '')

    results = {}
    t0 = time.time()
    with ThreadPoolExecutor(max(2, (os.cpu_count() or 4) - 1)) as ex:
        for n, (cb, r, fp) in enumerate(ex.map(one, combos), 1):
            results['%s %s/%s' % cb] = (r, fp)
            if n % 100 == 0:
                print('  %d / %d loads (%.0f s)' % (n, len(combos), time.time() - t0), flush=True)
    return results


# ---------------------------------------------------------------- inject

def char_files(r, char, lab):
    files = set()
    for line in r.get('CHARREAD', []):
        how, path = (line.split(' ', 1) + [''])[:2]
        if how == 'WRITE' or not path.lower().endswith('.lua'):
            continue
        m = re.search(r'(data/.+)$', path)
        if not m:
            continue
        rel = re.sub(r'^data/%s/\.\./' % re.escape(char), 'data/', m.group(1), flags=re.I)
        if '/shared/' in rel or ('/' + char.lower() + '/') not in ('/' + rel.lower()):
            continue
        full = os.path.normpath(os.path.join(lab, 'addons', 'GearSwap', rel))
        if os.path.exists(full):
            files.add(full)
    return sorted(files)


def verdict(r, rel):
    """How a broken file showed: FAILS_* stops GearSwap, OK_* loads; *_CLEAR / *_WARNED names the file."""
    name = os.path.basename(rel).lower()
    errors = r.get('ENTRY LOAD ERROR', []) + r.get('GET_SETS ERROR', []) + r.get('CRASH', []) + r.get('TIMEOUT', [])
    named = any(name in m.lower() for m in r.get('CHAT', []))
    if errors:
        return ('FAILS_CLEAR' if named or name in errors[0].lower() else 'FAILS_UNCLEAR'), errors[0]
    if r.get('SCHED_ERROR'):
        return 'LATER_ERROR', r['SCHED_ERROR'][0]
    chat = next((m for m in r.get('CHAT', []) if name in m.lower()), '')
    return ('OK_WARNED', chat) if named else ('OK_SILENT', '')


def inject(lua, lab, spec):
    char, main, sub = spec.split(':')
    wd = os.path.join(lab, 'work_inject')
    base = parse(run_load(lua, lab, char, main, sub, wd), lab)
    gs_lab = os.path.join(lab, 'addons', 'GearSwap')
    rows = []
    for full in char_files(base, char, lab):
        original = open(full, 'rb').read()
        rel = os.path.relpath(full, gs_lab).replace('\\', '/')
        try:
            for kind, text in BREAKS.items():
                with open(full, 'w', newline='') as f:
                    f.write(text)
                v, why = verdict(parse(run_load(lua, lab, char, main, sub, wd), lab), rel)
                rows.append({'file': rel, 'break': kind, 'verdict': v, 'why': why[:220]})
        finally:
            with open(full, 'wb') as f:
                f.write(original)
    return rows


# ---------------------------------------------------------------- report

def summarize(results):
    agg = collections.defaultdict(collections.Counter)
    where = collections.defaultdict(set)
    nums = collections.defaultdict(list)
    for key, (r, _) in results.items():
        for tag in FATAL + ['DUPLICATE']:
            for msg in r.get(tag, []):
                agg[tag][msg[:240]] += 1
                where[(tag, msg[:240])].add(key)
        for msg in r.get('PCALL_FAIL', []):
            msg = re.sub(r'^\d+x ', '', msg)
            m = re.search(r'Cannot find the include file \((.*?)\)', msg)
            if m:
                agg['MISSING_OPTIONAL'][re.sub(r'^(shared/data/job_abilities/)\w+/\w+?_', r'\1<job>/<job>_', m.group(1))] += 1
            elif 'cannot open' not in msg:
                agg['PCALL_OTHER'][msg[:240]] += 1
        for f in ('files', 'loads', 'kb_read', 'kb_kept', 'globals', 'ms_file', 'ms_get_sets', 'ms_sched', 'sends', 'events'):
            if f in r:
                nums[f].append((r[f], key))
    return agg, where, nums


def fingerprint_changes(results):
    fp_dir = os.path.join(OUT, 'fp')
    changed, new = [], 0
    for key, (_, fp) in results.items():
        path = os.path.join(fp_dir, re.sub(r'[ /]', '_', key) + '.txt')
        if os.path.exists(path):
            old = open(path, encoding='utf-8', errors='replace').read()
            if old != fp:
                changed.append(key)
        else:
            new += 1
    # only the loads of this run are replaced: a --quick run keeps the full run's other results
    os.makedirs(fp_dir, exist_ok=True)
    for key, (_, fp) in results.items():
        with open(os.path.join(fp_dir, re.sub(r'[ /]', '_', key) + '.txt'), 'w', encoding='utf-8') as f:
            f.write(fp)
    return changed, new


def write_report(results, injected, changed, new_fp, seconds):
    agg, where, nums = summarize(results)
    previous = {}
    prev_path = os.path.join(OUT, 'summary.json')
    if os.path.exists(prev_path):
        previous = json.load(open(prev_path, encoding='utf-8'))
    fatal = sum(sum(agg[t].values()) for t in FATAL)
    L = ['# Load Check', '', '%s, %d loads in %.0f s. **%s**' % (
        time.strftime('%Y-%m-%d %H:%M'), len(results), seconds,
        'Nothing breaks, nothing leaks.' if fatal == 0 else '%d problems (see below).' % fatal), '']
    L += ['## Problems (fail the run)', '']
    for tag in FATAL:
        c = agg[tag]
        L.append('- **%s**: %d' % (tag, sum(c.values())))
        for msg, n in c.most_common(15):
            keys = sorted(where[(tag, msg)])
            L.append('  - %d x `%s`  (%s%s)' % (n, msg, ', '.join(keys[:4]), ', ...' if len(keys) > 4 else ''))
    old_fatal = set(previous.get('fatal_messages', []))
    now_fatal = sorted({'%s %s' % (t, m) for t in FATAL for m in agg[t]})
    fresh = [m for m in now_fatal if m not in old_fatal]
    gone = [m for m in old_fatal if m not in now_fatal]
    if previous:
        L += ['', '## Since the last run (%s)' % previous.get('at', '?'), '',
              '- new problems: %d' % len(fresh)] + ['  - `%s`' % m for m in fresh[:20]]
        L += ['- problems gone: %d' % len(gone)] + ['  - `%s`' % m for m in gone[:20]]
    L += ['- loads whose sets/states/commands/globals changed: %d%s' % (
        len(changed), (' (' + ', '.join(changed[:10]) + (', ...' if len(changed) > 10 else '') + ')') if changed else ''),
          '- loads with no earlier result to compare: %d' % new_fp]
    L += ['', '## Cost of a load (offline, same PC for all)', '', '| measure | min | median | max |', '|---|---|---|---|']
    labels = {'ms_file': 'entry file (ms)', 'ms_get_sets': 'get_sets (ms)', 'ms_sched': 'work in the first 10 s (ms)',
              'files': 'files read', 'loads': 'file loads', 'kb_read': 'KB read', 'kb_kept': 'memory kept (KB)',
              'globals': 'globals', 'sends': 'commands sent', 'events': 'events registered'}
    for f, label in labels.items():
        v = sorted(nums[f])
        if v:
            L.append('| %s | %s | %s | %s (%s) |' % (label, v[0][0], v[len(v) // 2][0], v[-1][0], v[-1][1]))
    L += ['', '## Loaded twice in the same load', '']
    L += ['- %d loads: `%s`' % (n, m) for m, n in agg['DUPLICATE'].most_common(10)] or ['- none']
    L += ['', '## Optional files looked for and absent (normal, but each costs a disk lookup)', '']
    L += ['- %d x `%s`' % (n, m) for m, n in agg['MISSING_OPTIONAL'].most_common(12)]
    if agg['PCALL_OTHER']:
        L += ['', '## Other errors caught by a pcall (the load went on)', '']
        L += ['- %d x `%s`' % (n, m) for m, n in agg['PCALL_OTHER'].most_common(20)]
    bad_inject = 0
    for spec, rows in injected.items():
        count = collections.Counter(r['verdict'] for r in rows)
        files = sorted({r['file'] for r in rows})
        L += ['', '## Broken files: %s (%d files x %d breaks)' % (spec, len(files), len(BREAKS)), '',
              ' | '.join('%s %d' % (k, count[k]) for k in ('OK_WARNED', 'OK_SILENT', 'FAILS_CLEAR', 'FAILS_UNCLEAR', 'LATER_ERROR')),
              '', '| file | ' + ' | '.join(BREAKS) + ' |', '|---|' + '---|' * len(BREAKS)]
        for f in files:
            cells = [next((r['verdict'] for r in rows if r['file'] == f and r['break'] == b), '') for b in BREAKS]
            L.append('| %s | %s |' % (f, ' | '.join(cells)))
        L += ['', 'Details of the ones that do not say which file:', '']
        for r in rows:
            if r['verdict'] in ('FAILS_UNCLEAR', 'LATER_ERROR'):
                bad_inject += 1
                L.append('- %s (%s): `%s`' % (r['file'], r['break'], r['why']))
    L += ['', '---', 'OK_WARNED: loads, and a chat line names the file. OK_SILENT: loads, nothing said (fine for an',
          'optional file that is empty). FAILS_CLEAR: GearSwap stops, the error names the file.',
          'FAILS_UNCLEAR: stops, and the error points elsewhere. LATER_ERROR: loads, then fails a few seconds later.']
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, 'report.md'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(L) + '\n')
    with open(prev_path, 'w', encoding='utf-8') as f:
        json.dump({'at': time.strftime('%Y-%m-%d %H:%M'), 'loads': len(results), 'fatal': fatal,
                   'fatal_messages': now_fatal, 'inject_unclear': bad_inject,
                   'inject': {k: v for k, v in injected.items()}}, f, indent=1)
    return fatal, fresh, bad_inject, now_fatal


def main():
    ap = argparse.ArgumentParser(description='Load every job of every character outside the game.')
    ap.add_argument('chars', nargs='*')
    ap.add_argument('--quick', action='store_true', help='2 subjobs per job instead of all')
    ap.add_argument('--inject', action='append', help='Perso:JOB:SUB to break file by file (repeatable)')
    ap.add_argument('--no-inject', action='store_true')
    args = ap.parse_args()
    lua = find_lua()
    chars = args.chars or characters()
    specs = [] if args.no_inject else (args.inject or [s for s in DEFAULT_INJECT if s.split(':')[0] in chars])
    t0 = time.time()
    print('copy of the game folder ...', flush=True)
    lab = make_lab(sorted(set(chars) | {s.split(':')[0] for s in specs}))
    print('loads: %s%s' % (', '.join(chars), ' (quick)' if args.quick else ''), flush=True)
    results = sweep(lua, lab, chars, args.quick)
    injected = {}
    for spec in specs:
        print('broken files: %s ...' % spec, flush=True)
        injected[spec] = inject(lua, lab, spec)
    changed, new_fp = fingerprint_changes(results)
    fatal, fresh, unclear, messages = write_report(results, injected, changed, new_fp, time.time() - t0)
    shutil.rmtree(lab, ignore_errors=True)
    for m in messages[:8]:
        print('  ' + m[:200])
    print('\n%d loads, %d problems%s, %d broken-file cases that do not name the file, %d loads changed since last run'
          % (len(results), fatal, (' (%d new)' % len(fresh)) if fresh else '', unclear, len(changed)))
    print('report: %s' % os.path.join(OUT, 'report.md'))
    sys.exit(1 if fatal else 0)


if __name__ == '__main__':
    main()
