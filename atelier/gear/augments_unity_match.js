// Unity +1 items -> LSB bundles 285-392. The bundle table has no item names,
// so each bundle is matched on its rank-15 stats against the augment list
// OmniWatch gives for the item (cache/omni_Unity_Gear.lua, keyed by item id),
// both read through the same key vocabulary. Writes cache/unity_map.json:
// {matched: {itemId: bundle}, ambiguous: {...}, unmatched_items, unmatched_bundles}.
//     node augments_unity_match.js
// @author ejouanchicot
const fs = require('fs');
const path = require('path');
const { load } = require('./augments_load');

const FFXI = load();
const RANGE = [285, 392];
const src = fs.readFileSync(path.join(__dirname, 'cache', 'omni_Unity_Gear.lua'), 'utf8');

// OmniWatch strings that our labels do not spell the same way.
const FIX = [
    [/^Ranged Magic Accuracy/, 'Magic Accuracy'],
    [/^All Base Stats/, 'STR/DEX/VIT/AGI/INT/MND/CHR'],
    [/^Avatar: All Base Stats/, 'Avatar: STR/DEX/VIT/AGI/INT/MND/CHR'],
    [/^All Attr\./, 'STR/DEX/VIT/AGI/INT/MND/CHR'],
    [/^Store TP/, '"Store TP"'],
    [/^Pet: /, 'Pet:'],
    [/^Avatar: /, 'Avatar:'],
];

function stats_of_strings(augs) {
    const out = {};
    let bad = [];
    for (let s of augs) {
        for (const [re, rep] of FIX) s = s.replace(re, rep);
        const p = FFXI.parse_augment_string(s, null);
        if (p.unknown) { bad.push(s); continue; }
        for (const e of p.effects) out[e.key] = (out[e.key] || 0) + e.value;
    }
    return { stats: out, bad };
}

function bundle_stats(id, rank) {
    const out = {};
    for (const e of FFXI.RANKED_BUNDLES[id]) {
        const v = e.values[Math.min(rank, e.values.length - 1)];
        if (!v) continue;
        for (const k of Object.keys(e.keys)) out[k] = (out[k] || 0) + e.keys[k] * v;
    }
    return out;
}

function same(a, b) {
    const ka = Object.keys(a).filter(k => a[k]), kb = Object.keys(b).filter(k => b[k]);
    return ka.length === kb.length && ka.every(k => a[k] === b[k]);
}

const items = [];
const re = /\[(\d+)\]=\{\s*\["id"\]=\d+,\s*\["Unity Ranking"\]="[^"]*",\s*\["en"\]="([^"]*)",([\s\S]*?)\n    \}/g;
let m;
while ((m = re.exec(src)) !== null) {
    const a = /\["augments"\]=\{([\s\S]*?)\}/.exec(m[3]);
    if (!a) continue;
    const augs = [...a[1].matchAll(/'([^']*)'/g)].map(x => x[1]);
    items.push({ id: +m[1], en: m[2], augs });
}

const result = { matched: {}, ambiguous: {}, unparsed: {}, unmatched_items: [], unmatched_bundles: [] };
const used = new Set();
for (const it of items) {
    const { stats, bad } = stats_of_strings(it.augs);
    if (bad.length) result.unparsed[it.en] = bad;
    const hits = [];
    for (let b = RANGE[0]; b <= RANGE[1]; b++) if (same(stats, bundle_stats(b, 15))) hits.push(b);
    if (hits.length === 1) { result.matched[it.id] = hits[0]; used.add(hits[0]); }
    else if (hits.length > 1) result.ambiguous[it.en + ' (' + it.id + ')'] = hits;
    else result.unmatched_items.push(it.en + ' (' + it.id + '): ' + JSON.stringify(stats));
}
// Items OmniWatch lists with a wrong or partial augment list, placed by hand:
// the only free bundle with the item's distinctive effect (checked on BG Wiki,
// see augments_check_bgwiki.js).
const MANUAL = {
    20807: [299, 'Buramgh +1: OmniWatch says Acc+35, LSB bundle 299 has 25'],
    26732: [329, 'Stinger Helm +1: OmniWatch omits PDL+5'],
    27563: [306, 'Metamorph Ring +1: OmniWatch says INT/MND/CHR+5, bundle 306 has 10'],
    28135: [289, 'Assid. Pants +1: OmniWatch drops the Avatar: prefix of the attributes'],
    25856: [382, 'Tatena. Haidate +1: 382 and 386 are identical, given in item id order'],
    25924: [386, 'Tatena. Sune. +1: 382 and 386 are identical, given in item id order'],
};
result.manual = {};
for (const [id, [b, why]] of Object.entries(MANUAL)) {
    if (result.matched[id] || used.has(b)) continue;
    result.matched[id] = b; used.add(b); result.manual[id] = why;
    for (const k of Object.keys(result.ambiguous)) if (k.endsWith('(' + id + ')')) delete result.ambiguous[k];
    result.unmatched_items = result.unmatched_items.filter(s => !s.includes('(' + id + ')'));
}
for (let b = RANGE[0]; b <= RANGE[1]; b++) if (!used.has(b)) result.unmatched_bundles.push(b);
fs.writeFileSync(path.join(__dirname, 'cache', 'unity_map.json'), JSON.stringify(result, null, 1));
console.log('unity items with augments:', items.length, '| matched:', Object.keys(result.matched).length,
    '| ambiguous:', Object.keys(result.ambiguous).length, '| unmatched items:', result.unmatched_items.length,
    '| unmatched bundles:', result.unmatched_bundles.length);
if (process.argv.includes('-v')) console.log(JSON.stringify(result, null, 1));
