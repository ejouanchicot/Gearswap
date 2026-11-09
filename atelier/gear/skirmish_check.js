// Checks skirmish.js: every Skirmish augment, written as the game shows it, must be read by the optimizer's augment
// reader (augments_parse.js) as all its stats at its max, nothing left unread; and FFXI.skirmish_max must bring a copy's
// augments to their max. Run by skirmish_build.py (node skirmish_check.js).
// @author ejouanchicot
const fs = require('fs');
const path = require('path');
const { load } = require('./augments_load');

const FFXI = load();
const rows = JSON.parse(fs.readFileSync(path.join(__dirname, 'cache', 'skirmish_check.json'), 'utf8'));
const bad = [];
for (const r of rows) {
    const p = FFXI.parse_augments('Telchine Cap', [r.text]);
    const vals = Object.values(p.stats).concat(Object.values(p.extra));
    // "Elemental Siphon"+35 and the like are read as their value; a pair ("Accuracy+15 Attack+15") as two stats
    const ok = !p.unknown.length && vals.length === r.parts && vals.every(v => Math.abs(v) === r.value);
    if (!ok) bad.push(`${r.stat}: "${r.text}" -> ${JSON.stringify({stats: p.stats, extra: p.extra, unknown: p.unknown})}`);
}
let fails = bad.length;
const eq = (what, got, want) => { if (JSON.stringify(got) !== JSON.stringify(want)) { fails++; console.log(`FAILED ${what}: ${JSON.stringify(got)}`); } };
// a copy of the players' (Tetsouo, Kaories): its augments at their max, the stones it lacks named
eq('Telchine Chas. dur +9', FFXI.skirmish_max('Telchine Chas.', ['Enh. Mag. eff. dur. +9']),
    {augs: ['Enh. Mag. eff. dur. +10'], changed: true, missing: ['Snow', 'Leaf']});
eq('Telchine Cap FC 3', FFXI.skirmish_max('Telchine Cap', ['"Fast Cast"+3', 'Enh. Mag. eff. dur. +10']),
    {augs: ['"Fast Cast"+5', 'Enh. Mag. eff. dur. +10'], changed: true, missing: ['Snow']});
eq('an unlisted augment kept', FFXI.skirmish_max('Telchine Cap', ['Pet: "Regen"+3']).augs, ['Pet: "Regen"+3']);
eq('not a Skirmish piece', FFXI.skirmish_max('Nyame Helm', []), null);
eq('the long name', FFXI.SKIRMISH_BY_NAME['Telchine Chasuble'], 'Telchine');
for (const b of bad) console.log('UNREAD ' + b);
console.log(`${rows.length} augments, ${bad.length} unread; ${fails} failed in all`);
process.exit(fails ? 1 : 0);
