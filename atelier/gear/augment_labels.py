"""The game's text of an augment at its max, for the tables the optimizer builds pieces from (skirmish_build.py,
reive_build.py): the labels of Windower's libs/extdata.lua augment_values (system 1), the value formatted as extdata
does (label, then +N or -N, then % for a percent augment).
"""
import sys

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
    # the Reive capes' (reive_build.py)
    'Healing Magic Skill': [('Healing magic skill ', 0)], 'Enhancing Magic Skill': [('Enha.mag. skill ', 0)],
    'Enfeebling Magic Skill': [('Enfb.mag. skill ', 0)], 'Elemental Magic Skill': [('Elem. magic skill ', 0)],
    'Dark Magic Skill': [('Dark magic skill ', 0)], 'Geomancy Skill': [('Geomancy Skill ', 0)],
    'Blue Magic Skill': [('Blue Magic skill ', 0)], 'Phalanx': [('Phalanx ', 0)],
    'Helix Duration': [('Helix eff. dur. ', 0)], 'Indi Duration': [('Indi. eff. dur. ', 0)],
    'Meditate Duration': [('Meditate eff. dur. ', 0)], 'Zanshin': [('"Zanshin"', 0)], 'Embolden': [('"Embolden"', 0)],
    'Reverse Flourish': [('"Rev. Flourish"', 0)], 'Martial Arts': [('"Martial Arts"', 0)],
    'Pet: TP Bonus': [('Pet: TP Bonus', 0)], 'Phantom Roll Delay': [('"Phantom Roll" ability delay ', 0)],
    'Blood Pact Recast Time II': [('Blood Pact ab. del. II ', 0)],
    # the Updraft Mantle's "Breath": the wyvern's, extdata's only Breath bonus (0x079)
    'Breath': [('Pet: Breath', 0)],
}


def game_text(a):
    """One augment at its max, as extdata.lua writes it: each label, then +N / -N, then % when in percent."""
    if a['stat'] not in LABELS:
        sys.exit('no game label for the augment "%s"' % a['stat'])
    v = a['max'] if a['sign'] == '+' else -a['max']
    return ' '.join(lab + ('+%d' % v if v > 0 else '%d' % v) + ('%' if pct else '') for lab, pct in LABELS[a['stat']])
