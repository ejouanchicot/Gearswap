// ============================================================================
// Probe spec - the scenarios to play on the foreign file and on ours
// ============================================================================
// From what foreign_eval.lua read: idle and engaged with every value of each
// of his modes (one mode at a time, the others at their default), every
// weaponskill and ability his sets name (each weaponskill with every value of
// his Weaponskill Mode), one ability of each kind his sets name (Waltz,
// Step...), and every spell the job and its subjob can cast. Writes two specs
// with the same labels: his (his mode names) and ours (through the map's
// `modes`: {HisMode: {state: 'OurMode', values: {his: 'ours'}}}).
//
//   node make_spec.js <eval.json> <map.js|-> <his_spec.json> <our_spec.json> [his job file]
// With his job file: every buff it reads (idle, engaged, weaponskills, ranged, every spell),
// ranged attacks for RNG / COR, low MP and a Light day and weather when it reads them.
//
// @file    scripts/convert/make_spec.js
// @author  ejouanchicot
// @version 1.0
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs');
const [evalPath, mapPath, hisPath, ourPath] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(evalPath, 'utf8'));
const map = mapPath && mapPath !== '-' ? require(require('path').resolve(mapPath)) : {};

// Mote's own modes that pick no gear, and his bookkeeping states
const SKIP = new Set(['EquipStop', 'MagicalDefenseMode', 'PCTargetMode', 'SelectNPCTargets', 'CombatForm', 'CombatWeapon',
  'RestingMode', 'RangedMode', 'Moving', 'EngagedMoving', 'Auto_Kite', 'warned', 'NukeType', 'OpenType', 'CloseType',
  'Etude', 'Carol', 'Threnody', ...(map.skip_modes || [])]);
// one ability standing for each kind Mote looks up as sets.precast.<kind>
const KIND_SAMPLE = {Waltz: 'Curing Waltz III', Step: 'Box Step', Flourish1: 'Animated Flourish', Flourish2: 'Reverse Flourish',
  Flourish3: 'Climactic Flourish', Jig: 'Spectral Jig', Samba: 'Haste Samba', CorsairShot: 'Fire Shot', Rune: 'Ignis',
  Ward: 'Vallation', Effusion: 'Swipe', Scholar: 'Penury', Monster: 'Sic'};

const keysOf = p => { const k = []; const re = /\["((?:[^"\\]|\\.)*)"\]/g; let m; while ((m = re.exec(p))) k.push(m[1]); return k; };
const paths = data.sets.map(s => keysOf(s.path));
const under = (...prefix) => [...new Set(paths.filter(k => k.length > prefix.length && prefix.every((p, i) => k[i] === p))
  .map(k => k[prefix.length]))];

const modes = Object.entries(data.modes || {})
  .filter(([n, m]) => !SKIP.has(n) && m.type === 'list' && m.options && m.options.length > 1);
const bool = Object.entries(data.modes || {}).filter(([n, m]) => !SKIP.has(n) && m.type === 'boolean');

const his = [], ours = [];
function add(label, sc) {
  his.push({label, ...sc});
  const t = {...sc, modes: {}};
  for (const [name, value] of Object.entries(sc.modes || {})) {
    const m = (map.modes || {})[name];
    if (m === false) continue;
    const to = (m && m.state) || name;
    t.modes[to] = (m && m.values && m.values[value]) || value;
  }
  ours.push({label, ...t});
}

for (const status of ['Idle', 'Engaged']) {
  add(status, {status});
  for (const [name, m] of modes) for (const v of m.options.slice(1).concat(m.options[0] !== m.default ? [m.default] : []))
    add(`${status} ${name}=${v}`, {status, modes: {[name]: v}});
  for (const [name, m] of bool) add(`${status} ${name}=${!m.default}`, {status, modes: {[name]: !m.default}});
}

// with a pet out, for the jobs whose sets change with one
const PET = {GEO: 'Luopan', BST: 'FunguarFamiliar', PUP: 'Automaton', SMN: 'Carbuncle', DRG: 'Wyvern'};
if (PET[data.job]) for (const status of ['Idle', 'Engaged']) add(`${status} pet`, {status, pet: PET[data.job]});

const wsMode = modes.find(([n]) => n === 'WeaponskillMode');
const SKILLS = new Set(['Hand-to-Hand', 'Dagger', 'Sword', 'Great Sword', 'Axe', 'Great Axe', 'Scythe', 'Polearm', 'Katana',
  'Great Katana', 'Club', 'Staff', 'Archery', 'Marksmanship', 'Throwing']);
// weaponskills that only his base set covers: a few of the job's, so sets.precast.WS is played too
const WS_SAMPLE = {WAR: ['Savage Blade', 'Upheaval', "Ukko's Fury"], DRK: ['Torcleaver', 'Cross Reaper'], SAM: ['Tachi: Fudo'],
  DRG: ['Stardiver'], BLU: ['Savage Blade', 'Expiacion'], NIN: ['Blade: Hi'], MNK: ['Victory Smite'], THF: ["Rudra's Storm"],
  BST: ['Decimation'], PLD: ['Savage Blade'], RUN: ['Dimidiation'], RDM: ['Savage Blade', 'Seraph Blade'],
  COR: ['Leaden Salute', 'Savage Blade'], RNG: ['Last Stand'], BRD: ["Rudra's Storm", 'Mordant Rime'], DNC: ["Rudra's Storm"],
  GEO: ['Black Halo'], WHM: ['Black Halo'], BLM: ['Myrkr'], SCH: ['Myrkr'], PUP: ['Victory Smite'], SMN: ['Garland of Bliss']};
const wsNames = new Set(under('precast', 'WS').filter(n => !SKILLS.has(n) && !(wsMode && wsMode[1].options.includes(n))));
for (const n of WS_SAMPLE[data.job] || []) wsNames.add(n);
for (const ws of wsNames) {
  add(`ws:${ws}`, {status: 'Engaged', action: {kind: 'ws', name: ws}});
  if (wsMode) for (const v of wsMode[1].options.slice(1)) add(`ws:${ws} WeaponskillMode=${v}`,
    {status: 'Engaged', modes: {WeaponskillMode: v}, action: {kind: 'ws', name: ws}});
}
for (const ja of under('precast', 'JA')) add(`ja:${ja}`, {status: 'Idle', action: {kind: 'ja', name: ja}});
for (const kind of under('precast')) {
  if (['FC', 'JA', 'WS', 'RA'].includes(kind)) continue;
  for (const name of under('precast', kind)) add(`ja:${name}`, {status: 'Idle', action: {kind: 'ja', name}});
  if (KIND_SAMPLE[kind]) add(`ja:${KIND_SAMPLE[kind]}`, {status: 'Idle', action: {kind: 'ja', name: KIND_SAMPLE[kind]}});
}
// the map's own scenarios ({label, status, modes, mp, action})
for (const x of map.scenarios || []) add(x.label, x);
// every spell, then again under each value of his Casting Mode
// the subjob played (7th argument) when it is not the one his file was read with
const spells = {expand: 'spells', main: data.job, sub: process.argv[7] || data.sub, sub_level: 53, status: 'Idle'};
his.push({...spells, label: 'spells'}); ours.push({...spells, label: 'spells'});
const cast = modes.find(([n]) => n === 'CastingMode');
if (cast) for (const v of cast[1].options.slice(1)) {
  const sc = {...spells, label_suffix: ` CastingMode=${v}`};
  his.push({...sc, modes: {CastingMode: v}});
  const m = (map.modes || {}).CastingMode;
  if (m !== false) ours.push({...sc, modes: {[(m && m.state) || 'CastingMode']: (m && m.values && m.values[v]) || v}});
}
// ---------------------------------------------------------------- what his code reacts to
// (his job file, when given: the buffs it reads, whether it reads MP, the world)
const jobFile = process.argv[6];
if (jobFile && fs.existsSync(jobFile)) {
  const text = fs.readFileSync(jobFile, 'latin1').replace(/--\[(=*)\[[\s\S]*?\]\1\]/g, '').replace(/--[^\n]*/g, '');
  const grab = re => [...text.matchAll(re)].map(m => m[1]);
  const title = s => s.replace(/(^|[\s(:])([a-z])/g, (m, a, b) => a + b.toUpperCase());
  const seenBuff = new Set(), buffs = [];
  for (const b of [...grab(/buffactive\[["']([^"']+)["']\]/g), ...grab(/buffactive\.(\w+)/g), ...grab(/state\.Buff\[["']([^"']+)["']\]/g),
    ...grab(/state\.Buff\.(\w+)/g), ...grab(/buff\s*==\s*["']([^"']+)["']/gi)]) {
    const k = b.toLowerCase();
    if (!seenBuff.has(k)) { seenBuff.add(k); buffs.push(title(b)); }
  }
  const ranged = ['RNG', 'COR'].includes(data.job);
  const wsList = [...wsNames];
  for (const b of buffs) {
    for (const status of ['Idle', 'Engaged']) add(`${status} +${b}`, {status, buffs: [b]});
    for (const ws of wsList) add(`ws:${ws} +${b}`, {status: 'Engaged', buffs: [b], action: {kind: 'ws', name: ws}});
    if (ranged) add(`ra +${b}`, {status: 'Engaged', buffs: [b], action: {kind: 'ra', name: 'Ranged'}});
    const sc = {...spells, label_suffix: ` +${b}`, buffs: [b]};
    his.push({...sc}); ours.push({...sc});
  }
  if (ranged) {
    add('ra', {status: 'Engaged', action: {kind: 'ra', name: 'Ranged'}});
    for (const [name, m] of modes) for (const v of m.options.slice(1)) add(`ra ${name}=${v}`,
      {status: 'Engaged', modes: {[name]: v}, action: {kind: 'ra', name: 'Ranged'}});
  }
  if (/player\.mpp?\b/.test(text)) {
    add('Idle mp=300', {status: 'Idle', mp: 300});
    add('Idle mp=300 +Sublimation: Activated', {status: 'Idle', mp: 300, buffs: ['Sublimation: Activated']});
    const sc = {...spells, label_suffix: ' mp=300', mp: 300};
    his.push({...sc}); ours.push({...sc});
  }
  if (/world\.(day|weather)/.test(text)) {
    const w = {day_element: 'Light', weather_element: 'Light', day: 'Lightsday', weather: 'Auroras'};
    const sc = {...spells, label_suffix: ' Light day+weather', world: w};
    his.push({...sc}); ours.push({...sc});
  }
}
// every job: resting, and idle in a city and in Adoulin
if (paths.some(k => k[0] === 'resting')) add('Resting', {status: 'Resting'});
add('Idle in Windurst Woods', {status: 'Idle', world: {area: 'Windurst Woods'}});
add('Idle in Western Adoulin', {status: 'Idle', world: {area: 'Western Adoulin'}});

// dedupe labels (an ability named under two kinds)
const seen = new Set();
const uniq = l => l.filter(s => { const k = s.label + (s.label_suffix || ''); if (s.expand) return true; if (seen.has(k)) return false; seen.add(k); return true; });
fs.writeFileSync(hisPath, JSON.stringify(uniq(his)));
seen.clear();
fs.writeFileSync(ourPath, JSON.stringify(uniq(ours)));
console.log(`${data.job}: ${his.length} scenario lines`);
