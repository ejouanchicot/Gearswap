"""
Release files: the manifest that tells a player's Atelier page what a version holds.

A release is a tag v<VERSION> on GitHub whose commit holds release_manifest.json: every file the update
replaces (the code a player package ships: make_package.py's DATA_FILES and TREES under data/, without the
page-only files), each with its git blob hash. The Atelier page (atelier/app/js/update_core.js) reads that
manifest from raw.githubusercontent.com at the tag, hashes the player's files the same way and downloads
only the ones that differ. Player folders (<Character>/...) are never in it.

Usage (from the data folder, the tree committed):
    python scripts/release/release.py manifest   write release_manifest.json from HEAD
    python scripts/release/release.py check      the manifest matches HEAD (run before tagging)

Steps of a release:
    1. VERSION bumped, release notes written, everything committed
    2. python scripts/release/release.py manifest ; git add release_manifest.json ; git commit
    3. git tag v<VERSION> ; git push origin master v<VERSION>
    4. gh release create v<VERSION> --title v<VERSION> --notes-file <notes>

@author ejouanchicot
@date   Created: 2026-10-21
"""
import json
import os
import subprocess
import sys

DATA = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
sys.path.insert(0, DATA)
import make_package  # noqa: E402

MANIFEST = 'release_manifest.json'
REPO = 'ejouanchicot/Gearswap'


def git(*args):
    return subprocess.run(['git', *args], cwd=DATA, check=True, capture_output=True, text=True).stdout


def scope():
    """The data-relative files and folders an update covers: what a package ships from data/, page-only files out."""
    files = {f[len('data/'):] for f in make_package.DATA_FILES if f.startswith('data/')}
    trees = [t[len('data/'):] + '/' for t in make_package.TREES if t.startswith('data/')]
    skip = {f[len('data/'):] for f in make_package.PAGE_ONLY}
    return files, trees, skip


def tree_files(ref='HEAD'):
    """{path: blob hash} of every file committed at ref, in the update's scope (the manifest itself out)."""
    files, trees, skip = scope()
    out = {}
    for line in git('ls-tree', '-r', ref).splitlines():
        meta, path = line.split('\t', 1)
        mode, kind, blob = meta.split()
        if kind != 'blob' or path == MANIFEST or path in skip:
            continue
        if path in files or any(path.startswith(t) for t in trees):
            out[path] = blob
    return dict(sorted(out.items()))


def version():
    with open(os.path.join(DATA, 'VERSION'), encoding='utf-8') as f:
        return f.read().strip()


def build():
    return {'version': version(), 'repo': REPO, 'commit': git('rev-parse', 'HEAD').strip(), 'files': tree_files()}


def write():
    m = build()
    with open(os.path.join(DATA, MANIFEST), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(m, f, indent=1, sort_keys=False)
        f.write('\n')
    print('%s: version %s, %d files' % (MANIFEST, m['version'], len(m['files'])))


def check():
    try:
        with open(os.path.join(DATA, MANIFEST), encoding='utf-8') as f:
            m = json.load(f)
    except OSError:
        sys.exit('no %s: run "release.py manifest"' % MANIFEST)
    now = tree_files()
    bad = []
    if m.get('version') != version():
        bad.append('version %s, VERSION says %s' % (m.get('version'), version()))
    for path in sorted(set(now) | set(m['files'])):
        if now.get(path) != m['files'].get(path):
            bad.append('%s: %s' % (path, 'missing from HEAD' if path not in now else 'not in the manifest'
                                   if path not in m['files'] else 'changed since'))
    if bad:
        sys.exit('manifest out of date:\n  ' + '\n  '.join(bad[:30]))
    print('manifest OK: version %s, %d files' % (m['version'], len(now)))


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'manifest':
        write()
    elif cmd == 'check':
        check()
    else:
        sys.exit(__doc__)
