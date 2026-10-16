// ============================================================================
// Foreign GearSwap converter - writes one job's sets file in our format
// ============================================================================
// From what foreign_eval.lua read (the sets as GearSwap holds them after the
// load), writes <job>_sets.lua the way _master/sets/ writes them:
//   - each augmented piece (or piece with a bag / priority) defined once as a
//     local, variants of the same item in one table (Cape.stp, Cape.ws)
//   - a set whose ancestor set it fully contains is written
//     set_combine(ancestor, {the slots that differ}); other sets whole
//   - a set that is another one (the same table) written `sets.a = sets.b`
//   - slots ear1 ear2 ring1 ring2, `empty` kept
// The mapping (renames, sets left out with why, comments) comes from a job
// file of scripts/convert/maps/; every set it does not name keeps its path.
//
//   node write_sets.js <eval.json> <map.js|-> <out.lua> <report.json>
//
// @file    scripts/convert/write_sets.js
// @author  ejouanchicot
// @version 1.0
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs');

const [evalPath, mapPath, outPath, reportPath] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(evalPath, 'utf8'));
const map = Object.assign({}, mapPath && mapPath !== '-' ? require(require('path').resolve(mapPath)) : {});
// what his globals file does on every job (maps/<player>/_globals.js): its sets added under the job's own
const globalsPath = require('path').join(__dirname, 'maps', data.player.toLowerCase(), '_globals.js');
if (fs.existsSync(globalsPath)) map.add = Object.assign({}, require(globalsPath).add || {}, map.add || {});

const SLOT_ORDER = ['main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear', 'body', 'hands',
  'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'];
const SLOT_OUT = {left_ear: 'ear1', right_ear: 'ear2', left_ring: 'ring1', right_ring: 'ring2'};
const SLOT_IN = {ear1: 'left_ear', ear2: 'right_ear', ring1: 'left_ring', ring2: 'right_ring'};

// ---------------------------------------------------------------- paths
// 'sets["precast"]["WS"]["Savage Blade"]' (eval) or 'sets.precast.WS["Savage Blade"]' (map) -> keys
function parsePath(p) {
  // the map may leave out the leading `sets.` ('me.idle', 'precast.WS["Savage Blade"]')
  if (!/^(sets\b|\.|\[)/.test(p)) p = '.' + p;
  const keys = [];
  let i = p.startsWith('sets') ? 4 : 0;
  while (i < p.length) {
    if (p[i] === '.') {
      const m = /^\.([A-Za-z_][\w]*)/.exec(p.slice(i));
      keys.push(m[1]); i += m[0].length;
    } else if (p[i] === '[') {
      const q = p[i + 1];
      let j = i + 2, s = '';
      while (p[j] !== q) { if (p[j] === '\\') j++; s += p[j]; j++; }
      keys.push(s); i = j + 2;
    } else throw new Error('bad path ' + p);
  }
  return keys;
}
const keyOf = keys => JSON.stringify(keys);
function luaStr(s) {
  if (!s.includes("'")) return "'" + s.replace(/\\/g, '\\\\') + "'";
  if (!s.includes('"')) return '"' + s.replace(/\\/g, '\\\\') + '"';
  return "'" + s.replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "'";
}
function luaPath(keys) {
  let p = 'sets';
  for (const k of keys) p += /^[A-Za-z_]\w*$/.test(k) ? '.' + k : '[' + luaStr(k) + ']';
  return p;
}

// ---------------------------------------------------------------- the sets, renamed
const report = {renamed: [], dropped: [], kept_unread: [], notes: [], odd_keys: [], missing: data.missing,
  nil_args: data.nil_args, errors: data.errors};
const renames = new Map(Object.entries(map.rename || {}).map(([a, b]) => [keyOf(parsePath(a)), parsePath(b)]));
const drops = new Map(Object.entries(map.drop || {}).map(([a, why]) => [keyOf(parsePath(a)), why]));
const notes = new Map(Object.entries(map.note || {}).map(([a, n]) => [keyOf(parsePath(a)), n]));

// a rename of a set also moves the sets under it (engaged.DT -> engaged.PDT moves engaged.DT.Acc)
function renamed(keys) {
  for (let n = keys.length; n > 0; n--) {
    const r = renames.get(keyOf(keys.slice(0, n)));
    if (r) return r.concat(keys.slice(n));
  }
  return keys;
}
function dropped(keys) {
  for (let n = keys.length; n > 0; n--) {
    const why = drops.get(keyOf(keys.slice(0, n)));
    if (why) return why;
  }
  return null;
}

const sets = [];          // {keys, pieces} | {keys, alias: keys}
const byKey = new Map();
const oldToNew = new Map();
for (const s of data.sets) {
  const old = parsePath(s.path);
  if (!old.length) continue;
  const why = dropped(old);
  if (why) { report.dropped.push({set: luaPath(old), why}); continue; }
  const keys = renamed(old);
  oldToNew.set(keyOf(old), keys);
  if (keyOf(keys) !== keyOf(old)) report.renamed.push({from: luaPath(old), to: luaPath(keys)});
  if (s.odd_keys) report.odd_keys.push({set: luaPath(old), keys: s.odd_keys});
  const e = s.same_as ? {keys, aliasOld: parsePath(s.same_as)} : {keys, pieces: s.pieces};
  if (byKey.has(keyOf(keys))) throw new Error('two sets renamed to ' + luaPath(keys));
  byKey.set(keyOf(keys), e);
  sets.push(e);
}
for (const e of sets) {
  if (!e.aliasOld) continue;
  const why = dropped(e.aliasOld);
  e.alias = oldToNew.get(keyOf(e.aliasOld));
  if (why || !e.alias) {
    // the set it shares is left out: write its pieces here instead
    const src = data.sets.find(x => keyOf(parsePath(x.path)) === keyOf(e.aliasOld));
    e.pieces = src.pieces; delete e.alias;
  }
}
// sets added by the map (Adoulin from his globals file...)
for (const [p, pieces] of Object.entries(map.add || {})) {
  const keys = parsePath(p);
  if (byKey.has(keyOf(keys))) continue;
  const e = {keys, pieces, added: true};
  byKey.set(keyOf(keys), e); sets.push(e);
}

// Mote's gear.ElementalObi and kin, named only at cast time by his code: our systems put those pieces on
report.dynamic = [];
// a slot given a table with no item name (feet = {} where his gear table had no such entry): no
// piece in game either; left out and said
report.nameless = [];
for (const e of sets) {
  for (const [slot, p] of Object.entries(e.pieces || {})) {
    if (p === '<dynamic>') { delete e.pieces[slot]; report.dynamic.push(luaPath(e.keys) + '.' + slot); }
    else if (p && typeof p === 'object' && !p.name) { delete e.pieces[slot]; report.nameless.push(luaPath(e.keys) + '.' + slot); }
  }
}

// a new set built from his sets ({path: {from: ['midcast.SongEnfeeble', ...], pieces: {range: 'Gjallarhorn'}}}),
// written set_combine(first, others..., {pieces}): what his code put together at cast time
for (const [p, d] of Object.entries(map.derive || {})) {
  const keys = parsePath(p);
  if (byKey.has(keyOf(keys))) throw new Error(`derive ${p}: a set has that name already`);
  const from = d.from.map(parsePath);
  const resolve = k => { let e = byKey.get(keyOf(k)); while (e && e.alias) e = byKey.get(keyOf(e.alias)); return e; };
  const pieces = {};
  for (const k of from) {
    const e = resolve(k);
    if (!e || !e.pieces) throw new Error(`derive ${p}: ${luaPath(k)} does not exist`);
    Object.assign(pieces, e.pieces);
  }
  for (const [slot, item] of Object.entries(d.pieces || {})) pieces[slot.replace(/^ear1$/, 'left_ear').replace(/^ear2$/, 'right_ear')
    .replace(/^ring1$/, 'left_ring').replace(/^ring2$/, 'right_ring')] = item;
  const e = {keys, pieces, derived: {from, extra: d.pieces || {}}, added: true};
  byKey.set(keyOf(keys), e); sets.push(e);
}

// a set of his that his code laid over another one at cast time, while ours wears it alone:
// written set_combine(<that set>, {his pieces}) (map.rebase: {'midcast.March': 'midcast.BardSong'})
for (const [p, base] of Object.entries(map.rebase || {})) {
  const e = byKey.get(keyOf(parsePath(p)));
  if (!e || !e.pieces) throw new Error(`rebase ${p}: no such set`);
  e.rebase = parsePath(base);
}
// the same for a family map, which names sets a player may not have: only those he has, over a set he has
for (const [p, base] of Object.entries(map.rebase_if || {})) {
  const e = byKey.get(keyOf(parsePath(p)));
  if (e && e.pieces && byKey.has(keyOf(parsePath(base))) && !(map.rebase || {})[p]) e.rebase = parsePath(base);
}
// the other way round: a set his code laid OVER one of his sets at cast time (map.overlay:
// {'midcast.Aquaveil': 'midcast.EnhancingDuration'}), written set_combine({his pieces}, <that set>)
for (const [p, over] of Object.entries(map.overlay || {})) {
  const e = byKey.get(keyOf(parsePath(p)));
  if (!e || !e.pieces) throw new Error(`overlay ${p}: no such set`);
  e.overlay = parsePath(over);
}

// names our code reads for one of his sets, as that same set (map.alias: {'me.idle': 'idle'})
for (const [p, target] of Object.entries(map.alias || {})) {
  const keys = parsePath(p), to = parsePath(target);
  if (byKey.has(keyOf(keys))) throw new Error(`alias ${p}: a set has that name already`);
  if (!byKey.has(keyOf(to))) { report.notes.push({set: luaPath(keys), note: `not written: ${target} does not exist`}); continue; }
  const e = {keys, alias: to, added: true};
  byKey.set(keyOf(keys), e); sets.push(e);
}

const isContainer = e => e.pieces && Object.keys(e.pieces).length === 0;

// ---------------------------------------------------------------- locals for augmented pieces
const TAGS = [[/"Fast Cast"/i, 'fc'], [/Weapon skill damage/i, 'wsd'], [/"Dbl\.Atk\."/i, 'da'], [/"Store TP"/i, 'stp'],
  [/"Dual Wield"/i, 'dw'], [/Crit\.hit rate/i, 'crit'], [/Mag\. Atk\. Bns\./i, 'mab'], [/"Mag\.Atk\.Bns\."/i, 'mab'],
  [/Enmity\+/i, 'enmity'], [/"Regen"/i, 'regen'], [/"Refresh"/i, 'refresh'], [/Phalanx/i, 'phalanx'],
  [/"Treasure Hunter"/i, 'th'], [/Pet:/i, 'pet'], [/Rng\.Acc|Rng\.Atk/i, 'ranged'], [/"Snapshot"/i, 'snapshot'],
  [/Mag\. Acc|Magic Accuracy/i, 'macc'], [/"Cure" potency/i, 'cure'], [/"Waltz"/i, 'waltz'],
  [/"Triple Atk\."/i, 'ta'], [/Song spellcasting|Song/i, 'song'], [/Path: A/, 'a'], [/Path: B/, 'b'],
  [/Path: C/, 'c'], [/Path: D/, 'd']];
const camel = name => {
  let v = name.replace(/\+(\d)/g, ' $1').replace(/[^A-Za-z0-9 ]/g, ' ').split(/\s+/).filter(Boolean)
    .map(w => w[0].toUpperCase() + w.slice(1)).join('');
  if (/^\d/.test(v)) v = 'Item' + v;
  return v;
};
const LUA_WORDS = new Set(['and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'if', 'in',
  'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while']);

// ---------------------------------------------------------------- his gear tables (write_gear.js)
// A piece his 0_AugGear tables hold is written by its path there (HERC.Feet.TA), the one his own
// job file writes most (then the shortest): his gear file stays the one place a piece is defined.
// GEAR_FILE: where the converted sets include it from.
const GEAR_FILE = `_common/sets/0_AugGear_${data.player}.lua`;
const gearPath = new Map();     // piece signature -> path
if ((data.gear || []).length) {
  let source = '';
  for (const dir of [data.source_dir + data.player + '/', data.source_dir]) {
    if (fs.existsSync(dir + data.file)) { source = fs.readFileSync(dir + data.file, 'latin1'); break; }
  }
  const uses = path => source.split(path).length - 1;
  const candidates = new Map();
  for (const g of data.gear) {
    if (g.piece === 'empty') continue;
    const sig = JSON.stringify(g.piece);
    if (!candidates.has(sig)) candidates.set(sig, []);
    candidates.get(sig).push(g.path);
  }
  for (const [sig, paths] of candidates) {
    paths.sort((a, b) => uses(b) - uses(a) || a.length - b.length || a.localeCompare(b));
    gearPath.set(sig, paths[0]);
  }
}
const gearUsed = new Set();

const variants = new Map();   // item name -> Map(signature -> piece)
for (const e of sets) {
  for (const p of Object.values(e.pieces || {})) {
    if (typeof p !== 'object') continue;
    if (gearPath.has(JSON.stringify(p))) continue;
    const sig = JSON.stringify(p);
    if (!variants.has(p.name)) variants.set(p.name, new Map());
    variants.get(p.name).set(sig, p);
  }
}
const pieceVar = new Map();   // signature -> lua expression
const localDefs = [];
const usedNames = new Set();
for (const [name, vs] of [...variants].sort((a, b) => a[0].localeCompare(b[0]))) {
  let base = camel(name);
  while (usedNames.has(base)) base += 'X';
  usedNames.add(base);
  const list = [...vs.values()];
  if (list.length === 1) {
    pieceVar.set(JSON.stringify(list[0]), base);
    localDefs.push({name: base, pieces: [[null, list[0]]]});
    continue;
  }
  const taken = new Set(), entries = [];
  list.forEach((p, i) => {
    const text = (p.augments || []).join(' ') + (p.bag ? ' ' + p.bag : '');
    let tag = null;
    for (const [re, t] of TAGS) if (re.test(text) && !taken.has(t)) { tag = t; break; }
    if (!tag && p.bag) tag = p.bag.replace(/\s+/g, '').toLowerCase();
    if (!tag || taken.has(tag) || LUA_WORDS.has(tag)) tag = 'v' + (i + 1);
    taken.add(tag);
    pieceVar.set(JSON.stringify(p), base + '.' + tag);
    entries.push([tag, p]);
  });
  localDefs.push({name: base, pieces: entries});
}

function pieceTable(p, indent) {
  const lines = [`${indent}    name = ${luaStr(p.name)},`];
  if (p.augments) lines.push(`${indent}    augments = {${p.augments.map(luaStr).join(', ')}},`);
  if (p.bag) lines.push(`${indent}    bag = ${luaStr(p.bag)},`);
  if (p.priority !== undefined) lines.push(`${indent}    priority = ${p.priority},`);
  return '{\n' + lines.join('\n') + '\n' + indent + '}';
}
const expr = p => {
  if (p === 'empty') return 'empty';
  const g = gearPath.get(JSON.stringify(p));
  if (g) { gearUsed.add(g); return g; }
  return typeof p === 'string' ? luaStr(p) : pieceVar.get(JSON.stringify(p));
};

// ---------------------------------------------------------------- inheritance
const sameItem = (a, b) => JSON.stringify(a) === JSON.stringify(b);
function parentOf(e) {
  for (let n = e.keys.length - 1; n >= 1; n--) {
    const p = byKey.get(keyOf(e.keys.slice(0, n)));
    if (!p) continue;
    const pieces = p.pieces || (p.alias && (byKey.get(keyOf(p.alias)) || {}).pieces);
    if (!pieces || !Object.keys(pieces).length) continue;
    // set_combine can add and change slots, never take one away
    if (Object.keys(pieces).every(s => s in e.pieces)) return {keys: p.keys, pieces};
    return null;
  }
  return null;
}

// ---------------------------------------------------------------- sections
const SECTIONS = [
  ['WEAPON SETS', e => e.keys.length === 1 && e.pieces && Object.keys(e.pieces).length &&
    Object.keys(e.pieces).every(s => ['main', 'sub', 'range', 'ammo'].includes(s))],
  ['IDLE SETS', e => e.keys[0] === 'idle' || e.keys[0] === 'resting'],
  ['ENGAGED SETS', e => e.keys[0] === 'engaged'],
  ['DEFENSE SETS', e => e.keys[0] === 'defense'],
  ['PRECAST: JOB ABILITIES', e => e.keys[0] === 'precast' && !['FC', 'WS', 'RA'].includes(e.keys[1])],
  ['PRECAST: FAST CAST', e => e.keys[0] === 'precast' && e.keys[1] === 'FC'],
  ['PRECAST: WEAPONSKILLS', e => e.keys[0] === 'precast' && e.keys[1] === 'WS'],
  ['RANGED ATTACKS', e => (e.keys[0] === 'precast' || e.keys[0] === 'midcast') && e.keys[1] === 'RA'],
  ['MIDCAST', e => e.keys[0] === 'midcast'],
  ['BUFF SETS', e => e.keys[0] === 'buff'],
  ['OTHER SETS', () => true],
];
// Mote's own tables (init_include): written over only when they hold pieces
const SKELETON = new Set(['precast', 'precast.FC', 'precast.JA', 'precast.WS', 'precast.RA', 'midcast', 'midcast.RA',
  'midcast.Pet', 'idle', 'resting', 'engaged', 'defense', 'buff', 'naked'].map(p => keyOf(p.split('.'))));

const placed = new Set();
const out = [];
const depthSort = (a, b) => a.keys.length - b.keys.length || luaPath(a.keys).localeCompare(luaPath(b.keys));
const pending = [...sets].sort(depthSort);

function writeSet(e, lines) {
  const path = luaPath(e.keys);
  const note = notes.get(keyOf(e.keys));
  if (note) for (const l of note.split('\n')) lines.push('-- ' + l);
  if (e.alias) { lines.push(`${path} = ${luaPath(e.alias)}`); return; }
  if (e.derived) {
    const body = Object.entries(e.derived.extra).map(([s, p]) => `    ${s} = ${expr(p) || luaStr(p)},`).join('\n');
    lines.push(`${path} = set_combine(${e.derived.from.map(luaPath).join(', ')}, ${body ? '{\n' + body + '\n}' : '{}'})`);
    return;
  }
  // (an empty set laid over another one is that set: rebase / overlay first)
  if (isContainer(e) && !e.rebase && !e.overlay) {
    if (!SKELETON.has(keyOf(e.keys))) lines.push(`${path} = {}`);
    return;
  }
  if (e.rebase || e.overlay) {
    const slots = SLOT_ORDER.filter(s => s in e.pieces);
    const body = slots.map(s => `    ${SLOT_OUT[s] || s} = ${expr(e.pieces[s])},`).join('\n');
    const own = slots.length ? '{\n' + body + '\n}' : '{}';
    lines.push(e.rebase ? `${path} = set_combine(${luaPath(e.rebase)}, ${own})`
      : `${path} = set_combine(${own}, ${luaPath(e.overlay)})`);
    return;
  }
  const parent = parentOf(e);
  let pieces = e.pieces;
  if (parent) {
    pieces = {};
    for (const [s, p] of Object.entries(e.pieces)) if (!sameItem(p, parent.pieces[s])) pieces[s] = p;
  }
  const slots = SLOT_ORDER.filter(s => s in pieces);
  const body = slots.map(s => `    ${SLOT_OUT[s] || s} = ${expr(pieces[s])},`).join('\n');
  const table = slots.length ? '{\n' + body + '\n}' : '{}';
  lines.push(parent ? `${path} = set_combine(${luaPath(parent.keys)}, ${table})` : `${path} = ${table}`);
}

// a set waits for the sets its path, its parent and its alias need
function ready(e) {
  for (let n = 1; n < e.keys.length; n++) {
    const k = keyOf(e.keys.slice(0, n));
    if (byKey.has(k) && !placed.has(k)) return false;
  }
  if (e.alias && !placed.has(keyOf(e.alias))) return false;
  if (e.derived && e.derived.from.some(k => !placed.has(keyOf(k)))) return false;
  if (e.rebase && !placed.has(keyOf(e.rebase))) return false;
  if (e.overlay && !placed.has(keyOf(e.overlay))) return false;
  return true;
}
const sectionOf = e => SECTIONS.findIndex(([, f]) => f(e));
const bySection = SECTIONS.map(() => []);
const sectionAt = new Map();
let guard = 0;
while (pending.length && guard++ < 100000) {
  const i = pending.findIndex(ready);
  if (i < 0) throw new Error('cannot order: ' + pending.map(e => luaPath(e.keys)).join(', '));
  const [e] = pending.splice(i, 1);
  placed.add(keyOf(e.keys));
  // a set goes no earlier than the sets it needs (sets.precast.FC = sets.midcast.FastRecast: under MIDCAST)
  let section = sectionOf(e);
  const deps = [];
  for (let n = 1; n < e.keys.length; n++) deps.push(keyOf(e.keys.slice(0, n)));
  if (e.alias) deps.push(keyOf(e.alias));
  if (e.derived) for (const k of e.derived.from) deps.push(keyOf(k));
  if (e.rebase) deps.push(keyOf(e.rebase));
  if (e.overlay) deps.push(keyOf(e.overlay));
  for (const d of deps) if (sectionAt.has(d)) section = Math.max(section, sectionAt.get(d));
  sectionAt.set(keyOf(e.keys), section);
  bySection[section].push(e);
}

// ---------------------------------------------------------------- text
const job = data.job, player = data.player;
const header = [
  '---============================================================================',
  `--- ${job} Equipment Sets - ${player}`,
  '---============================================================================',
  `--- Converted from ${data.file} (his own GearSwap) on ${new Date().toISOString().slice(0, 10)}`,
  '--- by scripts/convert: every set as his file built it in GearSwap, under the',
  '--- names our code reads (see the report for each rename and what is left out).',
  '---',
  `--- @file    sets/${job.toLowerCase()}_sets.lua`,
  '--- @author  ejouanchicot',
  '--- @version 1.0',
  `--- @date    Created: ${new Date().toISOString().slice(0, 10)}`,
  '---============================================================================',
  '',
];
const body = [];
// filled once the sets are written (gearUsed), see below
const gearAt = body.length;
if (localDefs.length) {
  body.push('-- ============================================================--', '--                  EQUIPMENT DEFINITIONS                     --',
    '-- ============================================================--', '');
  for (const d of localDefs) {
    if (d.pieces.length === 1 && d.pieces[0][0] === null) body.push(`local ${d.name} = ${pieceTable(d.pieces[0][1], '')}`);
    else {
      body.push(`local ${d.name} = {`);
      for (const [tag, p] of d.pieces) body.push(`    ${tag} = ${pieceTable(p, '    ')},`);
      body.push('}');
    }
  }
  body.push('');
}
SECTIONS.forEach(([title], i) => {
  const lines = [];
  for (const e of bySection[i]) writeSet(e, lines);
  if (!lines.length) return;
  body.push('-- ============================================================--', `--  ${title}`.padEnd(62) + '--',
    '-- ============================================================--', '', ...lines, '');
});
if (gearUsed.size) {
  body.splice(gearAt, 0, `-- His gear tables (AF, RELIC, EMPY, capes, HERC...): ${GEAR_FILE}`,
    `-- A piece named from there (CORCape.TP) is changed there, for every job.`, `include('${GEAR_FILE}')`, '');
}
report.gear_used = [...gearUsed].sort();
fs.writeFileSync(outPath, header.concat(body).join('\n'));

// the report: sets the map names as not read by our code
for (const [k, n] of notes) report.notes.push({set: luaPath(JSON.parse(k)), note: n});
// what each written set must hold once loaded (check_roundtrip.js compares it with roundtrip.lua's dump)
report.expected = {};
// the pieces a written set holds once loaded: through its alias, over its rebase set
function built(e) {
  while (e.alias) e = byKey.get(keyOf(e.alias));
  if (e.derived) {
    const out = {};
    for (const k of e.derived.from) Object.assign(out, built(byKey.get(keyOf(k))));
    for (const [slot, item] of Object.entries(e.derived.extra)) out[SLOT_IN[slot] || slot] = item;
    return out;
  }
  if (e.overlay) return Object.assign({}, e.pieces, built(byKey.get(keyOf(e.overlay))));
  if (!e.rebase) return e.pieces;
  return Object.assign({}, built(byKey.get(keyOf(e.rebase))), e.pieces);
}
for (const e of sets) {
  report.expected[luaPath(e.keys)] = built(e);
}
if (reportPath) fs.writeFileSync(reportPath, JSON.stringify(report, null, 1));
console.log(`${job}: ${sets.length} sets written, ${report.renamed.length} renamed, ${report.dropped.length} left out, ${localDefs.length} locals`);
