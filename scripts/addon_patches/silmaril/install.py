"""Put the local additions back into the multi-box automation addon (after an addon update, or the first time).

    python scripts/addon_patches/silmaril/install.py            install
    python scripts/addon_patches/silmaril/install.py --check    say what is missing, change nothing

Each addition is one file copied into the addon's lib/ and one `require` line at the end of the addon's main
file. Nothing of the addon's own code is changed, so an update only removes them: run this again, then
`//lua r silmaril` on every character. Safe to run twice.

It refuses to install an addition whose hooks the addon no longer has (a function renamed by an update): the
addition would then break the addon at load.
"""
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDON = HERE.parents[4] / 'Silmaril'

# file -> (comment of its require line, the addon's functions it relies on: (lib file, text that must be there))
ADDITIONS = {
    'StateReport': ("reports this box's state to GearSwap", [
        ('Moving.lua', 'function get_following()'),
        ('Moving.lua', 'function get_fast_follow_target()'),
    ]),
    'CastHold': ('no movement while a spell is cast', [
        ('Moving.lua', 'function movement()'),
        ('Input.lua', 'function input_message(type, index, param, option, option2)'),
        ('Input.lua', 'type == "Magic"'),
        ('Windower.lua', 'function player_run(value)'),
        ('Engine.lua', 'movement()'),
    ]),
}


def missing_hooks(hooks):
    out = []
    for lib, text in hooks:
        path = ADDON / 'lib' / lib
        if not path.is_file() or text not in path.read_text(encoding='utf-8', errors='replace'):
            out.append('%s: %s' % (lib, text))
    return out


def main(check):
    main_file = ADDON / 'Silmaril.lua'
    if not main_file.is_file():
        raise SystemExit('addon not found: %s' % ADDON)
    done = 0
    for name, (comment, hooks) in ADDITIONS.items():
        source, target = HERE / (name + '.lua'), ADDON / 'lib' / (name + '.lua')
        require = "require 'lib./%s'" % name
        text = main_file.read_bytes()
        has_file = target.is_file() and target.read_bytes() == source.read_bytes()
        has_line = require.encode() in text
        if has_file and has_line:
            print('%-12s in place' % name)
            continue
        gone = missing_hooks(hooks)
        if gone:
            print('%-12s NOT installed, the addon no longer has:' % name)
            for line in gone:
                print('               ' + line)
            continue
        what = ', '.join(w for w, ok in (('file', has_file), ('require line', has_line)) if not ok)
        if check:
            print('%-12s missing: %s' % (name, what))
            continue
        if not has_file:
            shutil.copyfile(source, target)
        if not has_line:
            eol = b'\r\n' if b'\r\n' in text else b'\n'
            if not text.endswith(eol):
                text += eol
            text += eol + ('-- Local addition: %s (see lib/%s.lua)' % (comment, name)).encode() + eol
            text += require.encode() + eol
            main_file.write_bytes(text)
        print('%-12s installed (%s)' % (name, what))
        done += 1
    if done:
        print('now: //lua r silmaril on every character')


if __name__ == '__main__':
    main('--check' in sys.argv[1:])
