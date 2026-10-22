"""Build the Ambuscade JSE cape tables: gear/capes.json + capes.js.

Sources: BG Wiki 'Template:Ambuscade Cape Augments' (cached in cache/bgwiki/, one table per
material: Thread, Sap, Dye, Dust, Resin; per-item step and max) and the gear catalogue
(items.json, built from Windower res/items.lua by build_catalog.py, which runs first): the 22
capes are the items 26246 to 26267, each one wearable by one job only.

    python capes_build.py

The comparison with wsdist's capes is a local tool (capes_gearpy_dump.py, then capes_check.js).
"""
import json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from augments_bgwiki import wikitext

# Windower res/items.lua: Cichol's Mantle (WAR) to Ogma's Cape (RUN), one job each
CAPE_IDS = range(26246, 26268)

# BG Wiki label -> the catalogue's stat keys (sign carried by the wiki value).
KEYS = {
    'HP': ['HP'], 'MP': ['MP'], 'STR': ['STR'], 'DEX': ['DEX'], 'VIT': ['VIT'], 'AGI': ['AGI'],
    'INT': ['INT'], 'MND': ['MND'], 'CHR': ['CHR'],
    'Accuracy': ['Accuracy'], 'Attack': ['Attack'], 'Ranged Accuracy': ['Ranged Accuracy'],
    'Ranged Attack': ['Ranged Attack'], 'Magic Accuracy': ['Magic Accuracy'], 'Magic Damage': ['Magic Damage'],
    'Evasion': ['Evasion'], 'Magic Evasion': ['Magic Evasion'], 'DEF': ['Defense'],
    'Pet: Accuracy': ['Pet:Accuracy'], 'Pet: Ranged Accuracy': ['Pet:Ranged Accuracy'],
    'Pet: Attack': ['Pet:Attack'], 'Pet: Ranged Attack': ['Pet:Ranged Attack'],
    'Pet: Magic Accuracy': ['Pet:Magic Accuracy'], 'Pet: Magic Damage': ['Pet:Magic Damage'],
    'Weaponskill Damage': ['Weapon Skill Damage'], 'Critical Hit Rate': ['Crit Rate'], 'Store TP': ['Store TP'],
    'Double Attack': ['DA'], 'Haste': ['Gear Haste'], 'Dual Wield': ['Dual Wield'], 'Enmity': ['Enmity'],
    'Snapshot': ['Snapshot'], 'Magic Atk. Bonus': ['Magic Attack'], 'Fast Cast': ['Fast Cast'],
    'Cure potency': ['Cure Potency'], 'Waltz potency': ['Waltz Potency'], 'Pet: Regen': ['Pet:Regen'],
    'Pet: Haste': ['Pet:Gear Haste'],
    'Physical damage taken': ['PDT'], 'Magic damage taken': ['MDT'], 'Damage taken': ['DT'],
    'Regen': ['Regen'], 'Counter': ['Counter'], 'Blocking rate': ['Block Rate'], 'Parrying rate': ['Parrying Rate'],
    'Status ailment resistance': ['Status Resist'], 'Casting interruption rate': ['Spell Interruption Down'],
    'Pet: Physical damage taken': ['Pet:PDT'], 'Pet: Magic damage taken': ['Pet:MDT'], 'Pet: damage taken': ['Pet:DT'],
}
# Rows BG Wiki leaves without a max: 5 Resin at -1% each.
MAX_FILL = {('resin', 'Damage taken'): -5, ('resin', 'Pet: damage taken'): -5}
# Casting interruption rate: the wiki shows -10%; the key counts the reduction.
ABS = {'Casting interruption rate'}


def parse_template():
    w = wikitext('Template:Ambuscade Cape Augments')
    out = {}
    for block in w.split('[[Abdhaljs ')[1:]:
        mat = block.split('|')[0].split(']')[0].strip().lower()   # thread, sap, dye, dust, resin
        if mat in out:
            continue
        rows = []
        for r in re.findall(r'font-style: italic;"\|([^\n]*)\n\|\s*style="text-align: center;"\s*\|\s*([^\n]*)'
                            r'(?:\n\|\s*style="text-align: center;"\s*\|\s*([^\n]*))?', block):
            label = re.sub(r'[^\x20-\x7e<>/]', '', r[0]).replace('"', '').strip()
            labels = [x.strip() for x in label.split('<br />')]
            first_num = lambda t: (re.match(r'\s*([+-]?\d+(?:\.\d+)?)', t or '') or [None, None])[1]
            step = float(first_num(r[1]))
            mx = first_num(r[2]) if r[2] and not r[2].startswith('|') else None
            mx = float(mx) if mx else MAX_FILL.get((mat, labels[0]))
            keys = []
            for l in labels:
                if l not in KEYS:
                    raise SystemExit('unknown cape label %r (%s)' % (l, mat))
                keys += KEYS[l]
            if labels[0] in ABS:
                step, mx = abs(step), abs(mx)
            num = lambda x: int(x) if x is not None and float(x).is_integer() else x
            rows.append({'label': ' / '.join(labels), 'keys': keys, 'step': num(step), 'max': num(mx)})
        out[mat] = rows
    return out


def capes_from_catalogue():
    """The 22 capes from items.json: {job, en, name (the long name), id}."""
    items = {e['id']: e for e in json.load(open(os.path.join(HERE, 'items.json'), encoding='utf-8'))['items']}
    capes = []
    for iid in CAPE_IDS:
        e = items.get(iid)
        if not e or e['slots'] != ['back'] or len(e['jobs']) != 1:
            raise SystemExit('item %d is not a one-job cape in items.json: %r' % (iid, e and e['name']))
        capes.append({'job': e['jobs'][0].upper(), 'en': e['name'], 'name': e['enl'], 'id': iid})
    return capes


def main():
    options = parse_template()
    capes = capes_from_catalogue()
    data = {
        'source': "BG Wiki Template:Ambuscade Cape Augments; capes: Windower res/items.lua 26246-26267 (items.json)",
        'materials': {'thread': 'one attribute or HP/MP', 'dust': 'one pair (Acc/Atk, Racc/Ratk, Macc/Mdmg, Eva/Meva)',
                      'dye': 'one stat +10 (HP/MP +20)', 'sap': 'one effect', 'resin': 'one defensive effect'},
        'options': options,
        'capes': capes,
    }
    json.dump(data, open(os.path.join(HERE, 'capes.json'), 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
    js = ('// Generated by atelier/gear/capes_build.py from capes.json. Do not edit.\n'
          '// FFXI.AMBU_CAPE_OPTIONS[material] = [{label, keys, step, max}] (material: thread, dust, dye,\n'
          '// sap, resin); FFXI.AMBU_CAPES = [{job, en, name, id}]; FFXI.ambu_cape_stats(choice).\n'
          '// @author ejouanchicot\n'
          '(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {\n'
          '    var DATA = ' + json.dumps({'options': options, 'capes': capes}, ensure_ascii=False,
                                       separators=(',', ':')) + ';\n'
          + open(os.path.join(HERE, 'capes_tail.js'), encoding='utf-8').read() + '});\n')
    open(os.path.join(HERE, 'capes.js'), 'w', encoding='utf-8').write(js)
    print(len(capes), 'capes;', {k: len(v) for k, v in options.items()}, 'options')


if __name__ == '__main__':
    main()
