"""
Move a character folder to the layout of 2026-09-30.

    <Char>/<Char>_<JOB>.lua   one-line entry (shared/entry/<job>.lua does the work)
    <Char>/common/            settings of the whole character, alt/ and craft/
    <Char>/<job>/             everything of one job: its settings and its sets
    <Char>/saved/             files the game writes (window positions, traces...)

Usage (from the data folder):
    python migrate_layout.py <Character>            do it
    python migrate_layout.py <Character> --dry-run  only show what would move

A full copy of the folder is made first in data/_backups/<Character>_<date>/.
Nothing is ever overwritten: a file whose new place is taken is left where it
is and listed at the end. The shared code reads both layouts, so a folder left
half-moved still works. clone_character.py runs the same moves at the end of
every clone.

@author ejouanchicot
@date   Created: 2026-09-30
"""
import os
import re
import shutil
import sys
import time

JOBS = ['blm', 'blu', 'brd', 'bst', 'cor', 'dnc', 'drg', 'drk', 'geo', 'mnk', 'nin',
        'pld', 'pup', 'rdm', 'rng', 'run', 'sam', 'sch', 'smn', 'thf', 'war', 'whm']

# Files of config/ that the game writes: they go to saved/, not common/
SAVED_CONFIG = {'alt_state.lua', 'alt_window.lua', 'dualbox_role.lua', 'ui_settings.lua',
                'message_modes.lua', 'WARP_ITEMS_OWNED.lua'}
# Files at the root of the character folder that the game writes
SAVED_ROOT = {'temp_binds.lua', 'trace.log', 'trace.old.log', 'trace.on', 'atelier.on'}

HERE = os.path.dirname(os.path.abspath(__file__))


def new_place(rel):
    """New place of a file given relative to the character folder.

    Returns the new relative path, None when the file is dropped (the
    generated alt tables, now in shared/data/alt/, and the .example copies),
    or the path unchanged when it is not part of the old layout.
    """
    parts = rel.split('/')
    top = parts[0]
    if top == 'config':
        if len(parts) == 2:
            return ('saved/' if parts[1] in SAVED_CONFIG else 'common/') + parts[1]
        sub, rest = parts[1], '/'.join(parts[2:])
        if sub in JOBS:
            return sub + '/' + rest
        if sub == 'alt':
            if rest.endswith('_ALT_COMMANDS.lua') or rest.endswith('.example'):
                return None
            return 'common/alt/' + rest
        if sub == 'craft':
            return 'common/craft/' + rest
        return 'common/' + sub + '/' + rest
    if top == 'sets':
        if len(parts) == 2:
            name = parts[1]
            m = re.match(r'^(\w+)_sets\.lua$', name)
            if m and m.group(1) in JOBS:
                return m.group(1) + '/' + name
            return ('common/craft/' if name.endswith('_sets.lua') else 'common/') + name
        sub, rest = parts[1], '/'.join(parts[2:])
        if sub in JOBS:
            return sub + '/' + rest
        return 'common/' + rest if sub == 'common' else 'common/' + sub + '/' + rest
    if top == 'atelier':
        return 'saved/' + rel
    if len(parts) == 1 and rel in SAVED_ROOT:
        return 'saved/' + rel
    return rel


def plan_moves(char_dir):
    """List of (source, destination or None to delete) relative to char_dir."""
    moves = []
    for top in ('config', 'sets', 'atelier'):
        for root, _, files in os.walk(os.path.join(char_dir, top)):
            for f in files:
                rel = os.path.relpath(os.path.join(root, f), char_dir).replace('\\', '/')
                moves.append((rel, new_place(rel)))
    for name in sorted(os.listdir(char_dir)):
        if name in SAVED_ROOT and os.path.isfile(os.path.join(char_dir, name)):
            moves.append((name, new_place(name)))
    return moves


def rewrite_paths(text, char, moved):
    """Point the require/include paths inside a character file at the new places."""
    c = re.escape(char)
    jobs = '|'.join(JOBS)
    text = re.sub(r"(['\"])%s/sets/common/" % c, r"\1%s/common/" % char, text)
    text = re.sub(r"(['\"])%s/sets/(%s)/" % (c, jobs), r"\1%s/\2/" % char, text)
    text = re.sub(r"(['\"])%s/config/(%s)/" % (c, jobs), r"\1%s/\2/" % char, text)
    text = re.sub(r"(['\"])%s/config/" % c, r"\1%s/common/" % char, text)
    text = re.sub(r"(['\"])config/(%s)/" % jobs, r"\1\2/", text)

    def include_sets(m):
        old = 'sets/' + m.group(2)
        return m.group(1) + (moved.get(old) or new_place(old) or old) + m.group(3)
    text = re.sub(r"(include\(\s*['\"])sets/([^'\"]+)(['\"])", include_sets, text)
    return text


def stub_for(char, job):
    template = os.path.join(HERE, '_master', 'entry', 'Tetsouo_%s.lua' % job.upper())
    with open(template, encoding='utf-8') as f:
        return f.read().replace('Tetsouo', char).replace('@author  ' + char, '@author  ejouanchicot')


def migrate(char, dry_run=False, backup=True, quiet=False, base_dir=HERE):
    """Move one character folder. Returns the files left in place."""
    say = (lambda *a: None) if quiet else print
    char_dir = os.path.join(base_dir, char)
    if not os.path.isdir(char_dir):
        sys.exit('No folder %s' % char_dir)
    moves = plan_moves(char_dir)
    entries = []
    for name in sorted(os.listdir(char_dir)):
        m = re.match(r'^%s_(\w+)\.lua$' % re.escape(char), name)
        if m and m.group(1).lower() in JOBS:
            entries.append((name, m.group(1)))

    moved = {src: dst for src, dst in moves if dst}
    kept, done, deleted = [], 0, 0
    say('%s: %d files to move, %d entry files to shorten' % (char, len(moved), len(entries)))
    if dry_run:
        for src, dst in moves:
            say('  %-55s -> %s' % (src, dst or '(dropped: now in shared/data/alt, or an example copy)'))
        return kept

    if backup:
        target = os.path.join(base_dir, '_backups', '%s_%s' % (char, time.strftime('%Y%m%d_%H%M%S')))
        shutil.copytree(char_dir, target)
        say('Backup: %s' % target)

    for src, dst in moves:
        src_full = os.path.join(char_dir, src)
        if dst is None:
            os.remove(src_full)
            deleted += 1
            continue
        dst_full = os.path.join(char_dir, dst)
        if os.path.exists(dst_full):
            kept.append((src, dst))
            continue
        os.makedirs(os.path.dirname(dst_full), exist_ok=True)
        shutil.move(src_full, dst_full)
        done += 1

    for root, _, files in os.walk(char_dir):
        for f in files:
            if not f.endswith('.lua'):
                continue
            full = os.path.join(root, f)
            with open(full, 'rb') as fh:
                text = fh.read().decode('utf-8', errors='surrogateescape')
            new = rewrite_paths(text, char, moved)
            if new != text:
                with open(full, 'wb') as fh:
                    fh.write(new.encode('utf-8', errors='surrogateescape'))

    for name, job in entries:
        with open(os.path.join(char_dir, name), 'w', encoding='utf-8', newline='\n') as f:
            f.write(stub_for(char, job))

    for old in ('config', 'sets', 'atelier'):
        for root, _, _ in os.walk(os.path.join(char_dir, old), topdown=False):
            if not os.listdir(root):
                os.rmdir(root)
    for folder in ('common', 'saved'):
        os.makedirs(os.path.join(char_dir, folder), exist_ok=True)

    say('Moved %d, dropped %d (generated alt tables and examples), %d entries shortened.'
        % (done, deleted, len(entries)))
    if kept:
        say('Left in place (the new place already has a file):')
        for src, dst in kept:
            say('  %s  (new place: %s)' % (src, dst))
    return kept


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    migrate(sys.argv[1], '--dry-run' in sys.argv[2:])
