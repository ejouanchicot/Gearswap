// ============================================================================
// Foreign GearSwap converter - his modes and gear rules as <JOB>_CUSTOM.lua
// ============================================================================
// Writes the job's custom file (shared/utils/custom/custom_states.lua reads
// it) from what foreign_eval.lua read and the job's map:
//   - each of Mote's modes his sets use (a set named after one of its values):
//     its values, its Mote key, and for OffenseMode / IdleMode the set of each
//     value; WeaponskillMode and CastingMode need no gear, Mote reads
//     sets.precast.WS[ws][mode] itself once the mode has the values
//   - the Reive Mark neck of his globals file, as rules
//   - the map's own entries (map.custom), after these
// The header is the template's (_master/config/<job>/<JOB>_CUSTOM.lua).
//
//   node write_custom.js <eval.json> <map.js|-> <template_CUSTOM.lua> <out.lua>
//
// @file    scripts/convert/write_custom.js
// @author  ejouanchicot
// @version 1.0
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs');
const [evalPath, mapPath, templatePath, outPath, statesPath] = process.argv.slice(2);
// modes write_states.js gave his values in the STATES file: here only their gear
const inStates = statesPath && fs.existsSync(statesPath) ? JSON.parse(fs.readFileSync(statesPath, 'utf8')).set : {};
const data = JSON.parse(fs.readFileSync(evalPath, 'utf8'));
const map = mapPath && mapPath !== '-' ? require(require('path').resolve(mapPath)) : {};
const list = x => Array.isArray(x) ? x : [];

// ---------------------------------------------------------------- Lua text of a JS value
const luaStr = s => !s.includes("'") ? `'${s.replace(/\\/g, '\\\\')}'` : !s.includes('"') ? `"${s.replace(/\\/g, '\\\\')}"`
  : `'${s.replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`;
function toLua(v, indent = '') {
  if (typeof v === 'string') return luaStr(v);
  if (typeof v === 'number' || typeof v === 'boolean') return String(v);
  if (Array.isArray(v)) return '{' + v.map(x => toLua(x, indent)).join(', ') + '}';
  const inner = indent + '    ';
  const keys = Object.keys(v);
  if (!keys.length) return '{}';
  const short = keys.every(k => typeof v[k] !== 'object' || Array.isArray(v[k]));
  const entry = k => `${/^[A-Za-z_]\w*$/.test(k) ? k : '[' + luaStr(k) + ']'} = ${toLua(v[k], inner)}`;
  if (short && keys.length <= 3) return '{ ' + keys.map(entry).join(', ') + ' }';
  return '{\n' + keys.map(k => inner + entry(k) + ',').join('\n') + '\n' + indent + '}';
}

// ---------------------------------------------------------------- his modes
const keysOf = p => { const k = []; const re = /\["((?:[^"\\]|\\.)*)"\]/g; let m; while ((m = re.exec(p))) k.push(m[1]); return k; };
const paths = data.sets.filter(s => s.same_as || Object.keys(s.pieces || {}).length).map(s => keysOf(s.path));
const has = (...keys) => paths.some(k => k.length === keys.length && keys.every((x, i) => k[i] === x));
const named = v => paths.some(k => k.includes(v));
// Mote-Globals.lua's keys for its modes
const MOTE_KEY = {OffenseMode: 'f9', HybridMode: '^f9', RangedMode: '!f9', WeaponskillMode: '@f9', CastingMode: '^f11',
  IdleMode: '^f12'};
const entries = [], notes = [];
for (const [name, m] of Object.entries(data.modes || {})) {
  if (!MOTE_KEY[name] || m.type !== 'list' || !m.options || m.options.length < 2) continue;
  // HybridMode: most of our jobs set it themselves (their values name their sets): the map renames his sets
  if (name === 'HybridMode' || (map.modes || {})[name] === false || (map.skip_custom || []).includes(name)) continue;
  const used = m.options.filter(v => v !== 'Normal' && named(v));
  if (!used.length) { notes.push(`${name} (${m.options.join(', ')}): no set of his is named after a value, left out`); continue; }
  const e = inStates[name] ? {state: name} : {state: name, desc: m.description || name, key: MOTE_KEY[name], values: m.options};
  for (const v of m.options) {
    if (name === 'OffenseMode' && has('engaged', v)) e[v] = {engaged: `sets.engaged.${v}`};
    if (name === 'IdleMode' && has('idle', v)) e[v] = {idle: `sets.idle.${v}`};
  }
  if (inStates[name] && Object.keys(e).length === 1) continue;
  entries.push({comment: `His ${m.description || name} (Mote, ${MOTE_KEY[name]} in his GearSwap)` +
    (inStates[name] ? ', its values set in the STATES file' : '') +
    (name === 'WeaponskillMode' ? ': sets.precast.WS[<weaponskill>].<value> are read by Mote itself' : '') +
    (name === 'CastingMode' ? ': his spell sets .<value> are read by Mote itself' : ''), entry: e});
}

// the Reive Mark neck of his globals file (user_customize_idle_set / user_post_midcast)
if (has('reive') && !map.no_reive) {
  entries.push({comment: 'His globals file: the Reive Mark neck, idle and for nukes and cures', entry:
    {when: {buff: 'Reive Mark'}, idle: 'sets.reive'}});
  entries.push({entry: {when: {buff: 'Reive Mark', skill: 'Elemental Magic'}, midcast: 'sets.reive'}});
  entries.push({entry: {when: {buff: 'Reive Mark', spell: ['Cure*', 'Cura*', 'Full Cure']}, midcast: 'sets.reive'}});
}
// his job file's own Reive rule on weaponskills (map.reive_ws)
if (map.reive_ws) entries.push({comment: "His job file: Ygnas's Resolve +1 on weaponskills during a Reive", entry:
  {when: {buff: 'Reive Mark', spell_type: 'WeaponSkill'}, weaponskill: {neck: "Ygnas's Resolve +1"}}});
for (const c of list(map.custom)) entries.push(c.entry ? c : {entry: c});

// ---------------------------------------------------------------- text
const template = fs.readFileSync(templatePath, 'utf8');
const header = template.slice(0, template.indexOf('return {')).replace(/(--- [A-Z]{3} \([^)]*\) - your own modes and gear rules)/,
  `$1 - ${data.player}`);
const body = ['return {', ''];
body.push(`    -- Converted from ${data.file} (scripts/convert, ${new Date().toISOString().slice(0, 10)}).`);
for (const n of notes) body.push('    -- ' + n);
body.push('');
for (const {comment, entry} of entries) {
  if (comment) for (const l of comment.split('\n')) body.push('    -- ' + l);
  body.push('    ' + toLua(entry, '    ') + ',', '');
}
body.push('}', '');
fs.writeFileSync(outPath, header + body.join('\n'));
console.log(`${data.job}: ${entries.length} custom entries` + (notes.length ? ` (${notes.length} modes left out)` : ''));
