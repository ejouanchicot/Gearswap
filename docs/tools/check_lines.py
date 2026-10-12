"""Check, and bring up to date, the `file:line` citations of the documentation.

The developer pages cite the code as `path/file.lua:123` or `file.lua:123`. (A bare `:123` after a file was
named is not followed: which file it means is said by the sentence, not by anything a script can read.) Code moves, the numbers do not. For each citation this finds the commit that last wrote the line
of the page holding it (git blame), then follows the cited line of the code from that commit to now through
the file's diff: unchanged lines above it shift it by a known amount. Three outcomes:

  moved      the cited line is still there, at another number: the citation can be rewritten
  changed    the cited line itself was edited or removed since: a person must look
  missing    the file is not in the repository (engine files, outside it, are left alone)

    python docs/tools/check_lines.py            report
    python docs/tools/check_lines.py --write    rewrite the citations that only moved

Also reported: a cited line past the end of its file, and the line counts given in tables
(`| path/file.lua | 692 |`) that no longer match.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXT = r'(?:lua|js|py|md|css|html|json)'
FILE = re.compile(r'(?<![\w./-])((?:[\w.-]+/)*[\w.-]+\.' + EXT + r')(?::(\d+)(?:-(\d+))?)?')
TOKEN = FILE
COUNT_ROW = re.compile(r'^\|\s*`([\w./-]+\.' + EXT + r')`\s*\|\s*([\d  ]+)\s*\|')


def git(*args):
    return subprocess.run(['git', '-C', ROOT, *args], capture_output=True, text=True, encoding='utf-8', errors='replace').stdout


TRACKED = [p for p in git('ls-files').splitlines() if p]
BY_BASE = {}
for path in TRACKED:
    BY_BASE.setdefault(os.path.basename(path), []).append(path)
LENGTH = {}


def length(path):
    if path not in LENGTH:
        try:
            with open(os.path.join(ROOT, path), 'rb') as f:
                LENGTH[path] = f.read().count(b'\n') + 1
        except OSError:
            LENGTH[path] = None
    return LENGTH[path]


def resolve(name, recent):
    """The tracked file a citation names: its path, the end of a path, or a base name (the one named last)."""
    name = name.lstrip('./')
    if name in TRACKED_SET:
        return name
    ends = [p for p in TRACKED if p.endswith('/' + name)]
    if len(ends) == 1:
        return ends[0]
    bases = BY_BASE.get(os.path.basename(name), [])
    pool = ends or bases
    for seen in reversed(recent):
        if seen in pool:
            return seen
    return pool[0] if len(pool) == 1 else None


TRACKED_SET = set(TRACKED)
BLAME = {}


def blame(doc):
    """The commit that last wrote each line of a page (None for a line not committed yet)."""
    if doc not in BLAME:
        commits, out = [], git('blame', '--line-porcelain', '--', doc)
        for line in out.splitlines():
            m = re.match(r'^([0-9a-f]{40}) \d+ \d+', line)
            if m:
                commits.append(None if set(m.group(1)) == {'0'} else m.group(1))
        BLAME[doc] = commits
    return BLAME[doc]


HUNKS = {}


def hunks(commit, path):
    """The changes of a file from a commit to now: [(old start, old count, new start, new count)]; None when the
    file was not there at that commit."""
    key = (commit, path)
    if key not in HUNKS:
        if not git('ls-tree', commit, '--', path).strip():
            HUNKS[key] = None
        else:
            found = []
            for line in git('diff', '-U0', commit, 'HEAD', '--', path).splitlines():
                m = re.match(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@', line)
                if m:
                    found.append((int(m.group(1)), int(m.group(2) or 1), int(m.group(3)), int(m.group(4) or 1)))
            HUNKS[key] = found
    return HUNKS[key]


def follow(commit, path, line):
    """Where a line of a file at a commit is now: (new line, 'same' | 'moved' | 'changed' | 'unknown')."""
    if commit is None:
        return line, 'same'
    changes = hunks(commit, path)
    if changes is None:
        return line, 'unknown'
    shift = 0
    for old, old_n, new, new_n in changes:
        if old_n == 0:                      # lines added after `old`
            if line > old:
                shift += new_n
            continue
        if line < old:
            break
        if line < old + old_n:
            return line, 'changed'
        shift += new_n - old_n
    return line + shift, 'moved' if shift else 'same'


def check(doc, write):
    # (newline='': the page's own line ends are kept as they are, and written back the same)
    with open(os.path.join(ROOT, doc), encoding='utf-8', newline='') as f:
        lines = f.read().split('\n')
    commits, recent, report = blame(doc), [], []
    for n, text in enumerate(lines):
        commit = commits[n] if n < len(commits) else None
        row = COUNT_ROW.match(text)
        if row and row.group(1) in TRACKED_SET:
            said, real = int(re.sub(r'\D', '', row.group(2)) or 0), length(row.group(1)) - 1
            if said and abs(said - real) > 0:
                report.append((n + 1, 'count', '%s: %d lines said, %d now' % (row.group(1), said, real)))
                if write:
                    text = text.replace(row.group(2).strip(), str(real), 1)

        def swap(m):
            name, first, last = m.group(1), m.group(2), m.group(3)
            path = resolve(name, recent)
            if path:
                recent.append(path)
            elif ('/' in name and name.startswith(('shared/', 'docs/', 'scripts/', 'atelier/', '_master/')) and '<' not in name
                  and not os.path.exists(os.path.join(ROOT, name))):      # (on the disk and not tracked: not missing)
                report.append((n + 1, 'missing', name))
            if not (path and first):
                return m.group(0)
            out = []
            for number in (first, last):
                if number is None:
                    continue
                number = int(number)
                new, state = follow(commit, path, number)
                if state == 'changed':
                    report.append((n + 1, 'changed', '%s:%d' % (path, number)))
                elif new > (length(path) or 0):
                    report.append((n + 1, 'past the end', '%s:%d (%s lines)' % (path, new, length(path))))
                    new = number
                elif state == 'moved':
                    report.append((n + 1, 'moved', '%s:%d -> %d' % (path, number, new)))
                out.append(new if state == 'moved' else number)
            if not write or out == [int(x) for x in (first, last) if x is not None]:
                return m.group(0)
            numbers = '-'.join(str(x) for x in out)
            return '%s:%s' % (name, numbers)

        lines[n] = TOKEN.sub(swap, text)
    if write:
        with open(os.path.join(ROOT, doc), 'w', encoding='utf-8', newline='') as f:
            f.write('\n'.join(lines))
    return report


def main():
    write = '--write' in sys.argv
    docs = [p for p in TRACKED if p.startswith('docs/') and p.endswith('.md')] + [p for p in ('README.md', 'CLAUDE.md') if p in TRACKED_SET]
    totals = {}
    for doc in docs:
        for line, kind, what in check(doc, write):
            totals[kind] = totals.get(kind, 0) + 1
            if kind != 'moved' or '--all' in sys.argv:
                print('%s:%d  %s  %s' % (doc, line, kind, what))
    print('\n' + ', '.join('%d %s' % (v, k) for k, v in sorted(totals.items())) or 'nothing to say')
    if write:
        print('the citations that only moved, and the line counts, were rewritten')


if __name__ == '__main__':
    main()
