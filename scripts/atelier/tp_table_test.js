// Test of the page's TP pieces table (atelier/app/js/tp_table.js) and of what the game reads back from it
// (shared/utils/weaponskill/tp_pieces_table.lua), without a browser: the page's file runs in a sandbox with the
// engine stubbed, the Lua it writes is read by lua5.1 through the game's own reader.
//
//   node scripts/atelier/tp_table_test.js          (from data/; run by scripts/run_tests.py)
//
// Checks:
//   - one file a job, tp_pieces_<JOB>.lua, holding that job only
//   - a set the engine cannot work out (Blast Shot) is skipped and named; the job's other sets are still written
//   - the same buffs ticked: nothing written again; other buffs: the table worked out again (the player's choice B)
//   - the Lua written is read back by the game as the page meant it (segments, sets, weapons)
//
// @file    scripts/atelier/tp_table_test.js
// @author  ejouanchicot
'use strict';
const fs = require('fs'), os = require('os'), path = require('path'), vm = require('vm');
const {execFileSync} = require('child_process');

let failed = 0;
const check = (label, ok) => { if (!ok) failed++; console.log((ok ? 'ok   ' : 'FAIL ') + label); };

// the page's luaStr (atelier/app/js/live.js), so the Lua written is the page's own
const live = fs.readFileSync('atelier/app/js/live.js', 'utf8');
const luaStrLine = live.split('\n').find(l => l.startsWith('const luaStr ='));
if (!luaStrLine) { console.log('FAIL luaStr not found in live.js'); process.exit(1); }

const saved = [];
let buffs = {food: 'Grape Daifuku'};
const sets = [
  {path: 'sets.precast.WS["Savage Blade"]', ws: 'Savage Blade', pieces: {main: {name: 'Naegling'}, sub: {name: 'Blurred Shield +1'}, head: {name: 'Nyame Helm'}, ear1: {name: 'Ishvara Earring'}}},
  {path: 'sets.precast.WS["Blast Shot"]', ws: 'Blast Shot', pieces: {main: {name: 'Naegling'}, range: {name: 'Death Penalty'}, head: {name: 'Nyame Helm'}}},
  {path: 'sets.idle', pieces: {head: {name: 'Nyame Helm'}}},
];
const d = {job: 'COR', sets, tp_rule: {piece_list: [{slot: 'ear1', name: 'Moonshade Earring', bonus: 250}]}};
const ctx = {
  console: {warn: () => {}, log: console.log}, Set, Map, Object, JSON, Math, Promise, setTimeout, Array, String, Date,
  S: {char: 'Kaories', job: 'COR', trial: {}},
  data: () => d, liveOk: () => true, engineReady: () => true, render: () => {}, stamp: () => '2026-11-14 12:00',
  t: (k, v) => k + JSON.stringify(v || {}),
  saveFile: async (file, text) => { saved.push({file, text}); return true; },
  buffState: () => buffs,
  family: (p) => p.startsWith('sets.precast.WS') ? 'ws' : 'idle',
  wsOfSet: s => s.ws, withWeapons: s => ({pieces: s.pieces}), weaponModes: () => [], isMainMode: () => false,
  isEmpty: p => !p || !p.name, wsWeaponFits: () => true,
  SLOTS: ['main', 'sub', 'range', 'ammo', 'head', 'ear1'], WEAPON_SLOTS: new Set(['main', 'sub', 'range', 'ammo']),
  optContextInput: s => ({ws: s.ws, enemy: 'Aminon', sub: 'NIN', ml: 50, base: null}),
  optPieces: p => p,
  FFXI: {opt: {
    context: inp => inp,
    // the engine: Blast Shot cannot be worked out (a ranged weaponskill); Moonshade worth it under 2000 TP
    tpBest: (c, p, tp) => {
      if (c.ws === 'Blast Shot') throw new Error('ranged weapon skill: accuracy bonus by TP not on its page');
      return tp < 2000 ? {add: {ear1: {name: 'Moonshade Earring'}}, gain: 0.2} : {add: {}, gain: 0};
    }}},
};
vm.createContext(ctx);
vm.runInContext(luaStrLine + '\n' + fs.readFileSync('atelier/app/js/tp_table.js', 'utf8') +
  '\n;this.tpTableAfterExport = tpTableAfterExport;', ctx, {filename: 'tp_table.js'});

(async () => {
  await ctx.tpTableAfterExport('Kaories', d);
  check('one file written', saved.length === 1);
  const first = saved[0] || {file: '', text: ''};
  check('its name: tp_pieces_COR.lua', first.file === 'tp_pieces_COR.lua');
  check('Blast Shot skipped and named in the toast', /tpTableSkipped.*Blast Shot \(Naegling\)/.test(ctx.S.toast || ''));
  check('Savage Blade still written', first.text.includes("['Savage Blade']") && !first.text.includes('Blast Shot'));
  check('the page keeps this job only', Object.keys(d.tp_pieces || {}).join() === 'COR');

  await ctx.tpTableAfterExport('Kaories', d);
  check('same buffs: nothing written again', saved.length === 1);
  buffs = {food: 'Grape Daifuku', rolls: ["Chaos Roll"]};
  await ctx.tpTableAfterExport('Kaories', d);
  check('other buffs ticked: worked out and written again', saved.length === 2);

  // the game reads it back (its own reader, its own data parser)
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'tp_table_test_'));
  const file = path.join(dir, 'tp_pieces_COR.lua');
  fs.writeFileSync(file, saved[saved.length - 1].text);
  const lua = `package.path = './?.lua;' .. package.path
    windower = {}
    package.loaded['shared/utils/core/char_paths'] = {file = function(_, name) return [[${dir}]] .. '/' .. name end}
    local T = require('shared/utils/weaponskill/tp_pieces_table')
    local v = T.variants('COR', 'Savage Blade', 'Naegling')
    local seg = v and v[1] and v[1].segments or {}
    local out = {#(v or {}), v and v[1] and v[1].set and v[1].set.head or '-', #seg}
    for _, s in ipairs(seg) do out[#out + 1] = s.tp .. ':' .. (s.p.ear1 or '-') .. ':' .. s.g end
    out[#out + 1] = tostring(T.variants('COR', 'Blast Shot', 'Naegling'))
    print(table.concat(out, '|'))`;
  let got = '';
  try { got = execFileSync('lua5.1', ['-e', lua], {encoding: 'utf8'}).trim(); } catch (e) { got = 'error: ' + e.message; }
  check('read back by the game: ' + got, got === '1|Nyame Helm|2|1000:Moonshade Earring:0.2|2000:-:0|nil');
  fs.rmSync(dir, {recursive: true, force: true});

  console.log(failed === 0 ? '\nALL OK' : '\n' + failed + ' FAILED');
  process.exit(failed === 0 ? 0 : 1);
})();
