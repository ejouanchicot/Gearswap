// Checks augments_ranked.js against independent transcriptions of the game data:
//   1. BG Wiki per-rank tables ({{Augment Rank Table|Path=X}} / {{Augment Rank|Rank=N|AugmentK=...}}),
//   2. BG Wiki max-rank summaries (Nolan/Oboro "... Augs" templates, RankMax + Contents),
//   3. OmniWatch DREMA_augments.lua (ultimate weapons R15, Dynamis-D weapons paths a/b/c),
//   4. OmniWatch Misc_augments.lua (JSE necks at R15/R20/R25).
// Each text is read with FFXI.parse_augment_string and compared key by key with
// FFXI.ranked_stats. Pages come from cache/bgwiki (augments_fetch_bgwiki.py).
//     node augments_check_bgwiki.js [-v]
// Writes cache/check_bgwiki.json.
// @author ejouanchicot
const fs = require('fs');
const path = require('path');
const { load } = require('./augments_load');

const FFXI = load();
const CACHE = path.join(__dirname, 'cache');
const VERBOSE = process.argv.includes('-v');

function page(name) {
    const safe = name.replace(/[^A-Za-z0-9\-_+]/g, '_');
    const p = path.join(CACHE, 'bgwiki', safe + '.json');
    if (!fs.existsSync(p)) return '';
    const d = JSON.parse(fs.readFileSync(p, 'utf8'));
    return (d.parse && d.parse.wikitext && d.parse.wikitext['*']) || '';
}

// Wiki / OmniWatch spellings -> parser spellings.
const FIX = [
    [/&nbsp;/g, ' '], [/<[^>]+>/g, ''], [/'''/g, ''], [/''/g, ''], [/\{\{[^}]*(\}\})?/g, ''], [/\}\}\s*$/, ''], [/\[\[(?:[^\]|]*\|)?([^\]]*)\]\]/g, '$1'],
    [/^\s*\[\d\]\s*/, ''],
    [/All Base Stats|All Attr\.|All attributes/gi, 'STR/DEX/VIT/AGI/INT/MND/CHR'],
    [/Weapon skill dmg/gi, 'Weapon skill damage'], [/Physical dmg limit/gi, 'Physical damage limit'],
    [/Weaponskill damage/gi, 'Weapon skill damage'],
    [/Dbl\. Atk\./g, '"Dbl.Atk."'], [/Magic Attack Bonus/g, '"Mag.Atk.Bns."'],
    [/Potency of Cure effects Received/gi, 'Potency of "Cure" effect received'],
    [/^Pet: ?/, 'Pet:'], [/^Avatar: ?/, 'Avatar:'], [/^Automaton: ?/, 'Automaton:'], [/^Wyvern: ?/, 'Wyvern:'],
    [/Ranged Magic Accuracy/g, 'Magic Accuracy'],
    [/: Damage\+/g, ': DMG:+'],
];
function clean(s) {
    for (const [re, rep] of FIX) s = s.replace(re, rep);
    return s.trim();
}

function stats_of(strings) {
    const out = {}, bad = [];
    let prefix = null;
    for (let s of strings) {
        s = clean(s);
        if (!s || /^-+$/.test(s)) continue;
        const p = FFXI.parse_augment_string(s, prefix);
        prefix = p.prefix;
        if (p.unknown) { bad.push(s); continue; }
        for (const e of p.effects) out[e.key] = (out[e.key] || 0) + e.value;
    }
    return { stats: out, bad };
}

function diff(expected, ours) {
    const d = {};
    for (const k of new Set([...Object.keys(expected), ...Object.keys(ours)])) {
        const a = expected[k] || 0, b = ours[k] || 0;
        if (a !== b) d[k] = [a, b];
    }
    return d;
}

const report = { checks: 0, ok: 0, by_source: {}, mismatches: [], unparsed: {}, rank_max: [], items_checked: new Set() };
function record(source, item, pathName, rank, expected, bad) {
    const ours = FFXI.ranked_stats(item, pathName, rank);
    // Unparsed strings: compare only the keys we could read on the wiki side.
    let d = diff(expected, ours);
    if (bad.length) {
        for (const s of bad) report.unparsed[s] = (report.unparsed[s] || 0) + 1;
        for (const k of Object.keys(d)) if (!(k in expected)) delete d[k];
    }
    const s = report.by_source[source] = report.by_source[source] || { checks: 0, ok: 0 };
    s.checks++; report.checks++; report.items_checked.add(item);
    if (!Object.keys(d).length) { s.ok++; report.ok++; return; }
    report.mismatches.push({ source, item, path: pathName, rank, diff: d });
}

// --- 1 and 2: BG Wiki ---------------------------------------------------------
for (const [en, it] of Object.entries(FFXI.RANKED)) {
    const w = page(DATA_WIKI(en));
    if (!w) continue;
    const paths = Object.keys(it.paths);
    // per-rank tables
    const tables = w.split(/\{\{Augment Rank Table/).slice(1);
    for (const t of tables) {
        const pm = /\|\s*Path\s*=\s*([A-D])/.exec(t);
        const p = pm ? pm[1] : (paths.length === 1 ? paths[0] : null);
        if (!p || !it.paths[p]) continue;
        for (const row of t.split(/\{\{Augment Rank\s*\n?\s*\|/).slice(1)) {
            const rm = /Rank\s*=\s*(\d+)/.exec(row);
            if (!rm) continue;
            const strs = [...row.matchAll(/\|\s*Augment\d+\s*=([^\n]*)/g)].map(x => x[1]);
            const { stats, bad } = stats_of(strs);
            if (!Object.keys(stats).length && !bad.length) continue;   // a row the wiki left blank
            record('bgwiki rank table', en, p, +rm[1], stats, bad);
        }
    }
    // max-rank summary
    const sm = /\{\{(Nolan Item Page Augs|Oboro Item Page Augs|Oboro JSE Neck Augs|Oboro Divergence Weapon Augs)\s*\|\s*RankMax\s*=\s*(\d+)\s*\|\s*Contents\s*=([\s\S]*?)\n\}\}/.exec(w);
    if (sm) {
        const rankMax = +sm[2];
        if (rankMax !== it.max_rank) report.rank_max.push(`${en}: wiki RankMax ${rankMax}, table ${it.max_rank}`);
        let cols = sm[3].split(/\{\{!\}\}[^\n{]*?\{\{!\}\}|\{\{!\}\}/).map(c => c.trim()).filter(Boolean);
        // Dynamis-D pages show path C only (then a 'DMG for paths A & B' row).
        if (sm[1].includes('Divergence')) cols = cols.slice(0, 1).map(c => c.replace(/^\s*(rowspan|colspan)=\d+\s*/, ''));
        let colPaths = sm[1].includes('Divergence') ? ['C'] :
            cols.length > 1 ? ['A', 'B', 'C', 'D'].slice(0, cols.length) : [paths.length === 1 ? 'A' : null];
        cols.forEach((c, i) => {
            const p = colPaths[i];
            if (!p || !it.paths[p]) return;
            const strs = c.split(/<br\s*\/?>/i);
            const { stats, bad } = stats_of(strs);
            record('bgwiki max rank', en, p, rankMax, stats, bad);
        });
    }
}

// --- 3: OmniWatch DREMA ---------------------------------------------------------
const byId = {};
for (const [en, it] of Object.entries(FFXI.RANKED)) byId[it.id] = en;
const drema = fs.readFileSync(path.join(CACHE, 'omni_DREMA_augments.lua'), 'utf8');
for (const m of drema.matchAll(/\[(\d+)\]\s*=\s*\{([\s\S]*?)\n    \},/g)) {
    const en = byId[+m[1]];
    if (!en) continue;
    for (const pm of m[2].matchAll(/\['path: ([abc])'\]\s*=\s*\{([\s\S]*?)\}/g)) {
        const strs = [...pm[2].matchAll(/(['"])((?:(?!\1).)*)\1/g)].map(x => x[2]);
        const { stats, bad } = stats_of(strs);
        record('omniwatch drema', en, pm[1].toUpperCase(), FFXI.RANKED[en].max_rank, stats, bad);
    }
}

// --- 4: OmniWatch JSE necks ---------------------------------------------------
const misc = fs.readFileSync(path.join(CACHE, 'omni_Misc_augments.lua'), 'utf8');
for (const m of misc.matchAll(/--\s*[^\n]*\(([A-Z]{3}), R(\d+)\)\s*\n\s*\[(\d+)\]\s*=\s*\{([^}]*)\}/g)) {
    const en = byId[+m[3]];
    if (!en) continue;
    const strs = [...m[4].matchAll(/'([^']*)'/g)].map(x => x[1]);
    const { stats, bad } = stats_of(strs);
    record('omniwatch necks', en, 'A', +m[2], stats, bad);
}

function DATA_WIKI(en) { return FFXI.RANKED[en].wiki || en; }

const kinds = {};
for (const en of report.items_checked) { const k = FFXI.RANKED[en].kind; kinds[k] = (kinds[k] || 0) + 1; }
const allKinds = {};
for (const it of Object.values(FFXI.RANKED)) allKinds[it.kind] = (allKinds[it.kind] || 0) + 1;
const out = Object.assign({}, report, { items_checked: report.items_checked.size, items_checked_by_kind: kinds });
fs.writeFileSync(path.join(CACHE, 'check_bgwiki.json'), JSON.stringify(out, null, 1));
console.log(`checks: ${report.checks}, exact: ${report.ok} (${(100 * report.ok / Math.max(1, report.checks)).toFixed(1)}%)`);
for (const [s, v] of Object.entries(report.by_source)) console.log(`  ${s}: ${v.ok}/${v.checks}`);
console.log('  items checked by kind: ' + Object.keys(allKinds).map(k => `${k} ${kinds[k] || 0}/${allKinds[k]}`).join(', '));
console.log(`  unparsed strings: ${Object.keys(report.unparsed).length}, RankMax disagreements: ${report.rank_max.length}`);
if (VERBOSE) {
    const byItem = {};
    for (const m of report.mismatches) (byItem[m.item + ' ' + m.path + ' (' + m.source + ')'] = byItem[m.item + ' ' + m.path + ' (' + m.source + ')'] || []).push(m.rank + ':' + JSON.stringify(m.diff));
    for (const [k, v] of Object.entries(byItem)) console.log('  MISMATCH', k, v.length, 'rows, e.g.', v.slice(0, 2).join(' | '));
    console.log('  UNPARSED', JSON.stringify(report.unparsed));
    console.log('  RANKMAX', report.rank_max);
}
