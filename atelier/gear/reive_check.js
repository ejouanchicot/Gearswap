// Checks reive.js: every Reive cape augment read at its max (aug_lines_check.js), and FFXI.reive_max bringing a cape's
// augments to their max. Run by reive_build.py (node reive_check.js).
// @author ejouanchicot
const { load } = require('./augments_load');
const { unreadLines } = require('./aug_lines_check');

const FFXI = load();
const { rows, bad } = unreadLines(FFXI, 'reive');
let fails = bad.length;
const eq = (what, got, want) => { if (JSON.stringify(got) !== JSON.stringify(want)) { fails++; console.log(`FAILED ${what}: ${JSON.stringify(got)}`); } };
// the PLD template's Weard Mantle (_master/sets/pld_sets.lua) and Gab's Ghostfyre Cape (0_AugGear_Gabvanstronger.lua)
eq('Weard Mantle', FFXI.reive_max('Weard Mantle', ['VIT+4', 'DEX+3', 'Enmity+4', 'Phalanx +5']),
    {augs: ['VIT+5', 'DEX+5', 'Enmity+7', 'Phalanx +5'], changed: true, missing: []});
eq('Ghostfyre Cape', FFXI.reive_max('Ghostfyre Cape', ['Enfb.mag. skill +10', 'Enha.mag. skill +10', 'Enh. Mag. eff. dur. +20']),
    {augs: ['Enfb.mag. skill +10', 'Enha.mag. skill +10', 'Enh. Mag. eff. dur. +20'], changed: false, missing: ['Mag. Acc.+10']});
eq('a bare cape', FFXI.reive_max('Rhapsode\'s Cape', []).missing, ['HP+30', 'Mag. Acc.+7', 'Enmity-10', 'Damage taken-3%']);
eq('not a Reive cape', FFXI.reive_max('Intarabus\'s Cape', []), null);
for (const b of bad) console.log('UNREAD ' + b);
console.log(`${rows} augments, ${bad.length} unread; ${fails} failed in all`);
process.exit(fails ? 1 : 0);
