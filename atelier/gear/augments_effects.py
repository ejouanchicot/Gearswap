"""LSB bundle effect -> wsdist stat keys. Shared by the builder and the checks.

An effect is ({DAT effect id} or {parametric, arg}) + per-rank values. to_keys()
returns {key: sign}; the stat is sign * value. Keys are spelled as in wsdist's
gear.py when wsdist has the stat; other effects get a readable key (listed in
AUGMENTS.md as 'extra', not read by wsdist).
"""

STATS7 = ['STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR']

SIMPLE = {
    '9': 'HP', '10': 'MP', '11': 'STR', '12': 'DEX', '13': 'VIT', '14': 'AGI', '15': 'INT',
    '16': 'MND', '17': 'CHR', '18': 'Accuracy', '19': 'Attack', '20': 'Ranged Accuracy',
    '21': 'Ranged Attack', '22': 'Evasion', '23': 'Defense', '24': 'Magic Accuracy',
    '25': 'Magic Evasion', '26': 'Crit Rate', '29': 'Enmity', '30': 'DMG', '32': 'Gear Haste',
    '36': 'Spell Interruption Down', '37': 'PDT', '41': 'DT', '47': 'Damage Dealt%',
    '50': 'Status Resist', '53': 'TP Bonus', '55': 'DT',
    '133': 'Magic Attack', '134': 'Magic Defense', '137': 'Regen', '138': 'Refresh',
    '139': 'Rapid Shot', '140': 'Fast Cast', '141': 'Conserve MP', '142': 'Store TP',
    '143': 'DA', '144': 'TA', '145': 'Counter', '176': 'Resist Sleep', '180': 'Resist Silence',
    '185': 'Resist Bind', '188': 'Resist Charm', '194': 'Kick Attacks', '195': 'Subtle Blow',
    '211': 'Snapshot', '212': 'Recycle', '232': 'True Shot', '251': 'Daken',
    '285': 'Shield Skill', '286': 'Parrying Skill', '288': 'Healing Magic Skill',
    '289': 'Enhancing Magic Skill', '290': 'Enfeebling Magic Skill', '292': 'Dark Magic Skill',
    '321': 'Avatar Perpetuation Cost', '322': 'Song Casting Time', '326': 'Weapon Skill Accuracy',
    '327': 'Weapon Skill Damage', '328': 'Crit Damage', '329': 'Cure Potency',
    '330': 'Waltz Potency', '332': 'Skillchain Bonus', '343': 'Drain Aspir Potency',
    '353': 'TP Bonus', '354': 'QA', '356': 'Cure Potency Received', '362': 'Magic Damage',
    '363': 'Block Rate', '368': 'Phalanx Received', '369': 'Blood Pact Damage',
    '371': 'Regen Potency', '374': 'Enhancing Duration Received', '379': 'Utsusemi Enmity',
    '380': 'PDL', '515': 'EnSpell Damage (sword)',
    '1248': 'Enhancing Duration', '1249': 'Helix Duration', '1251': 'Enfeebling Duration',
    '1282': 'Regen Received', '1283': 'Crit TP', '1284': 'Drain Potency',
    '1285': 'Magic Burst Damage', '1286': 'Magic Burst Damage II', '1287': 'Magic Burst Accuracy',
    '1288': 'Ammo Damage%', '1289': 'Ammo Accuracy', '1290': 'Dagan Potency',
    '1291': 'Myrkr Potency', '1292': 'Atonement Enmity', '1293': 'Elemental WS Damage (path C)',
    '1294': 'TP During Evasion', '1295': 'Song Double Attack', '1296': 'Double Damage Chance',
    '1297': 'Double Ranged Damage Chance', '1298': 'Follow-up Chance',
    '1299': 'Ranged Follow-up Chance', '1300': 'Healing Recast', '1301': 'Ninjutsu Recast',
    '1302': 'DA Damage%', '1303': 'Counter Damage%', '1304': 'Mana Wall', '1305': 'TA Damage%',
    '1307': 'Ninjutsu Casting Time', '1308': 'Blood Pact Double Status',
    '1309': 'Luopan Duration', '1310': 'Vivacious Pulse Potency', '1311': 'Jump Damage%',
    '1313': 'Absorb Damage Taken', '1314': 'Special Attack Damage%', '1536': 'Subtle Blow II',
    '1600': 'Chakra', '1601': 'Afflatus Misery', '1604': 'Sekkanoki Recast',
    '1605': 'Sekkanoki WSD', '1606': 'Chain Affinity Recast', '1607': 'Burst Affinity Recast',
    '1608': 'Phantom Roll Duration', '1609': 'Phantom Roll', '1610': 'Phantom Roll 11 Recover',
    '1611': 'Flourish Recast', '1612': 'Step Duration',
}
# Effects whose in-game text reads "-#" (and any LSB text with '-#' or '-%d'):
# the stored value is a reduction, kept negative as the text shows it.
NEGATE = {'55', '321'}
# Effects stored in tenths of the shown value: "TP Bonus" (Ikenga's Axe R30 shows
# TP Bonus +500 for a stored 50, BG Wiki rank tables go by 10).
SCALE = {'353': 10}

ACC_BITS = [(0x1, 'Accuracy'), (0x2, 'Ranged Accuracy'), (0x4, 'Magic Accuracy')]
ATK_BITS = [(0x1, 'Attack'), (0x2, 'Ranged Attack'), (0x4, 'Magic Attack'), (0x8, 'Magic Damage')]
DEF_BITS = [(0x1, 'Defense'), (0x2, 'Magic Defense'), (0x4, 'Evasion'), (0x8, 'Magic Evasion')]
PREFIX = {'PET': 'Pet:', 'AVATAR': 'Avatar:', 'AUTOMATON': 'Automaton:',
          'WYVERN': 'Wyvern:', 'LUOPAN': 'Luopan:'}
P = 'xi.augment.parametric.'


def _bits(table, mask):
    return {k: 1 for b, k in table if mask & b}


def to_keys(params, text=''):
    """Effect params -> {key: sign}."""
    p = params
    if len(p) == 1 and not p[0].startswith(P):
        k = SIMPLE.get(p[0])
        if k is None:
            return {'Aug:' + (text or p[0]): 1}
        neg = p[0] in NEGATE or '-#' in (text or '') or '-%d' in (text or '')
        return {k: (-1 if neg else 1) * SCALE.get(p[0], 1)}
    kind = p[0].replace(P, '')
    if kind == 'ALL_ATTR':
        return {s: 1 for s in STATS7}
    arg = p[1] if len(p) > 1 else None
    if kind == 'ACCURACY':
        return _bits(ACC_BITS, int(arg, 16))
    if kind == 'ATTACK':
        return _bits(ATK_BITS, int(arg, 16))
    if kind == 'DEFENSE':
        return _bits(DEF_BITS, int(arg, 16))
    if kind == 'STAT_COMBO':
        m = int(arg, 16)
        return {s: 1 for i, s in enumerate(STATS7) if m & (1 << i)}
    if kind == 'BASE_STATS':   # bit 0 HP, bit 1 MP, then the 7 attributes
        m = int(arg, 16)
        return {s: 1 for i, s in enumerate(STATS7) if m & (1 << (i + 2))}
    if kind == 'WEAPON_SKILL':
        ws = text.split(': DMG')[0].strip('"')
        return {'WS Damage%:' + ws: 1}
    if kind in PREFIX:
        pre = PREFIX[kind]
        if arg == P + 'ALL_ATTR':
            return {pre + s: 1 for s in STATS7}
        if arg == '100':
            return {pre + 'Accuracy': 1, pre + 'Magic Accuracy': 1}
        inner = to_keys([arg], text.split(':', 1)[-1])
        return {pre + k: v for k, v in inner.items()}
    return {'Aug:' + text: 1}


def bundle_stats(bundle, rank):
    """{key: value} of one bundle at one rank (0-30)."""
    out = {}
    for e in bundle:
        vals = e['values']
        v = vals[rank] if rank < len(vals) else vals[-1]
        if not v:
            continue
        for k, s in to_keys(e['params'], e['text'] or '').items():
            out[k] = out.get(k, 0) + s * v
    return out
