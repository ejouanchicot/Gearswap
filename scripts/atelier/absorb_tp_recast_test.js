// Test of the Atelier's Absorb-TP recast (atelier/opt_enf.js O.absorbTpRecast, O.darkFigures): the figures of the
// SPEC notes/docs-perso/absorb-tp-recast-2026-11-13 and of GEO_DRK_Absorb-TP_recast.md (BG Wiki Spell_Recast).
// Run from data/: node scripts/atelier/absorb_tp_recast_test.js
'use strict';
const fs = require('fs');
const vm = require('vm');

const ctx = {globalThis: null, Math, console};
ctx.globalThis = ctx;
vm.createContext(ctx);
vm.runInContext(fs.readFileSync('atelier/opt_enf.js', 'utf8'), ctx, {filename: 'opt_enf.js'});
const O = {};
for (const part of ctx.FFXI_PARTS) part({opt: O});

let fails = 0;
const check = (name, got, want) => {
  const ok = Math.abs(got - want) < 1e-9;
  if (!ok) fails++;
  console.log((ok ? 'ok   ' : 'FAIL ') + name + ': ' + got + (ok ? '' : ' (wanted ' + want + ')'));
};
const R = O.absorbTpRecast;
if (typeof R !== 'function') { console.log('FAIL O.absorbTpRecast missing'); process.exit(1); }

// the document's table B, no haste buff
check('80 % FC + 25 % gear haste: 27 s', R(80, 25, 0), 27);
check('80 % FC, no haste: 36 s', R(80, 0, 0), 36);
check('no FC, 25 % gear haste: 45 s', R(0, 25, 0), 45);
check('nothing: 60 s', R(0, 0, 0), 60);
// the caps: Fast Cast 80, gear haste 25 % (256/1024), magic haste 43.75 % (448/1024)
check('FC over 80 counts as 80', R(95, 0, 0), 36);
check('gear haste over 25 % counts as 25', R(80, 40, 0), 27);
// table A: Haste II + Honor March, magic haste capped
check('capped magic haste + 25 % gear + 72 % FC: the 12 s floor', R(72, 25, 60), 12);
check('capped magic haste + 25 % gear + 80 % FC: 12 s', R(80, 25, 60), 12);
check('capped magic haste, no gear haste, 80 % FC: about 20 s', R(80, 0, 60), Math.round(60 * (1 - 448 / 1024) * 0.6 * 10) / 10);
// never under 20 % of 60 s
check('the floor holds', R(80, 25, 100), 12);

// the figure in a set: negative (less is better), the midcast's Fast Cast with the traits, the gear haste, the buffs
const f = {hp: 2000};
O.darkFigures(f, {fc: 70, haste: 25, macc: 50}, {darkKind: 'absorbtp', fc: 10, mhaste: 0});
check('figure: negative seconds, FC 70 + 10 trait', f.darkRecast, -27);
const f2 = {hp: 2000};
O.darkFigures(f2, {fc: 40, haste: 10}, {darkKind: 'absorbtp', mhaste: 30.0});
check('figure: with Haste II', f2.darkRecast, -R(40, 10, 30.0));

console.log(fails ? fails + ' FAILED' : 'ALL OK');
process.exit(fails ? 1 : 0);
