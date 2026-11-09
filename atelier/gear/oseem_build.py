"""Build the Oseem (Reisenjima) pieces table: gear/oseem.js.

Source: oseem_source.json (BG-Wiki "Arcane Glyptics Inscription", given by the player on 2026-11-09): the five armour
sets (Chironic, Herculean, Merlinic, Odyssean, Valorous) and the Escha weapons, each augment by path, its range and the
cap a stone raises it to. The player's choices (notes/docs-perso/oseem-augments-2026-11-09/SPEC.md): a piece is built
with every slot at its cap, stones included, and the Dark Matter stats are used.

A piece is built a path at a time, each slot a group of options (atelier/opt_ambu.js oseemBuilds):
    armour  acc    slot 1: one Accuracy / Attack stat of the path at 30 (25 off-path), or the pair at 25 each
            special slot 2: each special stat of the path at its cap (Fern's when it has one)
            base   slot 3: each base stat at its cap (Taupe's: 15)
            acc2   slot 4: the path's Accuracy +15, or one Dark Matter stat (one a piece, on any piece: the source)
            atk2   slot 5: the path's Attack +15
            Slot 1 + slot 4 (or 5) never past 40 of one stat: a slot 1 at 30 rules out the +15 of the same stat
            (excl); a Dark Matter stat the piece has in another slot is ruled out too (one line a stat). The path's +15 is the player's pieces' (Mag. Acc. on a magic path), the source names Accuracy
            only; a Familiar path has none (no piece shows it).
    weapon  special, base (or HP / MP), acc, atk, dmg: each stat at the higher of its max and its stone's cap.
A stat the source gives no max for is left out; a weapon whose table is a placeholder is left out.

Every augment is written as the game shows it (augment_labels.py), then read back by the optimizer's reader:
oseem_check.js, run at the end.

    python oseem_build.py
"""
import json, os, re, subprocess, sys

from augment_labels import LABELS, game_text

HERE = os.path.dirname(os.path.abspath(__file__))

BASE = {'STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR'} | {'Pet: ' + s for s in ('STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR')}
ACC = {'Accuracy', 'Ranged Accuracy', 'Magic Accuracy', 'Pet: Accuracy and Pet: Ranged Accuracy',
       'Pet: Accuracy & Ranged Accuracy', 'Pet: Magic Accuracy'}
ATK = {'Attack', 'Ranged Attack', 'Magic Attack Bonus', 'Pet: Attack and Pet: Ranged Attack', 'Pet: Attack & Ranged Attack',
       'Pet: Magic Attack Bonus', 'Pet: Magic Accuracy and Pet: Magic Attack Bonus'}
PAIRS = [('Accuracy', 'Attack'), ('Ranged Accuracy', 'Ranged Attack'), ('Magic Accuracy', 'Magic Attack Bonus')]
# a reduction the source sometimes writes with a + (or a Conserve MP with a -): the game's sign
MINUS = {'Physical Damage Taken', 'Physical damage taken', 'Magic Damage Taken', 'Damage Taken', 'Pet: Damage Taken',
         'Pet: Physical Damage Taken', 'Spell Interruption Rate Down', 'Cure Spellcasting Time', 'Cure spellcasting time',
         'Avatar Perpetuation Cost', 'Blood Pact Ability Delay'}
PLUS = {'Conserve MP'}
# the path's Accuracy / Attack of slots 4 and 5
SLOT45 = {'Melee': ('Accuracy', 'Attack'), 'Ranged': ('Ranged Accuracy', 'Ranged Attack'),
          'Magic': ('Magic Accuracy', 'Magic Attack Bonus'), 'Healing': ('Magic Accuracy', 'Magic Attack Bonus')}


# every line written: its value and how many stats it holds, for oseem_check.js
WRITTEN = {}


def text(stat, value, sign='+'):
    if stat in MINUS:
        sign = '-'
    elif stat in PLUS:
        sign = '+'
    t = game_text({'stat': stat, 'max': value, 'sign': sign})
    WRITTEN[t] = {'text': t, 'value': value, 'parts': len(LABELS[stat]), 'stat': stat}
    return t


def shape(t):
    """An augment with its values taken out (FFXI.augShape, skirmish_tail.js): the same stat at another value"""
    return ' '.join(re.sub(r'[+-]\s?\d+', '#', t).split())


def cap_of(v):
    """The highest value the stat reaches: its max, or the cap a stone raises it to."""
    caps = [c for c in [v.get('max')] + list((v.get('stone_caps') or {}).values()) if isinstance(c, (int, float))]
    return int(max(caps)) if caps else None


def stats_of(item, path):
    for a in item['augments']:
        v = a['by_path'].get(path)
        if v and cap_of(v):
            yield a['stat'], v


def armour_path(item, path, dark):
    groups = {'acc': [], 'special': [], 'base': [], 'acc2': [], 'atk2': []}
    on = {}
    for stat, v in stats_of(item, path):
        cap = cap_of(v)
        if stat in BASE:
            groups['base'].append(text(stat, cap, v['sign']))
        elif (stat in ACC or stat in ATK) and not (v.get('stone_caps') or {}).get('Fern'):
            on[stat] = v.get('on_path') is not False
            groups['acc'].append(text(stat, min(cap, 30 if on[stat] else 25)))
        else:
            groups['special'].append(text(stat, cap, v['sign']))
    for a, b in PAIRS:
        if on.get(a) and on.get(b):
            pair = text(a, 25) + ' ' + text(b, 25)
            WRITTEN[pair] = {'text': pair, 'value': 25, 'parts': len(LABELS[a]) + len(LABELS[b]), 'stat': a + ' + ' + b}
            groups['acc'].append(pair)
    excl = []
    if path in SLOT45:
        acc, atk = SLOT45[path]
        groups['acc2'].append(text(acc, 15))
        groups['atk2'].append(text(atk, 15))
        for stat, extra in ((acc, text(acc, 15)), (atk, text(atk, 15))):
            if stat in on and on[stat]:
                excl.append([text(stat, 30), extra])
    groups['acc2'] += dark
    # one line a stat: a Dark Matter stat the piece has a slot of already ("Weapon skill damage +10%" beside the special
    # slot's +5%) is never added to it. No piece of the players shows a stat twice; the source does not say it can be
    for d in dark:
        excl += [[t, d] for g in ('special', 'base', 'acc') for t in groups[g] if shape(t) == shape(d)]
    return {'groups': [g for g in groups if groups[g]], 'augs': {g: l for g, l in groups.items() if l}, 'excl': excl,
            'dt': dt_of(groups['special'])}


def dt_of(special):
    """The special slot's damage taken, kept in every build list (opt_ambu.js): the search weighs a piece without its
    set's floors (PDT, MDT), so a build with no damage taken would always lose to one with a stat more"""
    return [t for t in special if re.match(r'(Phys\. |Magic )?dmg\. taken|Damage taken', t)]


def weapon_path(item, path):
    groups = {'special': [], 'base': [], 'acc': [], 'atk': [], 'dmg': []}
    for stat, v in stats_of(item, path):
        g = ('dmg' if stat == 'DMG' else 'base' if stat in BASE or stat in ('HP', 'MP') else
             'acc' if stat in ACC else 'atk' if stat in ATK else 'special')
        groups[g].append(text(stat, cap_of(v), v['sign']))
    return {'groups': [g for g in groups if groups[g]], 'augs': {g: l for g, l in groups.items() if l}, 'excl': [],
            'dt': dt_of(groups['special'])}


def main():
    src = json.load(open(os.path.join(HERE, 'oseem_source.json'), encoding='utf-8'))
    items = json.load(open(os.path.join(HERE, 'items.json'), encoding='utf-8'))['items']
    # the source's name -> the game's (the catalogue's short name: "Odyss. Chestplate" for "Odyssean Chestplate")
    by_long = {}
    for it in items:
        by_long.setdefault(it['name'].lower(), it['name'])
        by_long.setdefault((it.get('enl') or '').lower(), it['name'])
    alias = {}
    dark = [text(d['stat'], d['max']) for d in src['_meta']['dark_matter']['stats_speciales_connues']]
    out, uncertain, skipped = {}, [], []

    def add(name, kind, paths):
        game = by_long.get(name.lower())
        if not game:
            sys.exit('the piece "%s" is not in the catalogue' % name)
        if game != name:
            alias[name] = game
        out[game] = {'kind': kind, 'paths': paths}

    for set_name, s in src['armor_sets'].items():
        paths = {p: armour_path(s, p, dark) for p in s['paths']}
        for piece in s['pieces']:
            add(piece['name'], set_name, paths)
        uncertain += ['%s %s %s' % (set_name, p, a['stat']) for a in s['augments'] for p, v in a['by_path'].items()
                      if v.get('uncertain') and cap_of(v)]
    for w_name, w in src['weapons'].items():
        paths = {p: weapon_path(w, p) for p in w['paths']}
        paths = {p: v for p, v in paths.items() if len(v['groups']) > 1}
        if not paths:
            skipped.append(w_name)
            continue
        add(w_name, 'weapon', paths)
        uncertain += ['%s %s %s' % (w_name, p, a['stat']) for a in w['augments'] for p, v in a['by_path'].items()
                      if (v.get('uncertain') or 'Question' in (v.get('raw') or '')) and cap_of(v)]

    check, seen = [], set()
    for name, o in out.items():
        for p in o['paths'].values():
            for g, lst in p['augs'].items():
                for t in lst:
                    if t not in seen:
                        seen.add(t)
                        check.append(WRITTEN[t])
    data = {'pieces': out, 'alias': alias, 'dark': dark, 'uncertain': uncertain, 'skipped': skipped}
    js = ('// Generated by atelier/gear/oseem_build.py from oseem_source.json. Do not edit.\n'
          '// FFXI.OSEEM_BY_NAME[piece name] = {kind: its set or "weapon", paths: {path: {groups: [slot groups], augs:\n'
          '// {group: [augments at their cap, as the game writes them]}, excl: [[slot 1 augment, slot 4/5 augment it rules\n'
          '// out]]}}}; FFXI.OSEEM_DARK: the Dark Matter stats; FFXI.oseem_max(name, augs): a piece with its augments at their cap.\n'
          '// Uncertain in the source, kept at their max: ' + '; '.join(uncertain) + '\n'
          '// Left out (no table in the source): ' + ', '.join(skipped) + '\n'
          '// @author ejouanchicot\n'
          '(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {\n'
          '    var DATA = ' + json.dumps(data, ensure_ascii=False, separators=(',', ':')) + ';\n'
          + open(os.path.join(HERE, 'oseem_tail.js'), encoding='utf-8').read() + '});\n')
    open(os.path.join(HERE, 'oseem.js'), 'w', encoding='utf-8', newline='\n').write(js)
    os.makedirs(os.path.join(HERE, 'cache'), exist_ok=True)
    json.dump(check, open(os.path.join(HERE, 'cache', 'oseem_check.json'), 'w', encoding='utf-8'), ensure_ascii=False)
    print('oseem.js: %d pieces, %d augment lines; left out: %s' % (len(out), len(check), ', '.join(skipped)))
    r = subprocess.run(['node', os.path.join(HERE, 'oseem_check.js')])
    sys.exit(r.returncode)


if __name__ == '__main__':
    main()
