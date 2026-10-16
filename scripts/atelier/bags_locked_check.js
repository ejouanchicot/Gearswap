// ============================================================================
// Locked wardrobes - the Bags view never counts a bag the character has not unlocked
// ============================================================================
// The game sends Wardrobes 5-8 with their size even when they are not unlocked
// (enabled false). bvBags (atelier/app/js/bags_view.js), the one reader the
// view, the plan and the moves sent to the game share, must leave an empty
// locked wardrobe out and show one that still holds things as full: then no
// plan sends anything there (seen 2026-10-16: Kaories, W5 in the plan).
//
//   node scripts/atelier/bags_locked_check.js
//
// @file    scripts/atelier/bags_locked_check.js
// @author  ejouanchicot
// @version 1.0
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs'), path = require('path'), vm = require('vm');
const DATA = path.resolve(__dirname, '..', '..');

const bag = (name, id, n, enabled) => ({id, name, place: 'wardrobe', max: 80, count: n, enabled,
  items: Array.from({length: n}, (_, i) => ({id: 1000 + id * 100 + i, n: 1}))});
const exported = {at: '2026-10-16 12:00:00', items: {}, bags: [
  bag('Wardrobe 4', 13, 73, true), bag('Wardrobe 5', 14, 0, false), bag('Wardrobe 6', 15, 2, false)]};

const ctx = {T: {fr: {}, en: {}}, S: {char: 'Test'}, DATA_GEN: 1, DATA: {Test: {COR: {DNC: {bags: exported}}}},
  latestExport: () => null, console, window: {addEventListener: () => {}}, document: {addEventListener: () => {}}};
vm.createContext(ctx);
vm.runInContext(fs.readFileSync(path.join(DATA, 'atelier/app/js/bags_view.js'), 'utf8') + '\n;globalThis.__B = bvBags();', ctx);
const B = ctx.__B;

const fails = [];
const find = n => B.bags.find(b => b.name === n);
if (!find('Wardrobe 4') || find('Wardrobe 4').max !== 80) fails.push('an unlocked wardrobe keeps its size');
if (find('Wardrobe 5')) fails.push('an empty locked wardrobe is left out');
const w6 = find('Wardrobe 6');
if (!w6) fails.push('a locked wardrobe that still holds things is shown');
else {
  if (w6.max - w6.count !== 0) fails.push('a locked wardrobe has no free room (max ' + w6.max + ', count ' + w6.count + ')');
  if (!w6.locked) fails.push('a locked wardrobe is marked locked');
}
if (exported.bags.find(b => b.name === 'Wardrobe 6').max !== 80) fails.push("the export itself is not changed");

for (const f of fails) console.log('FAIL ' + f);
console.log(fails.length ? `${fails.length} of 6 checks failed` : '6 checks, 0 failed');
process.exit(fails.length ? 1 : 0);
