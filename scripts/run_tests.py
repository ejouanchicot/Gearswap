"""Run every offline test of the project and sum them up in one table.

    python scripts/run_tests.py           the quick ones (about 3 min, most of it the Lua syntax check)
    python scripts/run_tests.py --full    and the slow ones: the Atelier page in Chrome, the Lua the page
                                          writes, the export without the game (about 10 min)
    python scripts/run_tests.py -v        the output of every test, not only of those that failed

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
import glob
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
SLOW = {'scripts/atelier/atelier_test.js', 'scripts/atelier/atelier_modules_test.js',
        'scripts/atelier/offline_export_page_test.js', 'scripts/atelier/offline_export_test.js'}
# A test that needs an argument to know what it tests
ARGS = {'scripts/audit/test_automove_cast.lua': ['shared/utils/movement/automove.lua']}
# Not tests: a tool (fight_run_check plays a run for a character given by hand)
SKIP = {'scripts/audit/fight_run_check.lua'}


def tests(full):
    lua = sorted(glob.glob('scripts/atelier/*_test.lua')) + sorted(glob.glob('scripts/audit/test_*.lua'))
    js = (['scripts/atelier/atelier_names_check.js', 'scripts/atelier/atelier_text_check.js',
           'scripts/atelier/atelier_items_check.js', 'scripts/atelier/bags_locked_check.js']
          + sorted(glob.glob('scripts/audit/calc_*check.js'))
          + ['scripts/atelier/atelier_modules_test.js', 'scripts/atelier/offline_export_page_test.js',
             'scripts/atelier/offline_export_test.js', 'scripts/atelier/atelier_test.js'])
    out = [('python', 'scripts/check_syntax.py')]
    out += [('lua5.1', t.replace(os.sep, '/')) for t in lua]
    out += [('node', t.replace(os.sep, '/')) for t in js if os.path.exists(t)]
    return [(run, t) for run, t in out if t not in SKIP and (full or t not in SLOW)]


def main():
    os.chdir(DATA)
    full, verbose = '--full' in sys.argv, '-v' in sys.argv
    rows, failed = [], 0
    for run, t in tests(full):
        start = time.time()
        exe = sys.executable if run == 'python' else shutil.which(run)
        if not exe:
            raise SystemExit('%s not found on the PATH' % run)
        proc = subprocess.run([exe, t] + ARGS.get(t, []), capture_output=True, text=True,
                              encoding='utf-8', errors='replace')
        took = time.time() - start
        text = (proc.stdout + proc.stderr).strip()
        last = text.splitlines()[-1].strip() if text else ''
        if t in REPORTS:
            state = 'report'
        elif proc.returncode == 0:
            state = 'ok' if t not in KNOWN else 'ok (was known)'
        elif t in KNOWN and KNOWN[t][1] in text:
            state = 'known'
        else:
            state = 'FAIL'
            failed += 1
        rows.append((state, took, t, KNOWN[t][0] if state == 'known' else last))
        if verbose or state == 'FAIL':
            print('---- %s %s\n%s\n' % (state, t, text[-4000:]))
    for state, took, t, note in rows:
        print('%-15s %6.1fs  %-48s %s' % (state, took, t, note[:90]))
    print('\n%d run, %d failed%s' % (len(rows), failed, '' if full else ' (quick set; --full for the slow ones)'))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
