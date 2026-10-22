// Tests for augments_parse.js.
//   1. Golden cases (augments_parse_tests.json): strings as Windower's extdata.lua
//      prints them, with the keys and values they must give.
//   2. Coverage: every augment of extdata.lua's augment_values (systems 1 and 2,
//      cache/extdata_augments.json from augments_extdata_dump.py) is printed the
//      way extdata.lua's string_augment does, then parsed; strings the parser
//      cannot read must belong to a family listed in IGNORED (effects no stat
//      model uses), otherwise the test fails.
//   3. LSB bundle texts: each bundle effect text, with its rank-30 value, must
//      parse to the same keys as augments_effects.py gave the bundle.
//   4. parse_augments on whole pieces (Odyssey path + rank, ambuscade cape).
//     node augments_parse_test.js [-v]
// @author ejouanchicot
const fs = require('fs');
const path = require('path');
const { load } = require('./augments_load');

const FFXI = load();
const VERBOSE = process.argv.includes('-v');
let failures = 0;
function fail(msg) { failures++; console.log('FAIL', msg); }
function same(a, b) {
    const ka = Object.keys(a).filter(k => a[k]), kb = Object.keys(b).filter(k => b[k]);
    return ka.length === kb.length && ka.every(k => a[k] === b[k]);
}
function flat(p) {
    const o = {};
    for (const e of p.effects) o[e.key] = (o[e.key] || 0) + e.value;
    return o;
}

// --- 1. golden ----------------------------------------------------------------
const golden = JSON.parse(fs.readFileSync(path.join(__dirname, 'augments_parse_tests.json'), 'utf8'));
let gOk = 0;
for (const t of golden.cases) {
    const p = FFXI.parse_augment_string(t.s, t.prefix || null);
    const got = flat(p);
    if (t.unknown ? p.unknown : (!p.unknown && same(got, t.expect))) gOk++;
    else fail(`golden ${JSON.stringify(t.s)}: expected ${JSON.stringify(t.unknown ? 'unknown' : t.expect)}, got ${p.unknown ? 'unknown' : JSON.stringify(got)}`);
}
console.log(`golden strings: ${gOk}/${golden.cases.length}`);

// --- 2. extdata coverage ------------------------------------------------------
// Families no stat model reads: printed by Windower, deliberately left unknown.
const IGNORED = [
    /^Enhances ".*" effect/, /^Enh\. ".*"/, /Ability delay|ability delay|ab\. del\.|Blood Pact" delay|"Blood Pact" ability delay/i,
    /^Add\.eff\.:/, /Affinity/, /^Vs\. /, /resistance[+-]/, /^\d+[+-]/, /^\?\?\?/, /Cap\. Point/,
    /^(Inc\.|Increases|Reduces) /, /^Occ\. (grants|maximizes|quickens)/, /Immunobreak/, /Avatar:/,
    /"Call Beast"|"Sic" and "Ready"|"Phantom Roll" ability|"Quick Draw" ability|"Waltz" ability/,
    /Meditate eff\. dur\.|"Cure" spellcasting time|Song recast|Enh\. Ninj\.|"Elemental Siphon"|"Blood Boon"|"Embolden"/,
    /^Pet: Breath|^Pet: Enemy crit|^Pet: Enmity|^Automaton: /,
    /^[^0-9]*$/,                                        // flag augments printed without a value
];
const ext = JSON.parse(fs.readFileSync(path.join(__dirname, 'cache', 'extdata_augments.json'), 'utf8'));
function windower_string(effs, val) {    // extdata.lua tools.aug.string_augment, systems 1/2
    let s = null;
    effs.forEach((v, i) => {
        if (i > 0) s += ' ';
        s = (s || '') + v.stat;
        const pot = (val + v.offset) * v.multiplier;   // Lua: multiplier 0 stays 0
        if (pot > 0) s += '+' + pot; else if (pot < 0) s += pot;
        if (v.percent) s += '%';
    });
    return s;
}
let cov = 0, covIgnored = 0, covTotal = 0;
const missing = {};
for (const sys of ['1', '2']) {
    for (const [id, effs] of Object.entries(ext.systems[sys])) {
        if (effs.some(e => e.stat === 'none' || /^-+$/.test(e.stat))) continue;
        const s = windower_string(effs, 4);
        covTotal++;
        const p = FFXI.parse_augment_string(s, null);
        if (!p.unknown && p.effects.length) { cov++; continue; }
        if (p.prefix && !p.effects.length) { cov++; continue; }          // 'Pet:' marker
        if (IGNORED.some(re => re.test(s))) { covIgnored++; continue; }
        missing[s] = sys + ':' + id;
    }
}
console.log(`extdata augments (systems 1-2, value 4): ${covTotal}, parsed ${cov}, ignored families ${covIgnored}, unexpected ${Object.keys(missing).length}`);
for (const [s, id] of Object.entries(missing)) fail(`extdata ${id} ${JSON.stringify(s)} not parsed`);

// --- 3. LSB bundle texts -------------------------------------------------------
let lOk = 0, lTotal = 0;
for (const [bid, effs] of Object.entries(FFXI.RANKED_BUNDLES)) {
    for (const e of effs) {
        if (!e.text || e.corrected) continue;
        // Stored in other units than shown (TP Bonus x10) or value inside the text: not comparable.
        if (Object.values(e.keys).some(m => Math.abs(m) !== 1) || /# for each/.test(e.text)) continue;
        const v = e.values[e.values.length - 1];
        if (!v) continue;
        lTotal++;
        // LSB writes '#' (or %d) for each value; '-#' texts store the size of a reduction.
        const neg = /-#|-%d/.test(e.text);
        const shown = neg ? '-' + Math.abs(v) : (v < 0 ? String(v) : '+' + v);
        const txt = e.text.replace(/%%/g, '%').replace(/[+-]?(#|%d)/g, shown);
        const p = FFXI.parse_augment_string(txt, null);
        const expect = {};
        for (const [k, m] of Object.entries(e.keys)) expect[k] = m * v;
        if (!p.unknown && same(flat(p), expect)) lOk++;
        else if (VERBOSE) console.log('  bundle', bid, JSON.stringify(txt), 'expected', JSON.stringify(expect), 'got', p.unknown ? 'unknown' : JSON.stringify(flat(p)));
    }
}
console.log(`LSB bundle effect texts read back to the builder's keys: ${lOk}/${lTotal}`);

// --- 4. whole pieces ----------------------------------------------------------
const pieces = [
    { name: 'Nyame Mail', augs: ['Path: B'], rank: 30, expect: { 'Attack': 35, 'Ranged Attack': 35, 'Weapon Skill Damage': 13, 'DA': 7, 'STR': 10, 'VIT': 10 } },
    { name: "Sakpata's Plate", augs: ['Path: A'], rank: 20, expect: null },
    { name: "Cichol's Mantle", augs: ['STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken -10%'],
      expect: { 'STR': 30, 'Accuracy': 20, 'Attack': 20, 'Weapon Skill Damage': 10, 'PDT': -10 } },
    { name: 'Herculean Helm', augs: ['Accuracy+25 Attack+25', 'Weapon skill damage +3%', 'STR+9', 'Accuracy+12', 'Attack+5'],
      expect: { 'Accuracy': 37, 'Attack': 30, 'Weapon Skill Damage': 3, 'STR': 9 } },
];
for (const t of pieces) {
    const r = FFXI.parse_augments(t.name, t.augs, t.rank);
    if (t.expect && !same(r.stats, t.expect)) fail(`piece ${t.name}: expected ${JSON.stringify(t.expect)}, got ${JSON.stringify(r.stats)} extra ${JSON.stringify(r.extra)}`);
    if (!t.expect && !r.ranked) fail(`piece ${t.name}: not found in FFXI.RANKED`);
    if (VERBOSE) console.log('  piece', t.name, JSON.stringify(r));
}
console.log(`whole pieces: ${pieces.length - 0} run`);

console.log(failures ? `${failures} failure(s)` : 'all augment parse tests passed');
process.exitCode = failures ? 1 : 0;
