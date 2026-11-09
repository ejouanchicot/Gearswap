"""Build the Alluvion Skirmish armour table: gear/skirmish.js.

Source: skirmish_source.json (BG-Wiki "Category:Alluvion Skirmish Armor", given by the player on 2026-11-09): the five
sets (Yorium, Acro, Taeon, Telchine, Helios), their pieces and the augments each stone (Snow, Leaf, Dusk) can give. A
piece carries one augment of each stone at most. An augment's "max" is the highest value it can reach whatever the
stone's quality (NQ, +1, +2: the quality only makes a high value likelier), so every augment is written at its max.
The Snow +2 exclusions are kept in the data but not applied: the project does not deal with a stone's quality, and a
stat a +2 stone cannot give is still reached at the same max with the NQ or +1 stone.

Every augment is written as the game shows it: the labels of Windower's libs/extdata.lua augment_values (system 1),
the value formatted as extdata does (label, then +N or -N, then % for a percent augment). Then every line must be read
by the optimizer's augment reader (augments_parse.js) as its stats at that value: skirmish_check.js, run at the end.

    python skirmish_build.py
"""
import json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))

# The source's stat -> the extdata labels it is made of (one per stat of the augment), and whether extdata writes it
# in percent. The value and sign are the source's.
P = True
LABELS = {
    'HP': [('HP', 0)], 'MP': [('MP', 0)],
    'STR': [('STR', 0)], 'DEX': [('DEX', 0)], 'VIT': [('VIT', 0)], 'AGI': [('AGI', 0)],
    'INT': [('INT', 0)], 'MND': [('MND', 0)], 'CHR': [('CHR', 0)],
    'STR and DEX': [('STR', 0), ('DEX', 0)], 'STR and VIT': [('STR', 0), ('VIT', 0)],
    'STR and AGI': [('STR', 0), ('AGI', 0)], 'STR and INT': [('STR', 0), ('INT', 0)],
    'STR and MND': [('STR', 0), ('MND', 0)], 'STR and CHR': [('STR', 0), ('CHR', 0)],
    'INT and MND': [('INT', 0), ('MND', 0)], 'MND and CHR': [('MND', 0), ('CHR', 0)],
    'Accuracy': [('Accuracy', 0)], 'Attack': [('Attack', 0)],
    'Accuracy and Attack': [('Accuracy', 0), ('Attack', 0)],
    'Ranged Accuracy': [('Rng.Acc.', 0)], 'Ranged Attack': [('Rng.Atk.', 0)],
    'Ranged Accuracy and Ranged Attack': [('Rng.Acc.', 0), ('Rng.Atk.', 0)],
    'Magic Accuracy': [('Mag. Acc.', 0)], 'Magic Attack Bonus': [('"Mag.Atk.Bns."', 0)],
    'Magic Accuracy and Magic Attack Bonus': [('Mag. Acc.', 0), ('"Mag.Atk.Bns."', 0)],
    'Defense': [('DEF', 0)], 'Evasion': [('Evasion', 0)], 'Magic Evasion': [('Mag. Evasion', 0)],
    'Enmity': [('Enmity', 0)],
    'Store TP': [('"Store TP"', 0)], 'Double Attack': [('"Dbl.Atk."', 0)], 'Triple Attack': [('"Triple Atk."', 0)],
    'Subtle Blow': [('"Subtle Blow"', 0)], 'Haste': [('Haste', 0)], 'Dual Wield': [('"Dual Wield"', 0)],
    'Counter': [('"Counter"', 0)], 'Critical Hit Rate': [('Crit.hit rate', 0)],
    'Critical Hit Damage': [('Crit. hit damage ', P)], 'Weapon Skill Damage': [('Weapon skill damage ', P)],
    'Weapon Skill Accuracy': [('Weapon Skill Acc.', 0)], 'Skillchain Damage': [('Sklchn.dmg.', P)],
    'Snapshot': [('"Snapshot"', 0)], 'Rapid Shot': [('"Rapid Shot"', 0)], 'Recycle': [('"Recycle"', 0)],
    'Waltz Potency': [('"Waltz" potency ', P)], 'Enemy Critical Hit Rate': [('Enemy crit. hit rate ', 0)],
    'Regen': [('"Regen"', 0)], 'Regen Potency': [('"Regen" potency', 0)],
    'Physical Damage Taken': [('Phys. dmg. taken ', P)], 'Magic Damage Taken': [('Magic dmg. taken ', P)],
    'Breath Damage Taken': [('Breath dmg. taken ', P)], 'Damage Taken': [('Damage taken', P)],
    'Fast Cast': [('"Fast Cast"', 0)], 'Conserve MP': [('"Conserve MP"', 0)],
    'Cure Potency': [('"Cure" potency ', P)], 'Cure Potency Received': [('Potency of "Cure" effect received', P)],
    'Cure Spellcasting Time': [('"Cure" spellcasting time ', P)],
    'Song Spellcasting Time': [('Song spellcasting time ', P)],
    'Spell Interruption Rate': [('Spell interruption rate down ', P)],
    'Enhancing Magic Duration': [('Enh. Mag. eff. dur. ', 0)], 'Phalanx Received': [('Phalanx ', 0)],
    'Magic Burst Damage': [('Magic burst dmg.', P)], 'Magic Critical Hit Rate': [('Magic crit. hit rate ', 0)],
    'Magic Critical Hit Damage': [('Mag. crit. hit dmg. ', P)], 'Occult Acumen': [('"Occult Acumen"', 0)],
    'Drain and Aspir Potency': [('"Drain" and "Aspir" potency ', 0)],
    'Summoning Magic Skill': [('Summoning magic skill ', 0)], 'Blood Boon': [('"Blood Boon"', 0)],
    'Blood Pact Ability Delay': [('"Blood Pact" ability delay ', 0)], 'Blood Pact Damage': [('Blood Pact Dmg.', 0)],
    'Avatar Perpetuation Cost': [('"Avatar perpetuation cost" ', 0)], 'Elemental Siphon': [('"Elemental Siphon"', 0)],
    'Call Beast Ability Delay': [('"Call Beast" ability delay ', 0)], 'Repair Potency': [('"Repair" potency ', P)],
    'Pet: Accuracy and Pet: Ranged Accuracy': [('Pet: Accuracy', 0), ('Pet: Rng. Acc.', 0)],
    'Pet: Attack and Pet: Ranged Attack': [('Pet: Attack', 0), ('Pet: Rng.Atk.', 0)],
    'Pet: Magic Accuracy': [('Pet: Mag. Acc.', 0)], 'Pet: Magic Attack Bonus': [('Pet: "Mag.Atk.Bns."', 0)],
    'Pet: Defense': [('Pet: DEF', 0)], 'Pet: Evasion': [('Pet: Evasion', 0)], 'Pet: Magic Evasion': [('Pet: Mag. Evasion', 0)],
    'Pet: Regen': [('Pet: "Regen"', 0)], 'Pet: Subtle Blow': [('Pet: "Subtle Blow"', 0)], 'Pet: Breath': [('Pet: Breath', 0)],
    'Pet: Double Attack': [('Pet: "Dbl. Atk."', 0)], 'Pet: Haste': [('Pet: Haste', 0)],
    'Pet: Damage Taken': [('Pet: Damage taken ', P)], 'Pet: Critical Hit Rate': [('Pet: Crit.hit rate ', 0)],
    'Pet: Enmity': [('Pet: Enmity', 0)], 'Pet: Store TP': [('Pet: "Store TP"', 0)],
}
STONES = ['Snow', 'Leaf', 'Dusk']


def game_text(a):
    """One augment at its max, as extdata.lua writes it: each label, then +N / -N, then % when in percent."""
    if a['stat'] not in LABELS:
        sys.exit('no game label for the augment "%s"' % a['stat'])
    v = a['max'] if a['sign'] == '+' else -a['max']
    return ' '.join(lab + ('+%d' % v if v > 0 else '%d' % v) + ('%' if pct else '') for lab, pct in LABELS[a['stat']])


def main():
    src = json.load(open(os.path.join(HERE, 'skirmish_source.json'), encoding='utf-8'))
    items = json.load(open(os.path.join(HERE, 'items.json'), encoding='utf-8'))['items']
    by_long = {}
    for it in items:
        by_long.setdefault(it['name'].lower(), it['name'])
        by_long.setdefault((it.get('enl') or '').lower(), it['name'])
    sets, check = {}, []
    for name, s in src['sets'].items():
        augs, inferred = {}, []
        for stone in STONES:
            seen = []
            for sub, rows in s['augments'][stone].items():
                for a in rows:
                    txt = game_text(a)
                    if txt not in seen:
                        seen.append(txt)
                        check.append({'text': txt, 'value': a['max'], 'parts': len(LABELS[a['stat']]), 'stat': a['stat']})
                    if a.get('column_inferred') and txt not in inferred:
                        inferred.append(txt)
            augs[stone] = seen
        pieces = []
        for p in s['pieces']:
            game = by_long.get(p['name'].lower())
            if not game:
                sys.exit('the piece "%s" is not in the catalogue' % p['name'])
            pieces.append({'name': game, 'long': p['name'], 'slot': p['slot'].lower()})
        sets[name] = {'jobs': [j.lower() for j in s['jobs']], 'pieces': pieces, 'augs': augs, 'inferred': inferred}
    data = {'stones': STONES, 'sets': sets, 'snow_plus2_exclusions': src['_meta'].get('snow_plus2_exclusions', {})}
    js = ('// Generated by atelier/gear/skirmish_build.py from skirmish_source.json. Do not edit.\n'
          '// FFXI.SKIRMISH_SETS[set] = {jobs, pieces: [{name, long, slot}], augs: {Snow, Leaf, Dusk: [augment at its max, as\n'
          '// the game writes it]}, inferred: [augments the source placed by deduction]}; FFXI.SKIRMISH_BY_NAME[piece name] =\n'
          '// set name; FFXI.skirmish_max(name, augs): a copy with each of its augments at its max.\n'
          '// @author ejouanchicot\n'
          '(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {\n'
          '    var DATA = ' + json.dumps(data, ensure_ascii=False, separators=(',', ':')) + ';\n'
          + open(os.path.join(HERE, 'skirmish_tail.js'), encoding='utf-8').read() + '});\n')
    open(os.path.join(HERE, 'skirmish.js'), 'w', encoding='utf-8', newline='\n').write(js)
    os.makedirs(os.path.join(HERE, 'cache'), exist_ok=True)
    json.dump(check, open(os.path.join(HERE, 'cache', 'skirmish_check.json'), 'w', encoding='utf-8'), ensure_ascii=False)
    n = sum(len(v) for s in sets.values() for v in s['augs'].values())
    print('skirmish.js: %d sets, %d augments' % (len(sets), n))
    r = subprocess.run(['node', os.path.join(HERE, 'skirmish_check.js')])
    sys.exit(r.returncode)


if __name__ == '__main__':
    main()
