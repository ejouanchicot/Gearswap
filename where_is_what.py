"""
Write <Character>/_WHERE-IS-WHAT.txt: every file of a character folder, what
it holds, and the command that changes it when there is one. Built from the
files really there, so it stays true after a file is added or moved.

Usage (from the data folder):
    python where_is_what.py <Character>

migrate_layout.py (and so clone_character.py) writes it at the end of every
run.

@author ejouanchicot
@date   Created: 2026-09-30
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FILE_NAME = '_WHERE-IS-WHAT.txt'

# Files of _common/, by name
COMMON = {
    'UI_CONFIG.lua': 'HUD: position, font, background, which sections show',
    'UI_COLOR_CONFIG.lua': 'HUD and chat colours of this character',
    'REGION_CONFIG.lua': 'Your game region (which chat colours exist)',
    'LOCKSTYLE_CONFIG.lua': 'Delays before the lockstyle is applied after a load or a job change',
    'ADDONS_CONFIG.lua': 'Windower addons a job loads / unloads for you (rolltracker, bst-hud, pettp, AzureSets)',
    'COMMON_KEYBINDS.lua': 'Keys every job gets (Auto Medicine, alts follow / mirror, Sneak / Invisible, your own)',
    'combat_mode.lua': 'Combat Mode: which jobs show it and its key (written by //gs c combatmode)',
    'treasure_mode.lua': 'Treasure Mode: which jobs show it and its key (written by //gs c th)',
    'DUALBOX_CONFIG.lua': 'Dual-box: main or alt, the other character, the box group',
    'REFILL_CONFIG.lua': 'Refill: which bags items are taken from and put back to',
    'CRAFT_CONFIG.lua': 'Craft / fishing: which set file //gs c craft and //gs c fish use, lockstyle',
    'CRAFT_REFILL.lua': 'Items refilled while a craft set is on',
    'WARDROBE_CONFIG.lua': 'Wardrobe organizer (//gs c wo): wardrobes it fills, overflows to and leaves alone',
    'AUTO_ABILITIES.lua': 'Job abilities used for you (Hasso, Entrust...), all off by default',
    'RECAST_CONFIG.lua': 'How close to ready a recast counts as ready',
    'DW_CONFIG.lua': 'Dual Wield tiers: less Dual Wield gear as haste goes up',
    'ELEMENTAL_BELT.lua': 'Hachirin-no-Obi / Orpheus\'s Sash picked automatically',
    'WEAPON_CONFIG.lua': 'How the weapon states equip a weapon that has no set',
    'STEALTH_CONFIG.lua': 'Sneak / Invisible on you and your alts (//gs c stealth)',
    'AUTOCURE_CONFIG.lua': 'Auto Medicine: debuffs cured, the items used, On or Off at start',
    'TUNING.lua': 'Thresholds and names some jobs use (SAM idle HP, refresh MP, waltz tiers, SMN skill-up, GEO escort, BRD debuff songs)',
    'SORTIE_CONFIG.lua': '//gs c sortie: the alt, its Silmaril profiles, your stances per target',
    'HP_PRIORITY.lua': 'Order the pieces go on in, so max HP never dips (Unity rank, MP jobs)',
    'rings.lua': 'Rings you own twice, each pinned to its wardrobe; the job sets use them',
}

# Job files, by the end of their name (checked in order)
JOB_SUFFIXES = [
    ('_HUD', 'HUD rows of the job and their order (//gs c ui roworder)'),
    ('_LOCKSTYLE', 'Lockstyle set number, per subjob'),
    ('_MACROBOOK', 'Macro book and page, per subjob (solo and dual-box)'),
    ('_KEYBINDS', 'Keys of the job and the state each one cycles'),
    ('_STATES', 'States of the job (modes, weapons...) and their defaults'),
    ('_CUSTOM', 'Your own states, keys and gear rules, without code'),
    ('_TP_CONFIG', 'TP bonus sources (merits, job points...) used to pick the weaponskill gear'),
    ('_WS_CONFIG', 'Weaponskills of the WS slots, per weapon'),
    ('_REFILL', 'Items refilled on this job (//gs c refill)'),
    ('_SONG_CONFIG', 'Songs of each song pack'),
    ('_SABOTEUR_CONFIG', 'When Saboteur goes before an enfeeble'),
    ('_CURE_CONFIG', 'Cure tier picked from the missing HP'),
    ('_BLU_MAGIC', 'Blue Magic spells and their sets'),
    ('_SPELL_MAP', 'Blue Magic spells and their sets'),
    ('_PET_DATA', 'Jug pets and their data'),
    ('_ECOSYSTEM_DATA', 'Jug pets by ecosystem'),
    ('_ELEMENTAL_CONFIG', 'Nuke settings (automatic belt, storm / day / weather checks)'),
    ('_MP_CONFIG', 'MP threshold of the job'),
    ('_WEAPONS', 'Shield per weapon and mode, the weapon a stance forces, grips'),
    ('_TIMING_CONFIG', 'Song rotation timings (//gs c songs, //gs c dummy)'),
]
GEAR = {
    'armor.lua': 'Armor pieces the sets use (defined once here)',
    'capes.lua': 'Capes the sets use, with their augments',
    'weapons.lua': 'Weapons the sets and the weapon states use',
    'instruments.lua': 'Instruments the song sets use',
    'pets.lua': 'Pet gear the sets use',
}
SAVED = ('Written by GearSwap itself (window positions, HUD and chat settings, dual-box role, '
         'gear augments of //gs c gearscan, traces). No need to edit.')


def describe_job_file(job, name):
    if name == '%s_sets.lua' % job:
        return 'Every set of the job (idle, engaged, precast, midcast, weaponskills...)'
    if name in GEAR:
        return GEAR[name]
    base = name[:-4] if name.endswith('.lua') else name
    for suffix, text in JOB_SUFFIXES:
        if base.endswith(suffix):
            return text
    return 'Gear the sets use' if re.match(r'^[a-z0-9]', name) else 'Setting of the job'


def describe_common_file(rel):
    name = rel.split('/')[-1]
    if rel.startswith('dualbox/alt/'):
        return 'Your own commands for the alt on %s' % name.split('_')[0]
    if name in COMMON:
        return COMMON[name]
    if name.endswith('_sets.lua'):
        return 'Craft or fishing set (named in CRAFT_CONFIG.lua)'
    return 'Gear shared by your jobs' if rel.startswith('sets/') else 'Setting of the whole character'


def files_under(folder):
    out = []
    for root, _, files in os.walk(folder):
        for f in files:
            if f.endswith('.lua'):
                out.append(os.path.relpath(os.path.join(root, f), folder).replace('\\', '/'))
    return sorted(out, key=str.lower)


def build(char, char_dir):
    lines = [
        'WHERE IS WHAT - %s' % char,
        '=' * 60,
        'Every file of this folder and what it holds. Written by',
        'where_is_what.py (again after migrate_layout.py or a clone):',
        'edit the files, not this list.',
        '',
        '%s_<JOB>.lua     one line each, the game loads them; nothing to edit' % char,
        '_common/          settings of the whole character (every job)',
        '<job>/            one folder per job: display/ keys/ combat/ inventory/ sets/',
        'saved/            written by GearSwap itself',
        '',
    ]
    common = os.path.join(char_dir, '_common')
    if os.path.isdir(common):
        lines += ['_common/  (every job)', '-' * 60]
        for rel in files_under(common):
            lines.append('  %-38s %s' % (rel, describe_common_file(rel)))
        lines.append('')
    for job in sorted(os.listdir(char_dir)):
        folder = os.path.join(char_dir, job)
        if not (os.path.isdir(folder) and re.match(r'^[a-z]{3}$', job)):
            continue
        lines += ['%s/  (%s)' % (job, job.upper()), '-' * 60]
        for rel in files_under(folder):
            lines.append('  %-38s %s' % (rel, describe_job_file(job, rel.split('/')[-1])))
        lines.append('')
    lines += ['saved/', '-' * 60, '  ' + SAVED, '']
    return '\r\n'.join(lines)


def write(char, base_dir=HERE):
    char_dir = os.path.join(base_dir, char)
    with open(os.path.join(char_dir, FILE_NAME), 'w', encoding='utf-8', newline='') as f:
        f.write(build(char, char_dir))


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    write(sys.argv[1])
    print('Wrote %s/%s' % (sys.argv[1], FILE_NAME))
