"""Run every offline test of the project and sum them up in one table.

    python scripts/run_tests.py           the quick ones (about 15 s)
    python scripts/run_tests.py --full    and the slow ones: the Atelier page in Chrome, its click tests, the Lua the page
                                          writes, the export without the game, the packages
                                          make_package.py builds, in Python and in the page (5 to 40 min)
    python scripts/run_tests.py --all     --full, the slowest ones run even when nothing they check changed
    python scripts/run_tests.py -v        the output of every test, not only of those that failed
    python scripts/run_tests.py -j 1      one test at a time (by default up to 6 run together; the two
                                          that write into the real exports always run alone, at the end)

The two slowest (the export without the game, 25 min; the packages, 8 min) are skipped by --full when none
of the files they check changed since they last passed here (WATCH below; the passes are kept in
.git/run_tests_cache.json). The characters' own folders are not among those files: --all after changing them.

Run from anywhere; the tests run from data/. Exits 1 when a test fails.

Three kinds of line:
  test    must pass (exit code 0)
  known   fails today for a reason written down below; the table says so, and says when it passes again
  report  a comparison to read, not a pass or a fail (the calc engine against the old engine's reference
          battery: the gaps are documented in atelier/calc/DIFFERENCES.md)

scripts/audit/ is gitignored: its tests run when the folder is there. The differential tests
(scripts/audit/difftest_*.lua) compare two versions of a file and are run by hand during a refactor.
Needs lua5.1 and node on the PATH; --full also needs Chrome and Puppeteer (see atelier_test.js).

@file    scripts/run_tests.py
@author  ejouanchicot
@date    Created: 2026-10-15
"""
import concurrent.futures
import glob
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time

DATA = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Failing today, on purpose or with a known cause: (why, what the last line says when it is that cause)
KNOWN = {
    'scripts/audit/calc_dnc_ingame_check.js':
        ('Ruthless Stroke measured off the engine (documented gap, atelier/calc/DIFFERENCES.md)', 'FAILED'),
    'scripts/atelier/atelier_text_check.js':
        ('4 checks of French names failing since before 2026-10-14 (mode and settings texts)', '4 check(s) failed'),
}
REPORTS = {'scripts/audit/calc_check.js', 'scripts/audit/calc_round_check.js', 'scripts/audit/calc_ws_check.js'}
SLOW = {'scripts/atelier/atelier_test.js', 'scripts/atelier/atelier_modules_test.js', 'scripts/atelier/atelier_clicks_test.js',
        'scripts/atelier/offline_export_page_test.js', 'scripts/atelier/offline_export_test.js',
        'scripts/atelier/make_package_test.py', 'scripts/atelier/make_package_page_test.js',
        'scripts/loadcheck/check_load.py'}
# They write into the characters' real exports and atelier/index.js, then put them back: run alone, after the
# others (atelier_test.js, the packages and the load check read those files)
ALONE = {'scripts/atelier/offline_export_page_test.js', 'scripts/atelier/offline_export_test.js'}
# The files a slow test checks (and the test itself): unchanged since it last passed, --full skips it
WATCH = {
    'scripts/atelier/offline_export_test.js': ['atelier/app/js/offline_export.js', 'atelier/lua/', 'scripts/atelier/atelier_all.py',
                                               'scripts/atelier/load_job.lua', 'shared/', '_master/'],
    'scripts/atelier/make_package_test.py': ['make_package.py', 'clone_character.py', 'migrate_layout.py', 'migrate_config.py',
                                             'where_is_what.py', 'character_db.lua', '_master/', 'atelier/app/js/offline_export.js',
                                             'scripts/atelier/package_exports_cli.js'],
}
CACHE = os.path.join(DATA, '.git', 'run_tests_cache.json')


def fingerprint(t):
    """What the files a test checks are now: git's id of each tracked one, the size and time of each one changed
    or not tracked."""
    paths = [t] + WATCH[t]
    git = lambda *a: subprocess.run(['git'] + list(a) + ['--'] + paths, cwd=DATA, capture_output=True, text=True,
                                    encoding='utf-8', errors='replace').stdout
    loose = sorted(set(git('diff', '--name-only').split() + git('ls-files', '-o', '--exclude-standard').split()))
    stamp = []
    for rel in loose:
        try:
            st = os.stat(os.path.join(DATA, rel))
            stamp.append('%s %d %d' % (rel, st.st_size, st.st_mtime_ns))
        except OSError:
            stamp.append(rel + ' gone')
    return hashlib.sha1((git('ls-files', '-s') + '\n'.join(stamp)).encode('utf-8')).hexdigest()


def read_cache():
    try:
        with open(CACHE, encoding='utf-8') as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


# A test that needs an argument to know what it tests
ARGS = {'scripts/audit/test_automove_cast.lua': ['shared/utils/movement/automove.lua'],
        # every character's jobs with 2 subjobs each; the whole sweep and the broken files: run it by hand
        'scripts/loadcheck/check_load.py': ['--quick', '--no-inject']}
# Not tests: a tool (fight_run_check plays a run for a character given by hand)
SKIP = {'scripts/audit/fight_run_check.lua'}


def tests(full):
    lua = sorted(glob.glob('scripts/atelier/*_test.lua')) + sorted(glob.glob('scripts/audit/test_*.lua'))
    js = (['scripts/atelier/atelier_build_check.js', 'scripts/atelier/atelier_types_check.js', 'scripts/atelier/atelier_names_check.js',
           'scripts/atelier/atelier_text_check.js',
           'scripts/atelier/atelier_items_check.js', 'scripts/atelier/bags_locked_check.js', 'scripts/atelier/update_test.js']
          + sorted(glob.glob('scripts/audit/calc_*check.js'))
          + ['scripts/atelier/atelier_modules_test.js', 'scripts/atelier/offline_export_page_test.js',
             'scripts/atelier/offline_export_test.js', 'scripts/atelier/atelier_test.js', 'scripts/atelier/atelier_clicks_test.js'])
    js += ['scripts/atelier/make_package_page_test.js']
    # check_overlay.py: a re-clone would give every live file back as it is (the overlays had fallen behind the
    # live again with nothing to say so, audit 2026-10-28 E); it reads the gitignored live folders, so it only runs
    # where they are
    out = [('python', 'scripts/check_syntax.py'), ('python', 'scripts/atelier/make_package_test.py'),
           ('python', 'scripts/check_overlay.py'),
           ('python', 'scripts/loadcheck/check_load.py')]
    if not all(os.path.isdir(c) for c in ('Tetsouo', 'Kaories')):
        out = [x for x in out if x[1] != 'scripts/check_overlay.py']
    out += [('lua5.1', t.replace(os.sep, '/')) for t in lua]
    out += [('node', t.replace(os.sep, '/')) for t in js if os.path.exists(t)]
    # RUN_TESTS_SKIP: tests left out this time, comma-separated (scripts/atelier/cycle.sh has just run the click tests)
    skip = SKIP | set(filter(None, os.environ.get('RUN_TESTS_SKIP', '').split(',')))
    return [(run, t) for run, t in out if t not in skip and (full or t not in SLOW)]


# The longest a test may run before it is stopped and counted failed (a hung browser or worker held the whole
# run before: audit 2026-10-28); the slow ones take up to ~15 min today
TIMEOUT_QUICK, TIMEOUT_SLOW = 600, 1800


def run_one(run, t):
    start = time.time()
    exe = sys.executable if run == 'python' else shutil.which(run)
    if not exe:
        raise SystemExit('%s not found on the PATH' % run)
    limit = TIMEOUT_SLOW if t in SLOW else TIMEOUT_QUICK
    try:
        proc = subprocess.run([exe, t] + ARGS.get(t, []), capture_output=True, text=True,
                              encoding='utf-8', errors='replace', timeout=limit)
    except subprocess.TimeoutExpired as e:
        out = e.stdout.decode('utf-8', 'replace') if isinstance(e.stdout, bytes) else (e.stdout or '')
        proc = subprocess.CompletedProcess(e.cmd, 1, out, 'stopped after %d s (run_tests.py TIMEOUT)' % limit)
    return proc, time.time() - start


def judge(t, proc):
    text = (proc.stdout + proc.stderr).strip()
    if t in REPORTS:
        return 'report', text
    if proc.returncode == 0:
        return ('ok' if t not in KNOWN else 'ok (was known)'), text
    if t in KNOWN and KNOWN[t][1] in text:
        return 'known', text
    return 'FAIL', text


def main():
    os.chdir(DATA)
    every = '--all' in sys.argv
    full, verbose = '--full' in sys.argv or every, '-v' in sys.argv
    jobs = int(sys.argv[sys.argv.index('-j') + 1]) if '-j' in sys.argv else 6
    cache, prints = read_cache(), {}
    for t in WATCH:
        prints[t] = fingerprint(t)
    unchanged = {t for t in WATCH if not every and cache.get(t) == prints[t]}
    todo = tests(full)
    skipped = [x for x in todo if x[1] in unchanged]
    todo = [x for x in todo if x[1] not in unchanged]
    together, alone = [x for x in todo if x[1] not in ALONE], [x for x in todo if x[1] in ALONE]
    done = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, jobs)) as pool:
        for x, res in zip(together, pool.map(lambda x: run_one(*x), together)):
            done[x] = res
    for x in alone:
        done[x] = run_one(*x)
    rows, failed = [], 0
    for run, t in todo:
        proc, took = done[(run, t)]
        state, text = judge(t, proc)
        last = text.splitlines()[-1].strip() if text else ''
        failed += state == 'FAIL'
        rows.append((state, took, t, KNOWN[t][0] if state == 'known' else last))
        if verbose or state == 'FAIL':
            print('---- %s %s\n%s\n' % (state, t, text[-4000:]))
        # a pass kept with what its files were when it started
        if t in WATCH and state == 'ok':
            cache[t] = prints[t]
    with open(CACHE, 'w', encoding='utf-8') as f:
        json.dump(cache, f, indent=1)
    for run, t in skipped:
        rows.append(('skip', 0.0, t, 'none of its files changed since it last passed (--all runs it)'))
    for state, took, t, note in rows:
        print('%-15s %6.1fs  %-48s %s' % (state, took, t, note[:90]))
    print('\n%d run, %d failed%s%s' % (len(rows) - len(skipped), failed, ', %d skipped' % len(skipped) if skipped else '',
                                       '' if full else ' (quick set; --full for the slow ones)'))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
