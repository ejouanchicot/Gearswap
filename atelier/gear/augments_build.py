"""Build the rank/path augment table: catalog/augments_ranked.json + .js.

Sources (cached in catalog/cache/, see AUGMENTS.md):
  - LandSandBoat scripts/data/augments.lua, xi.data.augments.bundles: bundle id ->
    effects with a value per rank 0..30 (parsed by augments_lsb_parse.py).
  - Windower res/items.lua: the 'en' short names the export uses.
  - The item -> bundle layout below, worked out from the bundle order and checked
    against BG Wiki rank tables (augments_check_bgwiki.js; a local tool compares with
    wsdist's gear.py, augments_check_gearpy.py, kept on this PC).
  - STAT_KEYS below: the stat names the catalogue uses (STAT_KEYS.md).
  - Unity +1 items: cache/unity_map.json, written by augments_unity_match.js
    (it reads the bundles from augments_ranked.json, so run the builder, the
    matcher, then the builder again; augments_all.cmd does it).

    python augments_build.py
"""
import json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from augments_effects import to_keys

ITEMS_LUA = r'D:\Windower Tetsouo\res\items.lua'

# --- Windower names ----------------------------------------------------------
_items = {}
for m in re.finditer(r'\[(\d+)\] = \{id=\d+,en="((?:[^"\\]|\\.)*)",ja="(?:[^"\\]|\\.)*",enl="((?:[^"\\]|\\.)*)"',
                     open(ITEMS_LUA, encoding='utf-8').read()):
    _items[int(m.group(1))] = (m.group(2), m.group(3))
_by_en = {}
_by_enl = {}
for iid, (en, enl) in _items.items():
    _by_en.setdefault(en.lower(), []).append(iid)
    _by_enl.setdefault(enl.lower(), []).append(iid)


def resolve(name):
    """Full or short item name -> (id, en, enl). Equipment ids (>= 10000) first."""
    k = name.lower()
    ids = _by_en.get(k) or _by_enl.get(k)
    if not ids:
        raise KeyError('unknown item name: ' + name)
    iid = max(ids) if any(i >= 10000 for i in ids) else ids[0]
    return (iid,) + _items[iid]


# --- Item -> bundle layout ---------------------------------------------------
SLOTS5 = ['head', 'body', 'hands', 'legs', 'feet']
ITEMS = []   # (name, kind, max_rank, {path: bundle})


def add(name, kind, max_rank, paths):
    ITEMS.append((name, kind, max_rank, paths))


def armor_set(names, kind, max_rank, first_by_path):
    for i, n in enumerate(names):
        add(n, kind, max_rank, {p: b + i for p, b in first_by_path.items()})


# Odyssey Sheol C (Atonement 3/4), 5 pieces head..feet per bundle run.
armor_set(['Nyame Helm', 'Nyame Mail', 'Nyame Gauntlets', 'Nyame Flanchard', 'Nyame Sollerets'],
          'odyssey', 30, {'A': 438, 'B': 443, 'C': 448, 'D': 453})
armor_set(["Ikenga's Hat", "Ikenga's Vest", "Ikenga's Gloves", "Ikenga's Trousers", "Ikenga's Clogs"],
          'odyssey', 30, {'A': 408})
armor_set(["Gleti's Mask", "Gleti's Cuirass", "Gleti's Gauntlets", "Gleti's Breeches", "Gleti's Boots"],
          'odyssey', 30, {'A': 413})
armor_set(["Sakpata's Helm", "Sakpata's Breastplate", "Sakpata's Gauntlets", "Sakpata's Cuisses",
           "Sakpata's Leggings"], 'odyssey', 30, {'A': 418})
armor_set(["Mpaca's Cap", "Mpaca's Doublet", "Mpaca's Gloves", "Mpaca's Hose", "Mpaca's Boots"],
          'odyssey', 30, {'A': 423})
armor_set(["Agwu's Cap", "Agwu's Robe", "Agwu's Gages", "Agwu's Slops", "Agwu's Pigaches"],
          'odyssey', 30, {'A': 428})
armor_set(["Bunzi's Hat", "Bunzi's Robe", "Bunzi's Gloves", "Bunzi's Pants", "Bunzi's Sabots"],
          'odyssey', 30, {'A': 433})
# Odyssey weapons, in skill order (H2H, dagger, sword, GS, axe, GA, scythe,
# polearm, katana, GK, club, staff, crossbow, bow).
for b, n in enumerate(["Sakpata's Fists", "Gleti's Knife", "Sakpata's Sword", "Agwu's Claymore",
                       "Ikenga's Axe", "Agwu's Axe", "Bunzi's Chopper", "Agwu's Scythe", "Ikenga's Lance",
                       "Kunimitsu", "Gekkei", "Bunzi's Rod", "Mpaca's Staff", "Gleti's Crossbow",
                       "Mpaca's Bow"], start=393):
    add(n, 'odyssey', 30, {'A': b})
# Odyssey Sheol A/B (Atonement 1/2) and the later single pieces.
for b, n in enumerate(['Hesperiidae', 'Coiste Bodhar', 'Epitaph', 'Neo Animator', 'Acrontica', 'Tsuru',
                       'Schere Earring', 'Beithir Ring', 'Tellen Belt', 'Obstinate Sash',
                       'Alabaster Earring', 'Murky Ring', 'Alabaster Mantle', 'Murky Mantle'], start=458):
    add(n, 'odyssey', 30, {'A': b})
# Limbus (Temenos/Apollyon) augmented sets, head..feet.
armor_set(['Revelation Masque', 'Revelation Platemail', 'Revelation Gauntlets', 'Revelation Brais',
           'Revelation Sabatons'], 'limbus', 30, {'A': 472})
armor_set(['Duty Crown', 'Duty Cyclas', 'Duty Gauntlets', 'Duty Flanchard', 'Duty Sollerets'],
          'limbus', 30, {'A': 477})
armor_set(['Indomitable Petasos', 'Indomitable Coat', 'Indomitable Gloves', 'Indomitable Tonban',
           'Indomitable Sabots'], 'limbus', 30, {'A': 482})
armor_set(['Sworn Crown', 'Sworn Platemail', 'Sworn Gauntlets', 'Sworn Brais', 'Sworn Sabatons'],
          'limbus', 30, {'A': 487})
armor_set(['Clemency Somen', 'Clemency Haramaki', 'Clemency Kote', 'Clemency Haidate', 'Clemency Sune-Ate'],
          'limbus', 30, {'A': 492})

# Dynamis-D JSE necks, one bundle per job (WAR..RUN order), shared by +1 (rank 20) and +2 (rank 25).
NECKS = ["warrior's bead necklace", "monk's nodowa", "cleric's torque", "sorcerer's stole", "duelist's torque",
         "assassin's gorget", "knight's bead necklace", "abyssal bead necklace", "beastmaster collar",
         "bard's charm", "scout's gorget", "samurai's nodowa", "ninja nodowa", "dragoon's collar",
         "summoner's collar", "mirage stole", "commodore charm", "puppetmaster's collar", "etoile gorget",
         "argute stole", "bagua charm", "futhark torque"]
for b, n in enumerate(NECKS, start=199):
    add(n + ' +1', 'jse_neck', 20, {'A': b})
    add(n + ' +2', 'jse_neck', 25, {'A': b})

# Dynamis-D weapons: 22 families in ascending item id order, 9 bundles each:
# NQ (Su4, rank 15) A/B/C, HQ1 (Su4, rank 20) A/B/C, HQ2 (Su5, rank 25) A/B/C.
DYNA_D_FIRST_IDS = [21521, 21524, 21573, 21576, 21579, 21582, 21625, 21628, 21631, 21667, 21715,
                    21772, 21823, 21876, 21915, 21968, 22033, 22036, 22091, 22094, 22097, 22147]
for f, first in enumerate(DYNA_D_FIRST_IDS):
    for tier, rank in enumerate((15, 20, 25)):
        b = 1 + 9 * f + 3 * tier
        add(_items[first + tier][0], 'dynamis_weapon', rank, {'A': b, 'B': b + 1, 'C': b + 2})

# Ultimate weapons (Relic / Mythic / Ergon / Empyrean, then Aeonic), one path, rank 15.
REMA = ['Spharai', 'Glanzfaust', 'Kenkonken', 'Verethragna', 'Mandau', 'Terpsichore', 'Vajra', 'Carnwenhan',
        'Twashtar', 'Excalibur', 'Murgleis', 'Burtgang', 'Tizona', 'Almace', 'Mjollnir', 'Yagrush',
        'Gambanteinn', 'Idris', 'Ragnarok', 'Caladbolg', 'Epeolatry', 'Guttler', 'Aymur', 'Farsha',
        'Bravura', 'Conqueror', 'Ukonvasara', 'Apocalypse', 'Liberator', 'Redemption', 'Gungnir',
        'Ryunohige', 'Rhongomiant', 'Kikoku', 'Nagi', 'Kannagi', 'Amanomurakumo', 'Kogarasumaru',
        'Masamune', 'Claustrum', 'Tupsimati', 'Laevateinn', 'Nirvana', 'Hvergelmir', 'Yoichinoyumi',
        'Gandiva', 'Gastraphetes', 'Annihilator', 'Death Penalty', 'Armageddon',
        'Godhands', 'Aeneas', 'Sequence', 'Chango', 'Anguta', 'Trishula', 'Heishi Shorinken',
        'Dojikiri Yasutsuna', 'Tishtrya', 'Khatvanga', 'Lionheart', 'Tri-edge', 'Fail-Not', 'Fomalhaut']
REMA_WS = {  # weapon -> the WS (or effect) its bundle names, checked below
    'Spharai': 'Final Heaven', 'Glanzfaust': "Ascetic's Fury", 'Kenkonken': 'Stringing Pummel',
    'Verethragna': 'Victory Smite', 'Mandau': 'Mercy Stroke', 'Terpsichore': 'Pyrrhic Kleos',
    'Vajra': 'Mandalic Stab', 'Carnwenhan': 'Mordant Rime', 'Twashtar': "Rudra's Storm",
    'Excalibur': 'Knights of Round', 'Murgleis': 'Death Blossom', 'Burtgang': 'Atonement',
    'Tizona': 'Expiacion', 'Almace': 'Chant du Cygne', 'Mjollnir': 'Randgrith', 'Yagrush': 'Mystic Boon',
    'Gambanteinn': 'Dagan', 'Idris': 'Exudation', 'Ragnarok': 'Scourge', 'Caladbolg': 'Torcleaver',
    'Epeolatry': 'Dimidiation', 'Guttler': 'Onslaught', 'Aymur': 'Primal Rend', 'Farsha': 'Cloudsplitter',
    'Bravura': 'Metatron Torment', 'Conqueror': "King's Justice", 'Ukonvasara': "Ukko's Fury",
    'Apocalypse': 'Catastrophe', 'Liberator': 'Insurgency', 'Redemption': 'Quietus', 'Gungnir': 'Geirskogul',
    'Ryunohige': 'Drakesbane', 'Rhongomiant': "Camlann's Torment", 'Kikoku': 'Blade: Metsu',
    'Nagi': 'Blade: Kamu', 'Kannagi': 'Blade: Hi', 'Amanomurakumo': 'Tachi: Kaiten',
    'Kogarasumaru': 'Tachi: Rana', 'Masamune': 'Tachi: Fudo', 'Claustrum': 'Gate of Tartarus',
    'Tupsimati': 'Omniscience', 'Laevateinn': 'Vidohunir', 'Nirvana': 'Garland of Bliss', 'Hvergelmir': 'Myrkr',
    'Yoichinoyumi': 'Namas Arrow', 'Gandiva': "Jishnu's Radiance", 'Gastraphetes': 'Trueflight',
    'Annihilator': 'Coronach', 'Death Penalty': 'Leaden Salute', 'Armageddon': 'Wildfire',
    'Godhands': 'Shijin Spiral', 'Aeneas': 'Exenterator', 'Sequence': 'Requiescat', 'Chango': 'Upheaval',
    'Anguta': 'Entropy', 'Trishula': 'Stardiver', 'Heishi Shorinken': 'Blade: Shun',
    'Dojikiri Yasutsuna': 'Tachi: Shoha', 'Tishtrya': 'Realmrazer', 'Khatvanga': 'Shattersoul',
    'Lionheart': 'Resolution', 'Tri-edge': 'Ruinator', 'Fail-Not': 'Apex Arrow', 'Fomalhaut': 'Last Stand'}
for b, n in enumerate(REMA, start=221):
    add(n, 'ultimate_weapon', 15, {'A': b})

# Unity +1 items, matched by augments_unity_match.js (bundles 285-392).
UNITY_MAP = os.path.join(HERE, 'cache', 'unity_map.json')
if os.path.exists(UNITY_MAP):
    for iid, b in sorted(json.load(open(UNITY_MAP)).get('matched', {}).items(), key=lambda x: x[1]):
        add(_items[int(iid)][0], 'unity', 15, {'A': b})
# Unity +1 items OmniWatch does not list: matched by hand on their BG Wiki
# augment list (cache/bgwiki/<name>.json, 'Oboro Item Page Augs').
for n, b in [('Pouwhenua +1', 303), ('Magesmasher +1', 318), ('Marin Staff +1', 333), ('Triska Scythe +1', 334),
             ('Ghastly Tathlum +1', 343), ('Ushenzi +1', 369), ('Contemplator +1', 391)]:
    add(n, 'unity', 15, {'A': b})

# Abjuration pieces Nolan (Norg) augments with Eschalixirs: four fixed paths, no rank curve, so LSB has no
# bundle for them. Written by hand from BG Wiki (Kaykaus Mitra/Bliaut/Cuffs/Tights/Boots and +1, revisions of
# 2020-07 and 2022-04): bundle 'kaykaus<+1>:<slot>:<path>', one value per effect (NQ, +1).
# Spell Interruption Down counts the reduction, as the other bundles do; the rest carry the game's sign.
_KAYKAUS_EFFECTS = {
    'mp': ('MP+#', 'MP', 60, 80), 'mnd': ('MND+#', 'MND', 10, 12), 'int': ('INT+#', 'INT', 10, 12),
    'macc': ('Magic Accuracy+#', 'Magic Accuracy', 15, 20), 'mab': ('"Magic Atk. Bonus"+#', 'Magic Attack', 15, 20),
    'cct': ('"Cure" spellcasting time -#%', 'Cure Casting Time', -5, -7), 'enm': ('Enmity-#', 'Enmity', -5, -6),
    'sird': ('Spell interruption rate down #%', 'Spell Interruption Down', 10, 12),
    'cure': ('"Cure" potency +#%', 'Cure Potency', 5, 6), 'cmp': ('"Conserve MP"+#', 'Conserve MP', 6, 7),
    'fc': ('"Fast Cast"+#%', 'Fast Cast', 3, 4),
}
_KAYKAUS_ABC = {'A': ['mp', 'mnd', 'macc'], 'B': ['mp', 'cct', 'enm'], 'C': ['mp', 'sird', 'cct']}
_KAYKAUS_D = {'Mitra': ['mnd', 'macc', 'mab'], 'Bliaut': ['mp', 'cure', 'cmp'], 'Cuffs': ['mp', 'cmp', 'fc'],
              'Tights': ['int', 'mab', 'enm'], 'Boots': ['macc', 'cure', 'fc']}
FIXED_BUNDLES = {}
for _piece, _d in _KAYKAUS_D.items():
    for _hq in (False, True):
        _paths = {}
        for _path, _effs in list(_KAYKAUS_ABC.items()) + [('D', _d)]:
            _bid = 'kaykaus%s:%s:%s' % ('+1' if _hq else '', _piece.lower(), _path)
            FIXED_BUNDLES[_bid] = [{'text': _KAYKAUS_EFFECTS[e][0], 'keys': {_KAYKAUS_EFFECTS[e][1]: 1},
                                    'values': [_KAYKAUS_EFFECTS[e][3 if _hq else 2]]} for e in _effs]
            _paths[_path] = _bid
        add('Kaykaus %s%s' % (_piece, ' +1' if _hq else ''), 'nolan', 15, _paths)


# Where LSB disagrees with BG Wiki, the bundle is corrected:
# bundle -> (effect index, field, new value, reason). Listed in AUGMENTS.md.
CORRECTIONS = {
    237: (2, 'keys', {'HP': 1, 'MP': 1, 'MND': 1},
          'Gambanteinn: LSB mask 0x01A0 reads AGI/MND/CHR; BG Wiki (Ultimate Weapon Augments) '
          'and OmniWatch give HP, MP & MND +20'),
    280: (0, 'values', lambda b: list(b['279'][0]['values']),
          'Khatvanga: LSB gives DMG+26; BG Wiki and OmniWatch give DMG+8 (curve of Tishtrya, bundle 279)'),
}


# The stat names an augment is filed under in `stats` (the others go to `extra`): the catalogue's
# vocabulary (STAT_KEYS.md). Names only, spelled as the engine before spelled them so that both engines
# read the same pieces; written here once (2026-10-22) instead of read from wsdist's gear.py at each build.
STAT_KEYS = [
    "AGI", "Accuracy", "Archery Skill", "Attack", "Automaton Skill", "Axe Skill", "Barrage",
    "Barrage Ranged Accuracy", "Blood Pact Damage", "CHR", "Climactic Crit Damage", "Club Skill",
    "Conserve TP", "Crit Damage", "Crit Rate", "DA", "DA Damage%", "DEX", "DMG", "DT", "Dagger Skill", "Daken",
    "Dark Elemental Bonus", "Dark Magic Skill", "Delay", "Double Shot", "Double Shot Damage%", "Dual Wield",
    "Earth Elemental Bonus", "Ebullience Bonus", "Elemental Bonus", "Elemental Magic Skill",
    "Elemental WS Damage%", "EnSpell Damage", "EnSpell Damage%", "Evasion", "FUA", "Fencer",
    "Fire Elemental Bonus", "Futae Bonus", "Gear Haste", "Great Axe Skill", "Great Katana Skill",
    "Great Sword Skill", "Hand-to-Hand Skill", "Hasso+ JA Haste", "INT", "Innin DA%", "Katana Skill",
    "Kick Attacks", "Kick Attacks DMG", "Klimaform Damage%", "Light Elemental Bonus", "MDT", "MDT2", "MND",
    "Magic Accuracy", "Magic Accuracy Skill", "Magic Attack", "Magic Burst Accuracy", "Magic Burst Damage",
    "Magic Burst Damage II", "Magic Crit Rate II", "Magic Damage", "Magic Defense", "Magic Evasion",
    "Marksmanship Skill", "Martial Arts", "Ninjutsu Damage%", "Ninjutsu Magic Attack", "Ninjutsu Skill", "OA2",
    "OA3", "OA4", "OA5", "OA6", "OA7", "OA8", "Occult Acumen", "PDL", "PDT", "PDT2", "Pet:AGI", "Pet:Accuracy",
    "Pet:Attack", "Pet:Crit Rate", "Pet:DA", "Pet:DEX", "Pet:DT", "Pet:Damage Dealt%", "Pet:Evasion",
    "Pet:Gear Haste", "Pet:INT", "Pet:Level", "Pet:MDT", "Pet:MND", "Pet:Magic Accuracy", "Pet:Magic Attack",
    "Pet:PDT", "Pet:Ranged Accuracy", "Pet:Ranged Attack", "Pet:STR", "Pet:Store TP", "Pet:Subtle Blow",
    "Pet:TP Bonus", "Polearm Skill", "QA", "Quick Draw Damage", "Quick Draw Damage%",
    "Quick Draw Magic Accuracy", "Ranged Accuracy", "Ranged Attack", "Ranged Crit Damage", "Recycle", "Regain",
    "STR", "Scythe Skill", "Skillchain Bonus", "Sneak Attack Bonus", "Staff Skill", "Store TP",
    "Striking Crit Rate", "Subtle Blow", "Subtle Blow II", "Sword Skill", "TA", "TA Damage%", "TP Bonus",
    "Throwing Skill", "Thunder Elemental Bonus", "Trick Attack Bonus", "Triple Shot", "Triple Shot Damage%",
    "True Shot", "VIT", "WSC", "Weapon Skill Accuracy", "Weapon Skill Damage", "Wind Elemental Bonus",
    "Zanshin", "Zanshin OA2"
]


def main():
    bundles = json.load(open(os.path.join(HERE, 'cache', 'lsb_bundles.json')))
    # REMA sanity: each bundle names its weapon's WS (or effect).
    for b, n in enumerate(REMA, start=221):
        texts = ' '.join(e['text'] or '' for e in bundles[str(b)])
        if REMA_WS[n].lower() not in texts.lower():
            raise SystemExit('REMA layout broken at %d %s: %s' % (b, n, texts))
    out_bundles = {}
    for bid, effs in bundles.items():
        out_bundles[bid] = [{'text': e['text'], 'keys': to_keys(e['params'], e['text'] or ''),
                             'values': e['values']} for e in effs]
    for bid, (idx, field, value, why) in CORRECTIONS.items():
        eff = out_bundles[str(bid)][idx]
        eff[field] = value(out_bundles) if callable(value) else value
        eff['corrected'] = why
    out_bundles.update(FIXED_BUNDLES)
    ranked, aliases, seen = {}, {}, set()
    for name, kind, max_rank, paths in ITEMS:
        iid, en, enl = resolve(name)
        if en in ranked:
            raise SystemExit('duplicate item ' + en)
        wiki = name if name != name.lower() else ' '.join(w[:1].upper() + w[1:] for w in name.split(' '))
        ranked[en] = {'id': iid, 'kind': kind, 'max_rank': max_rank, 'paths': paths, 'wiki': wiki}
        for alias in {name, enl}:
            if alias.lower() != en.lower():
                aliases[alias] = en
        seen.update(paths.values())
    unmapped = sorted(int(b) for b in bundles if int(b) not in seen)
    data = {
        'source': 'LandSandBoat scripts/data/augments.lua (xi.data.augments.bundles); layout: augments_build.py',
        'stat_keys': STAT_KEYS,
        'bundles': out_bundles,
        'items': ranked,
        'aliases': aliases,
        'unmapped_bundles': unmapped,
    }
    json.dump(data, open(os.path.join(HERE, 'augments_ranked.json'), 'w', encoding='utf-8'),
              ensure_ascii=False, separators=(',', ':'))
    js = ('// Generated by atelier/gear/augments_build.py from augments_ranked.json. Do not edit.\n'
          '// FFXI.RANKED[en name] = {id, kind, max_rank, paths: {A: {bundle, effects}}};\n'
          '// FFXI.ranked_stats(name, path, rank) -> {stat key: value}. See AUGMENTS.md.\n'
          '// @author ejouanchicot\n'
          '(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {\n'
          '    var DATA = ' + json.dumps({k: data[k] for k in ('stat_keys', 'bundles', 'items', 'aliases')},
                                       ensure_ascii=False, separators=(',', ':')) + ';\n'
          + open(os.path.join(HERE, 'augments_ranked_tail.js'), encoding='utf-8').read() + '});\n')
    open(os.path.join(HERE, 'augments_ranked.js'), 'w', encoding='utf-8').write(js)
    kinds = {}
    for v in ranked.values():
        kinds[v['kind']] = kinds.get(v['kind'], 0) + 1
    print(len(ranked), 'items', kinds, '| unmapped bundles:', len(unmapped))


if __name__ == '__main__':
    main()
