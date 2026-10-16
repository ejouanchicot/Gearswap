// ============================================================================
// Foreign GearSwap converter - his values for Mote's modes in <JOB>_STATES.lua
// ============================================================================
// Our job templates set some of Mote's modes themselves (DRK: WeaponskillMode
// Normal / Acc). When his sets are named after other values of that mode
// (PDL), the character's STATES file takes his values instead: the line that
// sets the mode's options is rewritten, and a line choosing a default he does
// not have is commented out (Mote refuses an unknown value). A mode the
// template does not set is left to write_custom.js.
// Writes the STATES file and, as JSON, the modes it set (write_custom.js then
// gives them only their gear).
//
//   node write_states.js <eval.json> <map.js|-> <template_STATES.lua> <out.lua> <out.json>
//
// @file    scripts/convert/write_states.js
// @author  ejouanchicot
// @version 1.0
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs'), path = require('path');
const [evalPath, mapPath, templatePath, outPath, jsonPath] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(evalPath, 'utf8'));
const map = mapPath && mapPath !== '-' ? require(require('path').resolve(mapPath)) : {};

const MOTE_MODES = ['OffenseMode', 'HybridMode', 'IdleMode', 'WeaponskillMode', 'CastingMode', 'RangedMode'];
const keysOf = p => { const k = []; const re = /\["((?:[^"\\]|\\.)*)"\]/g; let m; while ((m = re.exec(p))) k.push(m[1]); return k; };
const paths = data.sets.filter(s => s.same_as || Object.keys(s.pieces || {}).length).map(s => keysOf(s.path));
const named = v => paths.some(k => k.includes(v));
const q = v => `'${String(v).replace(/'/g, "\\'")}'`;

let text = fs.readFileSync(templatePath, 'utf8');
const set = {}, notes = [];
for (const name of MOTE_MODES) {
  const m = (data.modes || {})[name];
  if (!m || m.type !== 'list' || !m.options || m.options.length < 2) continue;
  if ((map.modes || {})[name] === false || (map.keep_our_states || []).includes(name)) continue;
  if (!m.options.some(v => v !== 'Normal' && named(v))) continue;
  const opts = m.options.map(q).join(', ');
  // an uncommented definition: state.X = M{...} (one or several lines) or state.X:options(...)
  const def = new RegExp(`^([ \\t]*)state\\.${name}\\s*=\\s*M\\s*\\{[^}]*\\}`, 'm');
  const call = new RegExp(`^([ \\t]*)state\\.${name}:options\\(([^)]*)\\)`, 'm');
  let done = false;
  if (def.test(text)) {
    text = text.replace(def, (all, ind) => `${ind}-- ${data.player}'s values (converted from his GearSwap)\n` +
      `${ind}state.${name} = M{['description']='${(m.description || name).replace(/'/g, "\\'")}', ${opts}}`);
    done = true;
  } else {
    const c = call.exec(text);
    if (c && !/unpack|\.\.\./.test(c[2])) {
      text = text.replace(call, (all, ind) => `${ind}-- ${data.player}'s values (converted from his GearSwap)\n` +
        `${ind}state.${name}:options(${opts})`);
      done = true;
    } else if (c) notes.push(`${name}: the template sets it from a variable, left as it is`);
  }
  if (!done) continue;
  set[name] = m.options;
  // the template's default goes (Mote's :set() would refuse one he does not have, and one he has is
  // still not the one he starts on): his own, when it is not his first value
  const his = m.default && m.options.includes(m.default) ? m.default : m.options[0];
  const choose = new RegExp(`^([ \\t]*)(state\\.${name}:set\\('([^']*)'\\).*)$`, 'mg');
  text = text.replace(choose, (all, ind, line, value) => value === his ? all
    : `${ind}-- ${line}  -- ${data.player} starts on ${his}`);
  if (his !== m.options[0]) {
    const at = new RegExp(`state\\.${name}(\\s*=\\s*M\\{[^\\n]*|:options\\([^\\n]*)`, 'm').exec(text);
    if (at) text = text.slice(0, at.index + at[0].length) + `\nstate.${name}:set(${q(his)})` + text.slice(at.index + at[0].length);
  }
}
// His weapon modes (0_Shared's WeaponSet / SubSet / RangedSet: item names, 'Free' = keep what is worn) are
// our MainWeapon / SubWeapon / RangeWeapon, laid by BaseSetBuilder.lay_weapons (an item name with no set is
// equipped by WEAPON_CONFIG's equip_without_set). A job where he has no such mode gets 'Free' alone: the
// template's values (another character's weapons) would otherwise go over the weapons of his own sets.
// Left to the map when it handles the mode itself (map.modes, a states_patch of that state).
const WEAPONS = [['WeaponSet', 'MainWeapon', 'Main Weapon'], ['SubSet', 'SubWeapon', 'Sub Weapon'], ['RangedSet', 'RangeWeapon', 'Range Weapon']];
let lastWeapon = null;     // end of the last weapon state written: a missing one goes after it
for (const [his, ours, label] of WEAPONS) {
  if ((map.modes || {})[his] !== undefined || (map.states_patch || []).some(p => p.find.includes(`state.${ours}`))) continue;
  const m = (data.modes || {})[his];
  const opts = m && m.type === 'list' && m.options && m.options.length ? m.options : ['Free'];
  const def = new RegExp(`^([ \\t]*)state\\.${ours}\\s*=\\s*M\\s*\\{[^}]*\\}[^\\n]*`, 'm');
  const line = `state.${ours} = M{['description']='${label}', ${opts.map(q).join(', ')}}`;
  const head = `-- ${data.player}'s ${his} (converted from his GearSwap)`;
  const found = def.exec(text);
  let ind = '';
  if (found) {
    ind = found[1];
    text = text.slice(0, found.index) + `${ind}${head}\n${ind}${line}` + text.slice(found.index + found[0].length);
    // the template's own default goes: his is the one he starts on (added below when not his first value)
    const his = m && m.default && opts.includes(m.default) ? m.default : opts[0];
    text = text.replace(new RegExp(`^([ \\t]*)(state\\.${ours}:set\\((['"])(.*?)\\3\\).*)$`, 'mg'),
      (all, i, l, qq, v) => v === his ? all : `${i}-- ${l}  -- ${data.player} starts on ${his}`);
    lastWeapon = new RegExp(`state\\.${ours}\\s*=\\s*M\\{[^\\n]*`, 'm');
  } else if (!(opts.length === 1 && opts[0] === 'Free')) {
    const anchor = lastWeapon && lastWeapon.exec(text);
    if (!anchor) { notes.push(`${his}: no ${ours} in the template to put it after, left out`); continue; }
    ind = (/^[ \t]*/.exec(text.slice(text.lastIndexOf('\n', anchor.index) + 1)) || [''])[0];
    const at = anchor.index + anchor[0].length;
    text = text.slice(0, at) + `\n\n${ind}${head}\n${ind}${line}` + text.slice(at);
    lastWeapon = new RegExp(`state\\.${ours}\\s*=\\s*M\\{[^\\n]*`, 'm');
  } else continue;
  if (m && m.default && m.default !== opts[0] && opts.includes(m.default)) {
    const after = new RegExp(`state\\.${ours}\\s*=\\s*M\\{[^\\n]*`, 'm').exec(text);
    const at = after.index + after[0].length;
    text = text.slice(0, at) + `\n${ind}state.${ours}:set(${q(m.default)})` + text.slice(at);
  }
  set[ours] = opts;
}

// A Hybrid Mode he never had (only Normal) while our template starts on another value (PDT): our
// builders then read sets.engaged.PDT, which he does not have, or which is a set of another mode of
// his (THF's Offense Mode PDT). His characters start on Normal.
const hm = (data.modes || {}).HybridMode;
if (hm && hm.options && hm.options.length === 1 && hm.options[0] === 'Normal' && !set.HybridMode) {
  const def = /^([ \t]*)(state\.HybridMode\s*=\s*M\s*\{[^}]*\}|state\.HybridMode:options\([^)]*\))[^\n]*$/m;
  const m = def.exec(text);
  if (m && /'Normal'/.test(m[2])) {
    text = text.replace(/^([ \t]*)(state\.HybridMode:set\('([^']*)'\).*)$/mg, (all, ind, line, v) =>
      v === 'Normal' ? all : `${ind}-- ${line}  -- ${data.player} had no Hybrid Mode: Normal`);
    text = text.replace(def, (all, ind) => `${all}\n${ind}state.HybridMode:set('Normal')  -- ${data.player} had no Hybrid Mode`);
    notes.push('HybridMode starts on Normal');
  }
}

// the map's own edits of the template ({find: 'exact text', replace: 'new text', why}), each
// required to match once: a template that changed must not be patched blindly
for (const p of map.states_patch || []) {
  const n = text.split(p.find).length - 1;
  if (n !== 1) throw new Error(`states_patch: "${p.find}" found ${n} times in ${templatePath}`);
  text = text.replace(p.find, () => p.replace);
  for (const name of p.sets || []) set[name] = true;
}
fs.writeFileSync(outPath, text);
// His macro book and lockstyle (what his file sent at load: input /macro book N, input /lockstyleset M), the
// same whatever the subjob: written as the default of the job's LOCKSTYLE and MACROBOOK files, their per-subjob
// and dual-box tables emptied (a value there would win over his)
const block = (text, name) => {   // `name = {` ... its closing brace: [start, end] of the whole assignment
  const m = new RegExp(`^${name.replace('.', '\\.')}\\s*=\\s*\\{`, 'm').exec(text);
  if (!m) return null;
  let depth = 0, i = m.index + m[0].length - 1;
  for (; i < text.length; i++) { if (text[i] === '{') depth++; else if (text[i] === '}' && --depth === 0) break; }
  return [m.index, i + 1];
};
const setBlock = (text, name, value) => { const b = block(text, name);
  if (!b) throw new Error(`${name} not found`);
  return text.slice(0, b[0]) + `${name} = ${value}` + text.slice(b[1]); };
const cmds = Array.isArray(data.commands) ? data.commands : [];
const book = (cmds.join(' ').match(/macro book (\d+)/) || [])[1], style = (cmds.join(' ').match(/lockstyleset (\d+)/) || [])[1];
const J = data.job, dir = path.dirname(templatePath), outDir = path.dirname(outPath);
const who = `-- ${data.player}'s own (converted from his GearSwap)`;
if (style) {
  let t = fs.readFileSync(path.join(dir, `${J}_LOCKSTYLE.lua`), 'utf8');
  t = t.replace(new RegExp(`^${J}LockstyleConfig\\.default\\s*=\\s*\\d+`, 'm'), `${who}\n${J}LockstyleConfig.default = ${style}`);
  t = setBlock(t, `${J}LockstyleConfig.by_subjob`, '{}');
  fs.writeFileSync(path.join(outDir, `${J}_LOCKSTYLE.lua`), t);
}
if (book) {
  let t = fs.readFileSync(path.join(dir, `${J}_MACROBOOK.lua`), 'utf8');
  t = setBlock(t, `${J}MacroConfig.default`, `{ book = ${book}, page = 1 }  ${who}`);
  t = setBlock(t, `${J}MacroConfig.solo`, '{}');
  t = setBlock(t, `${J}MacroConfig.dualbox`, '{}');
  fs.writeFileSync(path.join(outDir, `${J}_MACROBOOK.lua`), t);
}

// the same for another config file of the job ({file: 'BLM_MP_CONFIG.lua', find, replace}): written next to STATES
const patched = new Map();   // file -> text, several patches of one file applied in order
// global: true -> a file of _master/config_global/, written to <work>/config_global/
const placeOf = p => p.global
  ? {src: path.join(path.dirname(templatePath), '..', '..', 'config_global', p.file),
     out: path.join(path.dirname(outPath), '..', '..', 'config_global', p.file)}
  : {src: path.join(path.dirname(templatePath), p.file), out: path.join(path.dirname(outPath), p.file)};
for (const p of map.config_patch || []) {
  const src = placeOf(p).src;
  const out = placeOf(p).out;
  let t = patched.has(out) ? patched.get(out) : fs.readFileSync(src, 'utf8');
  const n = t.split(p.find).length - 1;
  if (n !== 1) throw new Error(`config_patch: "${p.find}" found ${n} times in ${src}`);
  patched.set(out, t.replace(p.find, () => p.replace));
}
for (const [out, t] of patched) {
  fs.mkdirSync(path.dirname(out), {recursive: true});
  fs.writeFileSync(out, t);
}
fs.writeFileSync(jsonPath, JSON.stringify({set, notes}));
console.log(`${data.job}: STATES takes his values for ${Object.keys(set).join(', ') || 'no mode'}` +
  (notes.length ? ' (' + notes.join('; ') + ')' : ''));
