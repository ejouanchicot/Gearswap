// Checks skirmish.js: every Skirmish augment read at its max (aug_lines_check.js), and FFXI.skirmish_max bringing a
// copy's augments to their max. Run by skirmish_build.py (node skirmish_check.js).
// @author ejouanchicot
const { load } = require('./augments_load');
const { unreadLines } = require('./aug_lines_check');

const FFXI = load();
const { rows: count, bad } = unreadLines(FFXI, 'skirmish');
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
console.log(`${count} augments, ${bad.length} unread; ${fails} failed in all`);
process.exit(fails ? 1 : 0);
