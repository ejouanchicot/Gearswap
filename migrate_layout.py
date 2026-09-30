"""
Move a character folder to the layout of 2026-09-30.

    <Char>/<Char>_<JOB>.lua   one-line entry (shared/entry/<job>.lua does the work)
    <Char>/common/            settings of the whole character, by theme:
        display/ keys/ dualbox/ (+ alt/) inventory/ combat/
        sets/                 gear shared by jobs (rings.lua...), craft and fishing sets
    <Char>/<job>/             one job, by theme:
        display/ keys/ combat/ inventory/
        sets/                 its gear: <job>_sets.lua, armor.lua...
    <Char>/saved/             files the game writes (window positions, traces...)

Usage (from the data folder):
    python migrate_layout.py <Character>            do it
    python migrate_layout.py <Character> --dry-run  only show what would move

A full copy of the folder is made first in data/_backups/<Character>_<date>/.
Nothing is ever overwritten: a file whose new place is taken is left where it
is and listed at the end. The shared code reads the old layouts too, so a
folder left half-moved still works. clone_character.py runs the same moves at
the end of every clone.

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
SAVED_ROOT = {'temp_binds.lua', 'trace.log', 'trace.old.log', 'trace.on', 'atelier.on',
              'rolldebug.log'}
# Lower-case files of common/ that are settings, not gear
COMMON_SETTINGS = {'combat_mode.lua', 'treasure_mode.lua'}
# Theme folder of each setting in common/ (same table as COMMON_GROUPS in
# shared/utils/core/char_paths.lua)
COMMON_GROUPS = {
    'UI_CONFIG.lua': 'display', 'UI_COLOR_CONFIG.lua': 'display',
    'REGION_CONFIG.lua': 'display', 'LOCKSTYLE_CONFIG.lua': 'display',
    'COMMON_KEYBINDS.lua': 'keys', 'combat_mode.lua': 'keys', 'treasure_mode.lua': 'keys',
    'DUALBOX_CONFIG.lua': 'dualbox',
    'REFILL_CONFIG.lua': 'inventory', 'CRAFT_CONFIG.lua': 'inventory',
    'CRAFT_REFILL.lua': 'inventory', 'WARDROBE_CONFIG.lua': 'inventory',
    'AUTO_ABILITIES.lua': 'combat', 'RECAST_CONFIG.lua': 'combat', 'DW_CONFIG.lua': 'combat',
    'ELEMENTAL_BELT.lua': 'combat', 'WEAPON_CONFIG.lua': 'combat', 'STEALTH_CONFIG.lua': 'combat',
}


def _common(name):
    group = COMMON_GROUPS.get(name)
    return 'common/%s/%s' % (group, name) if group else 'common/' + name


# Theme folder of a job settings file, from the end of its name (same rule as
# CharPaths.job_group in shared/utils/core/char_paths.lua)
JOB_GROUP_SUFFIXES = [('_HUD', 'display'), ('_LOCKSTYLE', 'display'), ('_MACROBOOK', 'display'),
                      ('_KEYBINDS', 'keys'), ('_STATES', 'keys'), ('_CUSTOM', 'keys'),
                      ('_REFILL', 'inventory')]


def _job(job, name):
    """New place of a file of a job folder (gear goes to sets/)."""
    if re.match(r'^[a-z0-9]', name):
        return '%s/sets/%s' % (job, name)
    base = name[:-4] if name.endswith('.lua') else name
    group = next((g for suffix, g in JOB_GROUP_SUFFIXES if base.endswith(suffix)), 'combat')
    return '%s/%s/%s' % (job, group, name)

HERE = os.path.dirname(os.path.abspath(__file__))
GEAR_NAME = re.compile(r'^[a-z0-9]')   # gear files are lower-case, settings upper-case


def _config_place(parts):
    if len(parts) == 2:
        return 'saved/' + parts[1] if parts[1] in SAVED_CONFIG else _common(parts[1])
    sub, rest = parts[1], '/'.join(parts[2:])
    if sub in JOBS:
        return _job(sub, rest) if '/' not in rest else sub + '/' + rest
    if sub == 'alt':
        if rest.endswith('_ALT_COMMANDS.lua') or rest.endswith('.example'):
            return None
        return 'common/dualbox/alt/' + rest
    if sub == 'craft':
        return 'common/sets/' + rest if rest.endswith('_sets.lua') else _common(rest)
    return 'common/' + sub + '/' + rest


def _sets_place(parts):
    if len(parts) == 2:
        m = re.match(r'^(\w+)_sets\.lua$', parts[1])
        if m and m.group(1) in JOBS:
            return m.group(1) + '/sets/' + parts[1]
        return 'common/sets/' + parts[1]
    sub, rest = parts[1], '/'.join(parts[2:])
    if sub in JOBS:
        return sub + '/sets/' + rest
    return 'common/sets/' + (rest if sub == 'common' else sub + '/' + rest)


def new_place(rel):
    """New place of a file given relative to the character folder.

    Returns the new relative path, None when the file is dropped (the
    generated alt tables, now in shared/data/alt/, and the .example copies),
    or the path unchanged when it is already in place.
    """
    parts = rel.split('/')
    top = parts[0]
    if top == 'config':
        return _config_place(parts)
    if top == 'sets':
        return _sets_place(parts)
    if top == 'atelier':
        return 'saved/' + rel
    if len(parts) == 1 and rel in SAVED_ROOT:
        return 'saved/' + rel
    # First form of this layout (2026-09-30 morning): gear next to the settings
    if top in JOBS and len(parts) == 2:
        return _job(top, parts[1])
    if top == 'common' and len(parts) == 2 and GEAR_NAME.match(parts[1]) \
            and parts[1] not in COMMON_SETTINGS:
        return 'common/sets/' + parts[1]
    if top == 'common' and len(parts) == 2:
        return _common(parts[1])
    if top == 'common' and len(parts) == 3 and parts[1] == 'craft':
        return 'common/sets/' + parts[2] if parts[2].endswith('_sets.lua') else _common(parts[2])
    if top == 'common' and len(parts) >= 3 and parts[1] == 'alt':
        return 'common/dualbox/alt/' + '/'.join(parts[2:])
    return rel


def plan_moves(char_dir):
    """List of (source, destination or None to drop) relative to char_dir."""
    moves = []

    def add(rel):
        dst = new_place(rel)
        if dst != rel:
            moves.append((rel, dst))

    for top in ('config', 'sets', 'atelier', 'common/craft', 'common/alt'):
        for root, _, files in os.walk(os.path.join(char_dir, top)):
            for f in files:
                add(os.path.relpath(os.path.join(root, f), char_dir).replace('\\', '/'))
    for top in JOBS + ['common']:
        folder = os.path.join(char_dir, top)
        if os.path.isdir(folder):
            for f in os.listdir(folder):
                if os.path.isfile(os.path.join(folder, f)):
                    add(top + '/' + f)
    for name in sorted(os.listdir(char_dir)):
        if name in SAVED_ROOT and os.path.isfile(os.path.join(char_dir, name)):
            add(name)
    return moves


def rewrite_paths(text, char, moved):
    """Point the require/include paths inside a character file at the new places."""
    # every moved file, by its exact old name
    for old, new in moved.items():
        if not (old.endswith('.lua') and new):
            continue
        old_mod, new_mod = old[:-4], new[:-4]
        text = re.sub("(['\"])" + re.escape(char + '/' + old_mod) + "(['\"])",
                      lambda m: m.group(1) + char + '/' + new_mod + m.group(2), text)
        text = re.sub("(include\\(\\s*['\"])" + re.escape(old) + "(['\"])",
                      lambda m: m.group(1) + new + m.group(2), text)
    # old-style names of files that were already moved or never existed here
    c, jobs = re.escape(char), '|'.join(JOBS)
    text = re.sub("(['\"])%s/sets/common/" % c, "\\1%s/common/sets/" % char, text)
    text = re.sub("(['\"])%s/sets/(%s)/" % (c, jobs), "\\1%s/\\2/sets/" % char, text)
    text = re.sub("(['\"])%s/config/(%s)/" % (c, jobs), "\\1%s/\\2/" % char, text)
    text = re.sub("(['\"])%s/config/" % c, "\\1%s/common/" % char, text)
    text = re.sub("(['\"])config/(%s)/" % jobs, "\\1\\2/", text)

    def include_sets(m):
        old = 'sets/' + m.group(2)
        return m.group(1) + (moved.get(old) or new_place(old) or old) + m.group(3)
    text = re.sub("(include\\(\\s*['\"])sets/([^'\"]+)(['\"])", include_sets, text)
    return rewrite_comment_paths(text, char)


def rewrite_comment_paths(text, char):
    """Point the <Char>/config/... and <Char>/sets/... paths written in
    comments (file headers, "defined in" notes) at the new places, so a reader
    who follows them finds the file."""
    def fix(m):
        new = new_place(m.group(2))
        return m.group(1) + new if new else m.group(0)
    return re.sub(r"(%s/)((?:config|sets)/[\w./-]+\.lua)" % re.escape(char), fix, text)


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
    kept, done, dropped = [], 0, 0
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
            dropped += 1
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

    for old in ('config', 'sets', 'atelier', 'common/craft', 'common/alt'):
        for root, _, _ in os.walk(os.path.join(char_dir, old), topdown=False):
            if not os.listdir(root):
                os.rmdir(root)
    for folder in ('common', 'saved'):
        os.makedirs(os.path.join(char_dir, folder), exist_ok=True)

    say('Moved %d, dropped %d (generated alt tables and examples), %d entries shortened.'
        % (done, dropped, len(entries)))
    if kept:
        say('Left in place (the new place already has a file):')
        for src, dst in kept:
            say('  %s  (new place: %s)' % (src, dst))
    return kept


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    migrate(sys.argv[1], '--dry-run' in sys.argv[2:])
