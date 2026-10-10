"""
Tidy a character's settings to the layout of 2026-10-10.

    A setting of one job goes to that job's folder:
        <Char>/<job>/combat/<JOB>_CONFIG.lua      (BRD: its BRD_SONG_CONFIG.lua)
      taken from _common/combat/TUNING.lua, AUTO_ABILITIES.lua and the war_ keys of
      BUFF_CONFIG.lua, with the values the character had. TUNING.lua and
      AUTO_ABILITIES.lua are then removed.
    _common/ gets three folders more, and its files are all named _CONFIG now:
        combat/  BUFF_CONFIG  RECAST_CONFIG  CLEANSE_CONFIG  AUTO_MEDICINE_CONFIG (was AUTOCURE_CONFIG)
                 SUBJOB_CONFIG (new: waltz tiers, stratagem recharge)
        gear/    WEAPON_CONFIG  DW_CONFIG  ELEMENTAL_BELT_CONFIG  HP_PRIORITY_CONFIG
        travel/  STEALTH_CONFIG  WARP_CONFIG (new: the warp rings' margin)
        tools/   FIGHTS_CONFIG  SORTIE_CONFIG  ADDONS_CONFIG
    combat_mode.lua and treasure_mode.lua (the game writes them) go from _common/keys/ to saved/.

Usage (from the data folder):
    python migrate_config.py <Character>            do it
    python migrate_config.py <Character> --dry-run  only show what would change
    python migrate_config.py --templates            write the job templates of _master/config/

A copy of everything touched is made first in data/_backups/<Character>_config_<date>/.
Nothing is overwritten: a file whose new place is taken is left where it is and listed.
The shared code reads the places and names of before too (char_paths.lua, job_config.lua),
so a folder that was not tidied keeps working. Needs lua5.1 (or lua) on the PATH to read
the character's own values.

@author ejouanchicot
@date   Created: 2026-10-10
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
RULE = '---' + '=' * 76

# Common files: new place in _common/ and the name they had (None: unchanged)
MOVES = {
    'combat/AUTOCURE_CONFIG.lua': 'combat/AUTO_MEDICINE_CONFIG.lua',
    'combat/WEAPON_CONFIG.lua': 'gear/WEAPON_CONFIG.lua',
    'combat/DW_CONFIG.lua': 'gear/DW_CONFIG.lua',
    'combat/ELEMENTAL_BELT.lua': 'gear/ELEMENTAL_BELT_CONFIG.lua',
    'combat/HP_PRIORITY.lua': 'gear/HP_PRIORITY_CONFIG.lua',
    'combat/STEALTH_CONFIG.lua': 'travel/STEALTH_CONFIG.lua',
    'combat/FIGHTS_CONFIG.lua': 'tools/FIGHTS_CONFIG.lua',
    'combat/SORTIE_CONFIG.lua': 'tools/SORTIE_CONFIG.lua',
    'display/ADDONS_CONFIG.lua': 'tools/ADDONS_CONFIG.lua',
}
SAVED = ['combat_mode.lua', 'treasure_mode.lua']

# Each job's own settings: (key, old file, old key, key inside it or None, default, comment)
JOBS = {
    'SAM': [
        ('auto_hasso', 'AUTO_ABILITIES', 'sam_hasso', None, False,
         'Your chosen stance (Hasso, or Seigan after //gs c seigan) when you engage,\nunless Hasso or Seigan is up'),
        ('auto_third_eye_ws', 'AUTO_ABILITIES', 'sam_third_eye_ws', None, True, 'Third Eye before a weaponskill'),
        ('idle_hp', 'TUNING', 'sam_idle_hp', None, {'weak_below': 50, 'regen_below': 80},
         'Idle: sets.idle.Weak under this HP %, else sets.idle.Regen under that one'),
    ],
    'GEO': [
        ('auto_entrust', 'AUTO_ABILITIES', 'geo_entrust', None, False, 'An Indi- cast on a party member gets Entrust first'),
        ('auto_full_circle', 'AUTO_ABILITIES', 'geo_full_circle', None, False,
         'A Geo- cast while a luopan is out gets Full Circle first'),
        ('escort_indi', 'TUNING', 'geo_escort_indi', None, 'Indi-Regen', '//gs c escort with no Indi- named'),
    ],
    'BLU': [
        ('auto_unbridled', 'AUTO_ABILITIES', 'blu_unbridled', None, False,
         'An unbridled spell cast without Unbridled Learning / Wisdom gets Unbridled\nLearning first, then goes again'),
        ('expiacion_window', 'AUTO_ABILITIES', 'blu_expiacion_window', None, False,
         'With Tizona, no Aftermath: Lv.3 and under 3000 TP, Expiacion is cancelled\nonce; pressed again within 3 s, it goes'),
    ],
    'PLD': [
        ('auto_divine_emblem', 'AUTO_ABILITIES', 'pld_divine_emblem', None, True, 'Divine Emblem before Flash'),
        ('auto_majesty', 'AUTO_ABILITIES', 'pld_majesty', None, True, 'Majesty before Protect / Cure'),
    ],
    'BLM': [
        ('auto_dark_arts', 'AUTO_ABILITIES', 'blm_dark_arts', None, True, 'With a SCH subjob: Dark Arts before a nuke'),
        ('auto_klimaform', 'AUTO_ABILITIES', 'blm_klimaform', None, True,
         'With a SCH subjob: Klimaform before a storm (//gs c storm)'),
    ],
    'DNC': [
        ('auto_presto', 'AUTO_ABILITIES', 'dnc_presto', None, True, 'Presto before a step (//gs c step)'),
    ],
    'WAR': [
        ('retaliation_cancel', 'AUTO_ABILITIES', 'war_retaliation_cancel', None, True,
         'Retaliation cancelled after 5 s of running'),
        ('berserk', 'BUFF_CONFIG', 'war_berserk', None, ['Berserk', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'],
         '//gs c berserk: what it uses, in order (a name removed is no longer used;\nWarcry: Blood Rage instead while Warcry is on cooldown)'),
        ('defender', 'BUFF_CONFIG', 'war_defender', None, ['Defender', 'Aggressor', 'Retaliation', 'Restraint', 'Warcry'],
         '//gs c defender: the same with Defender'),
        ('add_sam', 'BUFF_CONFIG', 'war_add_sam', None, True,
         'With a SAM subjob: add the stance (Hasso with berserk, Seigan with defender)\nand Third Eye to those two commands'),
    ],
    'COR': [
        ('refresh_mp_below', 'TUNING', 'refresh_mp_below', 'COR', 50, 'Idle: sets.idle.Refresh under this MP %'),
    ],
    'WHM': [
        ('refresh_mp_below', 'TUNING', 'refresh_mp_below', 'WHM', 51, 'Idle: sets.latent_refresh under this MP %'),
    ],
    'SMN': [
        ('skillup', 'TUNING', 'smn_skillup', None, {'avatar': 'Siren', 'release_after': 5.0},
         '//gs c skillup: the avatar summoned, and the seconds before the Release\n(summon cast time + a margin)'),
    ],
}
BRD = [
    ('DEBUFF_SONGS', 'TUNING', 'brd_debuff_songs', None,
     {'lullaby': 'Horde Lullaby', 'lullaby2': 'Foe Lullaby II', 'elegy': 'Carnage Elegy', 'requiem': 'Foe Requiem VII'},
     'The spell of each debuff command (//gs c lullaby, lullaby2, elegy, requiem)'),
    ('REFRESH_BELOW', 'TUNING', 'brd_songs_refresh_below', None, 180,
     '//gs c songs sends nothing (no Nightingale, no song) while every song of the\npack is yours with more than this many seconds left; 0: always sing.\n//gs c songs force sings once anyway'),
]
COMMON_NEW = {
    'combat/SUBJOB_CONFIG.lua': ('Subjob - what a subjob brings to any job', [
        ('waltz_from', 'TUNING', 'waltz_from', None,
         {'Curing Waltz II': 200, 'Curing Waltz III': 600, 'Curing Waltz IV': 1100, 'Curing Waltz V': 1500},
         'Curing Waltz tier from the missing HP of the target (main DNC or /DNC):\neach tier starts at this many HP missing'),
        ('stratagem_full_recharge', 'TUNING', 'stratagem_full_recharge', None, 240,
         'Stratagems (main SCH or /SCH): seconds for the whole pool to come back (the\ncharges shown are read from it; lower with the job-point gift)'),
    ]),
    'travel/WARP_CONFIG.lua': ('Warp - the warp and teleport rings (//gs c warp...)', [
        ('ring_safety', 'TUNING', 'warp_ring_safety', None, 3.5,
         "Seconds held once the ring reads ready, before it is used. The ring's own\nwait after it is equipped is the game's and cannot be shortened; lower this\nmargin if your connection is good, raise it if the ring is used too early"),
    ]),
}
TITLES = {'SAM': 'Samurai', 'GEO': 'Geomancer', 'BLU': 'Blue Mage', 'PLD': 'Paladin', 'BLM': 'Black Mage', 'DNC': 'Dancer',
          'WAR': 'Warrior', 'COR': 'Corsair', 'WHM': 'White Mage', 'SMN': 'Summoner'}


# ---------------------------------------------------------------------------------------------
# Lua values
# ---------------------------------------------------------------------------------------------
def lua(value):
    """A Python value as a Lua literal, on one line."""
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, str):
        return "'" + value.replace('\\', '\\\\').replace("'", "\\'") + "'"
    if isinstance(value, list):
        return '{' + ', '.join(lua(v) for v in value) + '}'
    if isinstance(value, dict):
        def key(k):
            return k if re.match(r'^[A-Za-z_]\w*$', k) else '[' + lua(k) + ']'
        return '{' + ', '.join('%s = %s' % (key(k), lua(v)) for k, v in value.items()) + '}'
    raise TypeError(value)


DUMP = r'''
local function esc(s) return (s:gsub('[%c"\\]', function(c) return string.format('\\u%04x', c:byte()) end)) end
local function dump(v)
    local t = type(v)
    if t == 'table' then
        local n, parts = 0, {}
        for _ in pairs(v) do n = n + 1 end
        if n > 0 and #v == n then
            for i = 1, n do parts[i] = dump(v[i]) end
            return '[' .. table.concat(parts, ',') .. ']'
        end
        for k, x in pairs(v) do parts[#parts + 1] = '"' .. esc(tostring(k)) .. '":' .. dump(x) end
        return '{' .. table.concat(parts, ',') .. '}'
    elseif t == 'string' then return '"' .. esc(v) .. '"'
    elseif t == 'number' or t == 'boolean' then return tostring(v)
    end
    return 'null'
end
local ok, value = pcall(dofile, arg[1])
io.write(dump(ok and type(value) == 'table' and value or {}))
'''


def read_lua(path):
    """The table a plain settings file returns, as Python data ({} when missing or unreadable)."""
    if not os.path.isfile(path):
        return {}
    exe = shutil.which('lua5.1') or shutil.which('lua')
    if not exe:
        sys.exit('lua5.1 (or lua) is needed on the PATH to read ' + path)
    with tempfile.NamedTemporaryFile('w', suffix='.lua', delete=False, encoding='utf-8') as handle:
        handle.write(DUMP)
    try:
        out = subprocess.run([exe, handle.name, path], capture_output=True, text=True, encoding='utf-8').stdout
    finally:
        os.unlink(handle.name)
    try:
        return json.loads(out or '{}')
    except ValueError:
        return {}


def value_of(old, entry):
    """The character's value of a setting (its default when the old files do not give one)."""
    key, old_file, old_key, inside, default, _ = entry
    value = old.get(old_file, {}).get(old_key)
    if inside is not None:
        value = value.get(inside) if isinstance(value, dict) else None
    if value is None or type(value) is not type(default) and not (isinstance(value, (int, float)) and isinstance(default, (int, float))):
        return default
    if isinstance(default, dict):
        return dict(default, **{k: v for k, v in value.items()})
    return value


# ---------------------------------------------------------------------------------------------
# File texts
# ---------------------------------------------------------------------------------------------
def entries_text(entries, old, indent='    ', assign='%s = %s,'):
    lines = []
    for entry in entries:
        for comment in entry[5].split('\n'):
            lines.append(indent + '-- ' + comment)
        lines.append(indent + assign % (entry[0], lua(value_of(old, entry))))
        lines.append('')
    return '\n'.join(lines[:-1])


def settings_file(title, where, entries, old):
    head = [RULE, '--- ' + title, RULE,
            '--- The values below are the defaults. Change what you want; a line removed',
            '--- (or commented out) goes back to its default, and in a table the keys you',
            '--- give are enough.',
            '---', '--- @file ' + where, '--- @author ejouanchicot', '--- @date Created: 2026-10-10', RULE, '']
    return '\n'.join(head) + '\nreturn {\n' + entries_text(entries, old) + '\n}\n'


def job_file(job, old):
    title = "%s - the job's own switches and thresholds" % TITLES[job]
    return settings_file(title, '%s/combat/%s_CONFIG.lua' % (job.lower(), job), JOBS[job], old)


def brd_block(old):
    rule = '---' + '=' * 76
    return ('\n'.join([rule, '--- DEBUFF COMMANDS AND //gs c songs', rule, '']) + '\n'
            + entries_text(BRD, old, indent='', assign='BRDSongConfig.%s = %s') + '\n\n')


# ---------------------------------------------------------------------------------------------
# One character
# ---------------------------------------------------------------------------------------------
class Tidy:
    def __init__(self, root, dry, fresh=False):
        # fresh: the folder was just built from the templates (a clone): a job file already there is the
        # template's, and is written again with the values of the old files an overlay brought
        self.root, self.dry, self.fresh, self.done, self.left = root, dry, fresh, [], []
        self.common = os.path.join(root, '_common')
        self.backup = None

    def path(self, *parts):
        return os.path.join(self.root, *parts)

    def keep(self, path):
        """A copy of a file about to change, in _backups/ (once)."""
        if self.dry or not os.path.isfile(path):
            return
        if not self.backup:
            name = '%s_config_%s' % (os.path.basename(self.root), time.strftime('%Y%m%d_%H%M%S'))
            self.backup = os.path.join(HERE, '_backups', name)
        target = os.path.join(self.backup, os.path.relpath(path, self.root))
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copy2(path, target)

    def write(self, path, text, what):
        rel = os.path.relpath(path, self.root).replace('\\', '/')
        if os.path.exists(path) and not self.fresh:
            self.left.append('%s is already there: not written again' % rel)
            return
        self.done.append('%s  %s' % (what, rel))
        if not self.dry:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, 'w', encoding='utf-8', newline='\n') as handle:
                handle.write(text)

    def move(self, src, dst):
        a, b = os.path.relpath(src, self.root).replace('\\', '/'), os.path.relpath(dst, self.root).replace('\\', '/')
        if not os.path.isfile(src):
            return
        if os.path.exists(dst):
            self.left.append('%s stays: %s is taken' % (a, b))
            return
        self.done.append('moved    %s -> %s' % (a, b))
        if self.dry:
            return
        self.keep(src)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        text = open(src, encoding='utf-8', newline='').read()
        # the header's own "@file" line follows the file
        text = text.replace(a.split('_common/')[-1], b.split('_common/')[-1]) if '_common/' in a and '_common/' in b else text
        with open(dst, 'w', encoding='utf-8', newline='') as handle:
            handle.write(text)
        os.remove(src)

    def remove(self, path, why):
        if not os.path.isfile(path):
            return
        self.done.append('removed  %s  (%s)' % (os.path.relpath(path, self.root).replace('\\', '/'), why))
        if not self.dry:
            self.keep(path)
            os.remove(path)

    def edit(self, path, change, what):
        if not os.path.isfile(path):
            return
        raw = open(path, encoding='utf-8', newline='').read()
        newline = '\r\n' if '\r\n' in raw else '\n'
        new = change(raw.replace('\r\n', '\n'))
        if new is None or new == raw.replace('\r\n', '\n'):
            return
        self.done.append('%s  %s' % (what, os.path.relpath(path, self.root).replace('\\', '/')))
        if not self.dry:
            self.keep(path)
            with open(path, 'w', encoding='utf-8', newline='') as handle:
                handle.write(new.replace('\n', newline))

    def run(self):
        if not os.path.isdir(self.common):
            sys.exit('%s has no _common/ folder: run migrate_layout.py first' % self.root)
        self.fresh = self.fresh and any(os.path.isfile(os.path.join(self.common, 'combat', name + '.lua'))
                                        for name in ('TUNING', 'AUTO_ABILITIES'))
        old = {name: read_lua(os.path.join(self.common, 'combat', name + '.lua'))
               for name in ('TUNING', 'AUTO_ABILITIES', 'BUFF_CONFIG')}
        for job in JOBS:
            if os.path.isdir(self.path(job.lower())):
                self.write(self.path(job.lower(), 'combat', job + '_CONFIG.lua'), job_file(job, old), 'new     ')
        self.edit(self.path('brd', 'combat', 'BRD_SONG_CONFIG.lua'), lambda text: brd_into(text, old), 'added to')
        for rel, (title, entries) in COMMON_NEW.items():
            self.write(os.path.join(self.common, rel), settings_file(title, '_common/' + rel, entries, old), 'new     ')
        self.edit(os.path.join(self.common, 'combat', 'BUFF_CONFIG.lua'), buff_without_war, 'war_ keys out of')
        for name in ('TUNING', 'AUTO_ABILITIES'):
            self.remove(os.path.join(self.common, 'combat', name + '.lua'), 'its settings are in the job files now')
        for src, dst in MOVES.items():
            self.move(os.path.join(self.common, src), os.path.join(self.common, dst))
        for name in SAVED:
            self.move(os.path.join(self.common, 'keys', name), self.path('saved', name))
        return self


def brd_into(text, old):
    if 'BRDSongConfig.DEBUFF_SONGS' in text or 'return BRDSongConfig' not in text:
        return None
    at = text.rindex('return BRDSongConfig')
    return text[:at] + brd_block(old) + text[at:]


def buff_without_war(text):
    """BUFF_CONFIG.lua without its three war_ keys and the comment lines right above each."""
    lines, out = text.split('\n'), []
    for line in lines:
        if re.match(r'^\s*war_(berserk|defender|add_sam)\s*=', line):
            while out and out[-1].strip().startswith('--') and not out[-1].startswith('---'):
                out.pop()
            while out and out[-1].strip() == '' and len(out) > 1 and out[-2].strip() == '':
                out.pop()
            continue
        out.append(line)
    new = '\n'.join(out)
    new = new.replace("--- Buffs - what //gs c buff (and WAR's berserk / defender) cast, in order", '--- Buffs - what //gs c buff casts, in order')
    return new.replace('(pets), DNC (its dance and samba come first anyway), WAR (berserk /\n    -- defender below), BLU',
                       '(pets), DNC (its dance and samba come first anyway), WAR (its berserk /\n    -- defender chains: war/combat/WAR_CONFIG.lua), BLU')


def templates():
    """The job templates of _master/config/, the two new common ones, and BRD's block."""
    master = os.path.join(HERE, '_master')
    for job in JOBS:
        path = os.path.join(master, 'config', job.lower(), job + '_CONFIG.lua')
        with open(path, 'w', encoding='utf-8', newline='\n') as handle:
            handle.write(job_file(job, {}))
        print('written', os.path.relpath(path, HERE))
    for rel, (title, entries) in COMMON_NEW.items():
        path = os.path.join(master, 'config_global', os.path.basename(rel))
        with open(path, 'w', encoding='utf-8', newline='\n') as handle:
            handle.write(settings_file(title, '_common/' + rel, entries, {}))
        print('written', os.path.relpath(path, HERE))
    path = os.path.join(master, 'config', 'brd', 'BRD_SONG_CONFIG.lua')
    raw = open(path, encoding='utf-8', newline='').read()
    new = brd_into(raw.replace('\r\n', '\n'), {})
    if new:
        with open(path, 'w', encoding='utf-8', newline='') as handle:
            handle.write(new.replace('\n', '\r\n' if '\r\n' in raw else '\n'))
        print('added to', os.path.relpath(path, HERE))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if '--templates' in sys.argv:
        return templates()
    if len(args) != 1:
        sys.exit(__doc__)
    root = os.path.join(HERE, args[0])
    if not os.path.isdir(root):
        sys.exit('No folder ' + root)
    tidy = Tidy(root, '--dry-run' in sys.argv).run()
    for line in tidy.done:
        print(line)
    for line in tidy.left:
        print('LEFT:', line)
    if not tidy.dry:
        try:
            import where_is_what
            where_is_what.write(os.path.basename(root))
        except Exception as error:   # the index is a help, not a step that may stop the tidy-up
            print('_WHERE-IS-WHAT.txt not written again:', error)
    print('%s%d change(s)%s' % ('DRY RUN: ' if tidy.dry else '', len(tidy.done),
                                '' if tidy.dry or not tidy.backup else ', copy of the files of before in ' + os.path.relpath(tidy.backup, HERE)))


if __name__ == '__main__':
    main()
